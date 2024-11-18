from flask import Flask, request, jsonify
from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate


app = Flask(__name__)

# Define the template and model
template = """
Answer the question below.

Here is the conversation history: {context}
Question: {question}
"""
model = OllamaLLM(model="llama3.1")
prompt_template = ChatPromptTemplate.from_template(template)
chain = prompt_template | model

# In-memory storage for context (you could also use a database for this in a production setting)
conversation_history = {}

@app.route('/chat', methods=['POST'])
def chat():
    # Get user input and session id from the request
    data = request.json
    user_input = data.get("question", "")
    session_id = data.get("session_id", "default")

    # Get or initialize the conversation context for this session
    context = conversation_history.get(session_id, "")

    # Call the LLM chain to get the response
    result = chain.invoke({"context": context, "question": user_input})

    # Append the conversation to the context
    conversation_history[session_id] = f"{context}\nUser: {user_input}\nAI: {result}"

    return jsonify({"response": result})

if __name__ == "__main__":
    app.run(debug=True)