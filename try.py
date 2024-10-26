import spacy
from spacy.training import Example

# Load the pre-trained English model
nlp = spacy.load("en_core_web_sm")

# Define training data based on your sample
training_data = [
    ("I am constantly worried these days.", {"entities": [(9, 26, "MENTAL_HEALTH_CONCERN")]}),  # "constantly worried"
    ("I’m trying, but I’m still constantly worried.", {"entities": [(30, 47, "MENTAL_HEALTH_CONCERN")]}),  # "constantly worried"
    ("I am worried about health these days.", {"entities": [(7, 13, "MENTAL_HEALTH_CONCERN")]}),  # "worried"
    ("Every day I’m happy and excited.", {"entities": [(20, 25, "MENTAL_HEALTH_CONCERN")]}),  # "happy"
]

# Create a blank model if you want to create a new one, or use an existing one
ner = nlp.get_pipe("ner")

# Add the new label to the NER model
ner.add_label("MENTAL_HEALTH_CONCERN")

# Disable other pipes for training
with nlp.select_pipes(disable=["tagger", "parser"]):
    # Start training
    optimizer = nlp.begin_training()
    for epoch in range(10):  # Adjust the number of epochs as needed
        for text, annotations in training_data:
            example = Example.from_dict(nlp.make_doc(text), annotations)
            nlp.update([example], drop=0.5, losses={})

# Save the trained model
nlp.to_disk("mental_health_ner_model")

# Load the trained model
nlp_ner = spacy.load("mental_health_ner_model")

# Test the trained model with new input data
test_text = (
    "I am feeling really anxious these days, and I am happy about my progress."
)
doc = nlp_ner(test_text)

# Print the recognized entities
print("Extracted Entities:")
for ent in doc.ents:
    print(f"{ent.text}: {ent.label_}")
