# ~/testing-Project/app/app.py

from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    # Show the hostname (pod name) to demonstrate load balancing
    hostname = os.uname()[1]
    return f"Hello, Cloud Network Engineer! I'm running on Pod: {hostname}\n"

if __name__ == "__main__":
    # Listen on all interfaces
    app.run(host='0.0.0.0', port=8080)