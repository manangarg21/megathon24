import torch
import pickle
from torch.utils.data import Dataset, DataLoader
from transformers import BertForSequenceClassification, BertTokenizer, AdamW
from sklearn.model_selection import train_test_split
import pandas as pd

# Load the embeddings
with open('ner_embeddings.pkl', 'rb') as ner_file:
    ner_embeddings = pickle.load(ner_file)
with open('sentiment_embeddings.pkl', 'rb') as sent_file:
    sentiment_embeddings = pickle.load(sent_file)

# Concatenate embeddings for each data point
combined_embeddings = [torch.cat((ner, sent), dim=0) for ner, sent in zip(ner_embeddings, sentiment_embeddings)]

# Load category labels
data = pd.read_csv('dataset.csv')
categories = data['Category']
label_map = {label: idx for idx, label in enumerate(categories.unique())}
labels = torch.tensor([label_map[label] for label in categories])

# Dataset class
class CombinedDataset(Dataset):
    def __init__(self, embeddings, labels):
        self.embeddings = embeddings
        self.labels = labels

    def __len__(self):
        return len(self.labels)

    def __getitem__(self, idx):
        return {
            'input_ids': self.embeddings[idx],
            'labels': self.labels[idx]
        }

# Train-test split
train_embeddings, test_embeddings, train_labels, test_labels = train_test_split(
    combined_embeddings, labels, test_size=0.2, random_state=42)

# DataLoader
train_dataset = CombinedDataset(train_embeddings, train_labels)
test_dataset = CombinedDataset(test_embeddings, test_labels)
train_dataloader = DataLoader(train_dataset, batch_size=8, shuffle=True)
test_dataloader = DataLoader(test_dataset, batch_size=8, shuffle=False)

# Define the model
model = BertForSequenceClassification.from_pretrained("bert-base-uncased", num_labels=len(label_map))
optimizer = AdamW(model.parameters(), lr=2e-5)

# Training function
def train(model, dataloader, optimizer, epochs=3):
    model.train()
    for epoch in range(epochs):
        total_loss = 0
        for batch in dataloader:
            optimizer.zero_grad()
            input_ids = batch['input_ids']
            labels = batch['labels']
            outputs = model(inputs_embeds=input_ids, labels=labels)
            loss = outputs.loss
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        print(f"Epoch {epoch + 1}, Loss: {total_loss / len(dataloader)}")

# Start training
train(model, train_dataloader, optimizer)

# Evaluate
def evaluate(model, dataloader):
    model.eval()
    correct = 0
    with torch.no_grad():
        for batch in dataloader:
            input_ids = batch['input_ids']
            labels = batch['labels']
            outputs = model(inputs_embeds=input_ids)
            predictions = torch.argmax(outputs.logits, dim=-1)
            correct += (predictions == labels).sum().item()
    accuracy = correct / len(dataloader.dataset)
    print(f"Accuracy: {accuracy:.4f}")

evaluate(model, test_dataloader)
