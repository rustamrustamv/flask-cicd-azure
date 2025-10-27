# app.py
from flask import Flask
import os

app = Flask(__name__)

# Get a "GREETING" variable from the environment, default to "World"
greeting = os.environ.get("GREETING", "World")

@app.route('/')
def hello():
    # Return a personalized greeting
    return f"Hello, {greeting}!"

if __name__ == '__main__':
    # Run the app on port 8000, accessible from any IP
    app.run(host='0.0.0.0', port=8000)