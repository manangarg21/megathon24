import google.generativeai as genai
KEY = 'AIzaSyBhYCnouAgwJWL6NkafdXM6c7dzAMWWRX8'
genai.configure(api_key=KEY)

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
        prompt=f'''You are a chatbot created to help classify the person according to their chats in the following categories of mental health issues ( the categories are Health Anxiety,Anxiety,Insomnia,Depression,Stress,Career Confusion,Positive Outlook,Eating Disorder)and give them intesity score from 1 to 10 for each category .Also for each word this is the input sequence of words {input_data} and through our named entity recognition we have identified the following entities {entities} as the concerning words , we find the overall sentiment of this input to be {sentiment}. Only give it as Category score in different line nothing else'''
        input_data=prompt
        convo = model.start_chat(history=history)
        response = convo.send_message(input_data)
        return (response.text)
    except Exception as e:
        print(e)

        return ("This is a default response which happens only when Gemini is down or inappropriate prompts or there is an error in internet connection\n")
print(fetch_API_response("Things have been tough, I keep not eating properly.",[],['not','eating','properly'],"Negative"))