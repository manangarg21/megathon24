from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import pandas as pd
from tqdm import tqdm
import torch.nn.functional as F

# Set device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load model and tokenizer
tokenizer = AutoTokenizer.from_pretrained("cardiffnlp/twitter-roberta-base-sentiment-latest")
model = AutoModelForSequenceClassification.from_pretrained("cardiffnlp/twitter-roberta-base-sentiment-latest")
model.to(device)

# Load dataset
data = pd.read_csv('dataset.csv')  # Ensure 'dataset.csv' encoding is correct, e.g., encoding='latin1'

# Initialize counters
correct_predictions = 0
total_predictions = 0

# Iterate through the dataset
for index, row in tqdm(data.iterrows(), total=len(data)):
    text = row['User Input']  # Update with the correct column name for text
    true_label = row['Polarity']  # Update with the correct column name for label
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(device)
    with torch.no_grad():
        outputs = model(**inputs,output_hidden_states=True)
        last_hidden_state = outputs.hidden_states[-1]  # The last hidden state for embeddings
        logits = outputs.logits
    
    
    probs = F.softmax(logits, dim=1)
    confidence, predicted_class = torch.max(probs, dim=1)
    sentiment_label = model.config.id2label[predicted_class.item()]
    if sentiment_label == 'positive':
        sentiment_label = "Positive"
    elif sentiment_label == 'negative':
        sentiment_label = "Negative"
    else:
        sentiment_label = "Neutral"

    # Check if prediction is correct
    if sentiment_label == true_label:
        correct_predictions += 1
    total_predictions += 1

# Calculate accuracy
accuracy = correct_predictions / total_predictions
print(f'Accuracy: {accuracy * 100:.2f}%')
