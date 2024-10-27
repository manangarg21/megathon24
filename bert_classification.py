import torch
import pickle
from torch.utils.data import Dataset, DataLoader
from transformers import BertForSequenceClassification, AdamW
from sklearn.model_selection import train_test_split
import pandas as pd
import torch.nn.functional as F
from tqdm import tqdm

# Load the NER embeddings
with open('ner_embeddings.pkl', 'rb') as ner_file:
    ner_embeddings = pickle.load(ner_file)

# Set the target length to the maximum sequence length (19)
target_length = 19
embedding_dim = len(ner_embeddings[0][0][0])  # Get the embedding dimension from the first sequence

# Process embeddings with uniform padding
processed_embeddings = []
for batch in ner_embeddings:
    # Process each sequence in the batch
    batch_sequences = []
    for seq in batch:
        # Convert to tensor if not already
        seq_tensor = torch.tensor(seq) if not isinstance(seq, torch.Tensor) else seq
        
        # Get current sequence length
        curr_length = seq_tensor.size(0)
        
        # Pad sequence to target length
        if curr_length < target_length:
            # Create padding
            padding = torch.zeros((target_length - curr_length, embedding_dim))
            padded_seq = torch.cat([seq_tensor, padding], dim=0)
        else:
            # Truncate if longer than target length
            padded_seq = seq_tensor[:target_length]
            
        batch_sequences.append(padded_seq)
    
    # Stack sequences in the batch
    try:
        batch_tensor = torch.stack(batch_sequences)
        processed_embeddings.append(batch_tensor)
    except RuntimeError as e:
        print(f"Error in batch: {e}")
        continue

# Concatenate all batches
all_embeddings = torch.cat(processed_embeddings, dim=0)

# Load category labels
data = pd.read_csv('dataset.csv').head(70)  # Adjust this number to match your total samples

# Create label mappings and convert to tensor
categories = data['Category']
label_map = {label: idx for idx, label in enumerate(categories.unique())}
labels = torch.tensor([label_map[label] for label in categories])

# Verify dimensions match
print(f"Embeddings shape: {all_embeddings.shape}")
print(f"Labels shape: {labels.shape}")
print(f"Number of unique labels: {len(label_map)}")

# Dataset class
class CombinedDataset(Dataset):
    def __init__(self, embeddings, labels):
        self.embeddings = embeddings
        self.labels = labels
        assert len(embeddings) == len(labels), f"Embeddings ({len(embeddings)}) and labels ({len(labels)}) must have same length"

    def __len__(self):
        return len(self.labels)

    def __getitem__(self, idx):
        return {
            'input_ids': self.embeddings[idx],
            'labels': self.labels[idx]
        }

# Train-test split
train_embeddings, test_embeddings, train_labels, test_labels = train_test_split(
    all_embeddings, labels, test_size=0.3, random_state=42)

# Create datasets and dataloaders
train_dataset = CombinedDataset(train_embeddings, train_labels)
test_dataset = CombinedDataset(test_embeddings, test_labels)

# Create dataloaders
batch_size = 8
train_dataloader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, drop_last=False)
test_dataloader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False, drop_last=False)

# Define the model with correct input size
model = BertForSequenceClassification.from_pretrained(
    "bert-base-uncased", 
    num_labels=len(label_map),
    hidden_size=embedding_dim  # Use the original embedding dimension
)

optimizer = AdamW(model.parameters(), lr=2e-5)

# Training function
def train(model, dataloader, optimizer, epochs=3):
    model.train()
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    model.to(device)
    
    for epoch in tqdm(range(epochs)):
        total_loss = 0
        num_batches = 0
        
        for batch in dataloader:
            try:
                optimizer.zero_grad()
                input_ids = batch['input_ids'].to(device)
                labels = batch['labels'].to(device)
                
                outputs = model(inputs_embeds=input_ids, labels=labels)
                loss = outputs.loss
                loss.backward()
                optimizer.step()
                
                total_loss += loss.item()
                num_batches += 1
                
            except RuntimeError as e:
                print(f"Error in batch during training: {e}")
                continue
        
        avg_loss = total_loss / num_batches if num_batches > 0 else float('inf')
        print(f"Epoch {epoch + 1}, Average Loss: {avg_loss:.4f}")

# Evaluation function
def evaluate_with_confidence(model, dataloader):
    model.eval()
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    model.to(device)
    
    correct = 0
    total = 0
    results = []
    
    with torch.no_grad():
        for batch in dataloader:
            try:
                input_ids = batch['input_ids'].to(device)
                labels = batch['labels'].to(device)
                
                outputs = model(inputs_embeds=input_ids)
                logits = outputs.logits
                predictions = torch.argmax(logits, dim=-1)
                
                # Calculate confidence scores
                probabilities = F.softmax(logits, dim=-1)
                confidence_scores = torch.max(probabilities, dim=-1).values
                scaled_confidences = (confidence_scores * 9 + 1).int()
                
                # Update accuracy metrics
                correct += (predictions == labels).sum().item()
                total += labels.size(0)
                
                # Collect results
                for pred, conf, true_label in zip(predictions, scaled_confidences, labels):
                    results.append({
                        'predicted': pred.item(),
                        'confidence': conf.item(),
                        'true_label': true_label.item()
                    })
                    
            except RuntimeError as e:
                print(f"Error in batch during evaluation: {e}")
                continue
    
    accuracy = correct / total if total > 0 else 0
    print(f"\nEvaluation Results:")
    print(f"Accuracy: {accuracy:.4f}")
    print(f"Total samples evaluated: {total}")
    
    # Print sample results
    print("\nSample predictions (first 5):")
    for i, result in enumerate(results):
        print(f"Sample {i+1}:")
        print(f"  Predicted class: {result['predicted']}")
        print(f"  Confidence: {result['confidence']}/10")
        print(f"  True label: {result['true_label']}")

# Print model configuration
print("\nModel Configuration:")
print(f"Number of labels: {len(label_map)}")
print(f"Embedding dimension: {embedding_dim}")
print(f"Sequence length: {target_length}")

# Training and evaluation
print("\nStarting training...")
train(model, train_dataloader, optimizer)

print("\nEvaluating model...")
evaluate_with_confidence(model, test_dataloader)