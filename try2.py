import google.generativeai as genai
KEY = 'AIzaSyAkqAHBLuhCQmioY40Zoo8RHEMc5lpvl0I'
genai.configure(api_key=KEY)
from transformers import AutoTokenizer, AutoModel
import torch
from transformers import pipeline
from transformers import LukeForTokenClassification, LukeTokenizer
label2id = {"O": 0, "CONCERN": 1}
save_directory = "./saved_model_luke"
model = LukeForTokenClassification.from_pretrained(save_directory)
tokenizer = LukeTokenizer.from_pretrained(save_directory)
def predict_concerns_api(text, tokenizer, model, label2id):
    tokens = tokenizer(text, return_tensors="pt", padding=True, truncation=True)
    input_ids = tokens["input_ids"]
    attention_mask = tokens["attention_mask"]
    with torch.no_grad():
        outputs = model(input_ids=input_ids, attention_mask=attention_mask,output_hidden_states=True)
        logits = outputs.logits
    
    predictions = torch.argmax(logits, dim=-1).squeeze().tolist()
    id2label = {v: k for k, v in label2id.items()}
    predicted_labels = [id2label[label_id] for label_id in predictions]
    tokens = tokenizer.convert_ids_to_tokens(input_ids.squeeze())
    results = []
    for token, label in zip(tokens, predicted_labels):
        if label != "O":
            results.append(token[1:])
            print(f"{token}: {label}")
    return results
def fetch_API_response(input_data,history,entities,sentiment):
    
    """Used to generate a response using the Gemini API.
    @params
    input_data: The input data to be used for generating the response.
    history: The history of the conversation.
    flag: The flag to check if the context is to be used or not. Used to exclude context generation for topic summary.
    Returns:
        _type_: str
    """
    
    generation_config = {
    "temperature": 0.9,
    "top_p": 1,
    "top_k": 1,
    "max_output_tokens": 2048,
        }

    safety_settings = [
    {
        "category": "HARM_CATEGORY_HARASSMENT",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    ]
    model = genai.GenerativeModel(model_name="gemini-1.5-pro",
                                generation_config=generation_config,
                                safety_settings=safety_settings)
    try:
        prompt = f'''You are a chatbot trained to categorize and rate mental health-related concerns based on user statements. Classify the statement into each of the following categories and provide an intensity score from 1 to 10 for each category. Do not include any additional explanations or text beyond the specified output format.

        Categories:
        - Health Anxiety, Anxiety, Insomnia, Depression, Stress, Career Confusion, Positive Outlook, Eating Disorder, Phobia, Relationship Issues, Loneliness, Trauma

        Context:
        1. Input sequence: "{input_data}"
        2. Identified concerning words (named entity recognition): {entities}
        3. Overall sentiment: "{sentiment}"

        **Output format (strictly follow this format without additional text):**
        Maximum Category and corresponding Intensity Score

        Example Output:
        Stress 7

        Remember, only list the category and score without extra comments or reasoning.'''
    
        input_data=prompt
        convo = model.start_chat(history=history)
        response = convo.send_message(input_data)
        return (response.text)
    except Exception as e:
        print(e)

        return ("This is a default response which happens only when Gemini is down or inappropriate prompts or there is an error in internet connection\n")

from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

uri = "mongodb+srv://kushagradhingra:hello@cluster.yrtp0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster"
client = MongoClient(uri, server_api=ServerApi('1'))
try:
    client.admin.command('ping')
except Exception as e:
    print(e)
db_name = "test"
db = client[db_name]
collection_name = "journal_entries"
collection = db[collection_name]
history=[]
users=db["users"]
email=input("Enter the email: ")
col=users.find_one({"email":email})
password=input("Enter the password: ")
if col["password"]!=password:
    print("Invalid Password")
    exit()

for i in collection.find({"userId":str(col["_id"])}):
    if "question" in i and "response" in i:
        history.append({"role": "user", "parts": i["question"] + " " + i["response"]})
    if "journal" in i:
        history.append({"role": "user", "parts": i["journal"]})
text=input("Enter the text: ")
sentiment_analysis = pipeline('sentiment-analysis', model="cardiffnlp/twitter-roberta-base-sentiment-latest")
sentiment=sentiment_analysis(text)[0]['label']
response=fetch_API_response(text,history,predict_concerns_api(text,tokenizer,model,label2id),sentiment)
list=response.split(" ")
if len(list)<=3 and len(list)>=2:
    print(list[0],list[1])
else:
    print("Phobia 10")
