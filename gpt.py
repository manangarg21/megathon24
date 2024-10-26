import spacy
from transformers import pipeline, AutoModelForSequenceClassification, AutoTokenizer
import numpy as np
from typing import List, Dict

# Load Spacy model for NER
nlp = spacy.load("en_core_web_sm")

# Load Hugging Face pipeline for sentiment analysis
sentiment_analyzer = pipeline("sentiment-analysis")

def polarity_finder(text: str) -> str:
    """Detects the sentiment polarity of a given text."""
    result = sentiment_analyzer(text)[0]
    return {"label": result['label'], "score": result['score']}

# Example usage
polarity = polarity_finder("I'm feeling very anxious today.")
print("Polarity:", polarity)


def keyword_extractor(text: str) -> List[str]:
    """Extracts mental health-related phrases using NER."""
    doc = nlp(text)
    keywords = [ent.text for ent in doc.ents if ent.label_ in ["PERSON", "ORG", "GPE", "SYMPTOM"]]
    return keywords

# Example usage
keywords = keyword_extractor("I've been feeling very anxious lately.")
print("Extracted Keywords:", keywords)

# Mock concern mapping
CONCERN_MAPPING = {
    "anxious": "Anxiety",
    "depressed": "Depression",
    "stress": "Stress",
    "sleep": "Insomnia",
    "eating": "Eating Disorder"
}

def concern_classifier(keywords: List[str]) -> List[Dict[str, str]]:
    """Classifies extracted concerns into predefined categories."""
    classified_concerns = []
    for keyword in keywords:
        for word, category in CONCERN_MAPPING.items():
            if word in keyword.lower():
                classified_concerns.append({"concern": keyword, "category": category})
    return classified_concerns

# Example usage
classified_concerns = concern_classifier(keywords)
print("Classified Concerns:", classified_concerns)


INTENSITY_SCORES = {"slightly": 3, "very": 7, "extremely": 10}

def intensity_scorer(text: str) -> int:
    """Estimates an intensity score based on modifiers in text."""
    score = 5  # Default mid-range score
    for word, value in INTENSITY_SCORES.items():
        if word in text.lower():
            score = value
    return score

# Example usage
intensity = intensity_scorer("I feel extremely anxious")
print("Intensity Score:", intensity)

def timeline_analysis(entries: List[Dict[str, str]]) -> List[Dict[str, str]]:
    """Tracks changes in sentiment and categories over time."""
    timeline = []
    previous_sentiment = None

    for entry in entries:
        polarity = polarity_finder(entry["text"])
        keywords = keyword_extractor(entry["text"])
        classified = concern_classifier(keywords)
        intensity_scores = [intensity_scorer(kw["concern"]) for kw in classified]
        
        # Check for sentiment shift
        shift = "No change"
        if previous_sentiment and polarity['label'] != previous_sentiment:
            shift = "Improvement" if polarity['label'] == "POSITIVE" else "Deterioration"
        
        timeline.append({
            "day": entry["day"],
            "polarity": polarity,
            "concerns": classified,
            "intensity_scores": intensity_scores,
            "shift": shift
        })
        previous_sentiment = polarity['label']
    
    return timeline

# Example usage
entries = [
    {"day": 1, "text": "I can’t sleep well and I feel very low."},
    {"day": 7, "text": "I feel a bit better but still anxious."}
]

timeline = timeline_analysis(entries)
print("Timeline Analysis:", timeline)
