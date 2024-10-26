import pandas as pd
import numpy as np
from transformers import pipeline
from datetime import timedelta
import random


# Initialize sentiment analysis pipeline
sentiment_analyzer = pipeline("sentiment-analysis")
classifier = pipeline(
    "sentiment-analysis",
    model="distilbert-base-uncased-finetuned-sst-2-english",
    device=0  # Change to `device=0` for GPU or `device=-1` for CPU
)
# Set up synthetic data columns
data_columns = ["day", "text", "polarity", "concerns", "category", "intensity_score", "timeline_shift"]

# Helper function for intensity scoring
INTENSITY_WORDS = {"slightly": 3, "somewhat": 5, "very": 7, "extremely": 10}
def get_intensity_score(text: str) -> int:
    for word, score in INTENSITY_WORDS.items():
        if word in text.lower():
            return score
    return random.randint(1, 10)  # Random score for neutral cases

# Helper function for sentiment analysis
def get_sentiment(text: str) -> str:
    result = sentiment_analyzer(text)[0]
    return result['label'], result['score']

# Load datasets (assuming they are in CSV format; replace with paths to your datasets)
# Replace with paths if you have saved the datasets locally.
reddit_mental_health = pd.DataFrame({
    "text": ["I'm feeling very anxious today", "I can't sleep well and feel very low", "I'm extremely stressed"],
    "category": ["Anxiety", "Insomnia", "Stress"]
})
goemotions = pd.DataFrame({
    "text": ["Feeling so sad today", "I'm filled with joy", "I'm terrified of tomorrow"],
    "category": ["Sadness", "Joy", "Fear"]
})
semeval = pd.DataFrame({
    "text": ["Feeling a bit better", "I'm feeling worse every day", "I feel happy today"],
    "intensity_score": [4, 8, 3]
})

# Combine datasets
datasets = [reddit_mental_health, goemotions, semeval]
combined_data = pd.concat(datasets, ignore_index=True)

# Generate synthetic data
synthetic_data = []

start_date = pd.Timestamp("2024-01-01")
for i, row in combined_data.iterrows():
    day_offset = random.randint(0, 30)  # Generate entries over a 30-day period
    text = row['text']
    category = row.get('category', 'General')
    
    # Polarity and sentiment analysis
    polarity, polarity_score = get_sentiment(text)
    
    # Generate synthetic concerns and intensity score
    concerns = [text]
    intensity_score = row.get("intensity_score", get_intensity_score(text))
    
    # Simulate timeline shifts by assigning random changes in polarity
    timeline_shift = random.choice(["No change", "Improvement", "Deterioration"])
    
    # Build synthetic entry
    synthetic_entry = {
        "day": start_date + timedelta(days=day_offset),
        "text": text,
        "polarity": {"label": polarity, "score": polarity_score},
        "concerns": concerns,
        "category": category,
        "intensity_score": intensity_score,
        "timeline_shift": timeline_shift
    }
    synthetic_data.append(synthetic_entry)

# Convert to DataFrame
synthetic_df = pd.DataFrame(synthetic_data, columns=data_columns)

# Save to CSV for review or future use
synthetic_df.to_csv("synthetic_mental_health_data.csv", index=False)

print("Generated Synthetic Data:\n", synthetic_df.head())
