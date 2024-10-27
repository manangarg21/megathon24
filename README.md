## Megathon Project
## Problem Statement from MindPeers
### Team Name : Confused Matrix

### This is the codebase for the NLP task given as the problem statement

### Codebase:

- **Polarity Detection Accuracy** : We are doing sentiment analysis using a pipeline model from HuggingFace (Twitter RoBERTa) to track the emotional shift over time.
- **Extractor** : We created an NER (Named Entity Recognition) that accurately measures and extracts the `concern` phrases from the input given by the user. We are using the LUKE transformer based on ROBERTa Model which gives very good predictions and accuracies.
- **Classifier and Intensity Score** : Created a pipeline system which takes inputs from the previous two layers (Polarity Detection and Extractor) and then based on the embeddings from these classifies into the labels and based on the probabilities provides them with an intensity score.
- **Timeline-Based Sentiment Analyzer** : Using a history section in the backend we calculate how the sentiments change over time for a person and track their progress.