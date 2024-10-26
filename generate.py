import pandas as pd
import os

# Directory where downloaded datasets are stored
data_dir = "./mental_health_datasets"
os.makedirs(data_dir, exist_ok=True)

# Define filenames for each dataset (assuming you've saved them with these names)
file_paths = {
    "sentiment140": f"{data_dir}/sentiment140.csv",
    "go_emotions": f"{data_dir}/go_emotions.csv",
    "smhd": f"{data_dir}/smhd.csv"
}

# Load datasets
sentiment140_df = pd.read_csv(file_paths["sentiment140"], encoding='ISO-8859-1')  # Example encoding
go_emotions_df = pd.read_csv(file_paths["go_emotions"])
smhd_df = pd.read_csv(file_paths["smhd"])

# Preprocessing datasets
# Map each dataset's columns to a common schema
def preprocess_sentiment140(df):
    df = df.rename(columns={
        "text": "Text",
        "target": "Polarity"  # Map to -1, 0, 1 or "negative", "neutral", "positive"
    })
    df["ids"] = None  # No category labels here
    df["date"] = None
    df["flag"] = None
    df["user"]=None
    return df[["Text", "Polarity", "ids", "date", "flag", "user"]]

def preprocess_go_emotions(df):
    df = df.rename(columns={
        "comment": "Text",
        "emotion": "Polarity"  # Needs to be mapped to negative/positive as needed
    })
    df["Category"] = None
    df["Intensity Score"] = None
    df["Timeline"] = None
    return df[["Text", "Polarity", "Category", "Intensity Score", "Timeline"]]

def preprocess_smhd(df):
    df = df.rename(columns={
        "text": "Text",
        "mental_health_issue": "Category"  # Assuming it has a mental health category column
    })
    df["Polarity"] = None  # Define based on available data or set to neutral
    df["Intensity Score"] = None
    df["Timeline"] = None
    return df[["Text", "Polarity", "Category", "Intensity Score", "Timeline"]]

# Apply preprocessing
sentiment140_df = preprocess_sentiment140(sentiment140_df)
go_emotions_df = preprocess_go_emotions(go_emotions_df)
smhd_df = preprocess_smhd(smhd_df)

# Concatenate all datasets
merged_df = pd.concat([sentiment140_df, go_emotions_df, smhd_df], ignore_index=True)

# Display merged DataFrame sample
print(merged_df.head())

# Save combined dataset to CSV
merged_df.to_csv(f"{data_dir}/combined_mental_health_dataset.csv", index=False)
print(f"Combined dataset saved to {data_dir}/combined_mental_health_dataset.csv")
