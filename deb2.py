from transformers import DebertaV2Tokenizer, AutoModelForSequenceClassification
from datasets import load_dataset
import torch
import pandas as pd
from sklearn.model_selection import train_test_split
from torch.utils.data import Dataset, DataLoader, TensorDataset
from torch.optim import AdamW
from transformers import get_scheduler
from tqdm.auto import tqdm
from transformers import AdamW, BertTokenizer, BertForSequenceClassification

data=pd.read_csv('dataset.csv')

tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
model = BertForSequenceClassification.from_pretrained("bert-base-uncased", num_labels=3)

train_texts, test_texts, train_labels, test_labels = train_test_split(data['User Input'], data['Polarity'], test_size=0.3,shuffle=False)
# Split the training data into training and validation sets
test_texts, val_texts, test_labels, val_labels = train_test_split(test_texts, test_labels, test_size=0.5,shuffle=False)
# Tokenize validation texts
val_texts_encodings = tokenizer(val_texts.tolist(), padding="max_length", truncation=True, max_length=512, return_tensors="pt", return_attention_mask=True)

# Map validation labels to integers

# Create validation dataset

# Validation DataLoader
def preprocess_text(text):
    return text.lower().strip()

# Apply preprocessing
train_texts = train_texts.apply(preprocess_text)
test_texts = test_texts.apply(preprocess_text)

train_texts_encodings = tokenizer(train_texts.tolist() ,padding="max_length", truncation=True, max_length=512, return_tensors="pt",return_attention_mask=True)
test_texts_encodings = tokenizer(test_texts.tolist(), padding="max_length", truncation=True, max_length=512, return_tensors="pt",return_attention_mask=True)
# Map labels to integers
label_map = {"Positive": 0, "Negative": 1, "Neutral": 2}
train_labels = torch.tensor(train_labels.map(label_map).tolist())
test_labels = torch.tensor(test_labels.map(label_map).tolist())
val_labels = torch.tensor(val_labels.map(label_map).tolist())
# %%
train_dataset = TensorDataset(train_texts_encodings["input_ids"],train_texts_encodings['attention_mask'] ,train_labels)
test_dataset = TensorDataset(test_texts_encodings["input_ids"],test_texts_encodings['attention_mask'], test_labels)
val_dataset = TensorDataset(val_texts_encodings["input_ids"], val_texts_encodings['attention_mask'], val_labels)

# DataLoaders
batch_size = 8
train_dataloader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
test_dataloader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
val_dataloader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)

# %%
from transformers import AdamW
import torch
from tqdm import tqdm

def train_model(model, train_dataloader, val_dataloader, num_epochs=7, learning_rate=2e-5, accumulation_steps=4, patience=1):
    model.train()
    optimizer = AdamW(model.parameters(), lr=learning_rate)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)

    best_val_loss = float('inf')
    patience_counter = 0

    for epoch in range(num_epochs):
        print(f"Epoch {epoch + 1}/{num_epochs}")
        epoch_loss = 0
        progress_bar = tqdm(train_dataloader, desc="Training")

        optimizer.zero_grad()  # Reset gradients at the beginning of each epoch
        for step, batch in enumerate(progress_bar):
            input_ids, attention, labels = batch
            input_ids = input_ids.to(device)
            labels = labels.to(device)
            attention = attention.to(device)

            # Forward pass
            outputs = model(input_ids=input_ids, attention_mask=attention, labels=labels)
            loss = outputs.loss
            epoch_loss += loss.item()

            # Backward pass
            loss.backward()
            if (step + 1) % accumulation_steps == 0:
                optimizer.step()
                optimizer.zero_grad()  # Reset gradients after updating

        # Average epoch training loss
        avg_epoch_loss = epoch_loss / len(train_dataloader)
        print(f"Average Epoch Training Loss: {avg_epoch_loss:.4f}")

        # Validation loop
        model.eval()
        val_loss = 0
        with torch.no_grad():
            for val_batch in val_dataloader:
                val_input_ids, val_attention, val_labels = val_batch
                val_input_ids = val_input_ids.to(device)
                val_attention = val_attention.to(device)
                val_labels = val_labels.to(device)

                # Forward pass for validation
                val_outputs = model(input_ids=val_input_ids, attention_mask=val_attention, labels=val_labels)
                val_loss += val_outputs.loss.item()

        avg_val_loss = val_loss / len(val_dataloader)
        print(f"Validation Loss: {avg_val_loss:.4f}")

        # Early stopping
        if avg_val_loss < best_val_loss:
            best_val_loss = avg_val_loss
            patience_counter = 0
        else:
            patience_counter += 1

        if patience_counter >= patience:
            print("Early stopping triggered")
            break

        model.train()  # Return to training mode

    print("Training completed.")

train_model(model, train_dataloader,val_dataloader, num_epochs=8, learning_rate=2e-5, accumulation_steps=4)

# %%

def evaluate_model(model, test_dataloader):
    model.eval()  # Set the model to evaluation mode
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    
    print("Evaluating the model")
    correct_predictions = 0
    total_predictions = 0
    
    with torch.no_grad():  # Disable gradient calculation
        for batch in tqdm(test_dataloader, desc="Evaluating"):
            input_ids,attention, labels = batch
            input_ids = input_ids.to(device)
            labels = labels.to(device)
            attention=attention.to(device)
            # print(labels.shape)
            # print(input_ids.shape)
            # Forward pass
            outputs = model(input_ids=input_ids,attention_mask=attention)
            predictions = torch.argmax(outputs.logits, dim=-1)  # Get predicted class labels
            # Calculate the number of correct predictions
            # Create a DataFrame of input sentence, prediction, and actual label
            correct_predictions += (predictions == labels).sum().item()
            total_predictions += labels.size(0)
    
    accuracy = correct_predictions / total_predictions  # Calculate accuracy
    print(f"Accuracy on the test set: {accuracy:.4f}")

# Call the evaluation function
evaluate_model(model, test_dataloader)