import pandas as pd
from transformers import LukeTokenizer, LukeForTokenClassification, Trainer, TrainingArguments
from datasets import Dataset
import torch
from torch.utils.data import DataLoader
from transformers import get_linear_schedule_with_warmup, AdamW
from tqdm import tqdm 

file_path = './dataset.csv'
dataset = pd.read_csv(file_path)

subset_df = dataset.sample(frac=0.01, random_state=42)
subset_df.reset_index(drop=True, inplace=True)

label2id = {"O": 0, "B-MENTAL_HEALTH_CONCERN": 1, "I-MENTAL_HEALTH_CONCERN": 2}

def tag_ner_labels(row):
    text = row['User Input']
    concern = row['Extracted Concern']
    text_words = text.split()
    concern_words = concern.split()
    labels = []
    i = 0
    while i < len(text_words):
        if text_words[i:i+len(concern_words)] == concern_words:
            labels.extend(['B-MENTAL_HEALTH_CONCERN'] + ['I-MENTAL_HEALTH_CONCERN'] * (len(concern_words) - 1))
            i += len(concern_words)
        else:
            labels.append('O')
            i += 1
    return {'tokens': text_words, 'ner_tags': labels}

ner_data = subset_df.apply(tag_ner_labels, axis=1)
formatted_data = pd.DataFrame(ner_data.tolist())

hf_dataset = Dataset.from_pandas(formatted_data)

tokenizer = LukeTokenizer.from_pretrained("studio-ousia/luke-base")
model = LukeForTokenClassification.from_pretrained("studio-ousia/luke-base", num_labels=3)

def tokenize_and_align_labels(examples):
    sentences = [" ".join(tokens) for tokens in examples["tokens"]]
    tokenized_inputs = tokenizer(sentences, padding="max_length", truncation=True)
    labels = [[label2id[label] for label in example_labels] for example_labels in examples["ner_tags"]]
    aligned_labels = []
    for label_seq in labels:
        padded_labels = label_seq + [-100] * (len(tokenized_inputs["input_ids"][0]) - len(label_seq))
        aligned_labels.append(padded_labels)
    tokenized_inputs["labels"] = aligned_labels
    return tokenized_inputs

tokenized_dataset = hf_dataset.map(tokenize_and_align_labels, batched=True)

batch_size = 4  # Adjust this based on your memory capacity
train_dataloader = DataLoader(tokenized_dataset, batch_size=batch_size, shuffle=True)
optimizer = AdamW(model.parameters(), lr=3e-5)
epochs = 5

def train(model, train_dataloader, optimizer, epochs=3):
    model.train()
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    
    for epoch in range(epochs):
        print(f"Epoch {epoch + 1}/{epochs}")
        epoch_loss = 0
        
        for batch in tqdm(train_dataloader):
            # Move batch to device
            input_ids = batch['input_ids'].to(device)
            attention_mask = batch['attention_mask'].to(device)
            labels = batch['labels'].to(device)
            
            # Zero gradients before each step
            optimizer.zero_grad()
            
            # Forward pass
            outputs = model(input_ids, attention_mask=attention_mask, labels=labels)
            loss = outputs.loss
            epoch_loss += loss.item()
            
            # Backward pass and optimization step
            loss.backward()
            optimizer.step()
            # scheduler.step()
        
        avg_loss = epoch_loss / len(train_dataloader)
        print(f"Average loss for Epoch {epoch + 1}: {avg_loss:.4f}")

# Start training
train(model, train_dataloader, optimizer)
exit()
def extract_concerns(text):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    inputs = tokenizer(text, return_tensors="pt").to(device)
    outputs = model(**inputs)
    predictions = outputs.logits.argmax(dim=2)
    tokens = tokenizer.convert_ids_to_tokens(inputs['input_ids'][0])
    print("Tokens and Labels:")
    for token, label in zip(tokens, predictions[0]):
        print(f"Token: {token}, Label ID: {label}")
    concern_phrase = []
    for token, label in zip(tokens, predictions[0]):
        if token in ["<s>", "</s>", "[PAD]"]:
            continue
        if label == 1 or label == 2:
            concern_phrase.append(token.replace("##", ""))
        elif concern_phrase:
            break
    return " ".join(concern_phrase)

text = "I’ve been feeling very anxious and stressed lately."
extracted_concern = extract_concerns(text)
print("Extracted Concern:", extracted_concern)
