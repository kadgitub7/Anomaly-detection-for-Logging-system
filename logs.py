import random
import json
from datetime import datetime
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS 

app = Flask(__name__)
print(f"Checking for templates in: {app.template_folder}")
print(f"Checking for static files in: {app.static_folder}")
CORS(app)

def generateLog():
    wFile = open("logdata.jsonl","a")
    timeNow = datetime.now()
    error = random.randint(0,20) > 2
    if error:
        value = random.randint(0,300)
    else:
        value = random.randint(0,100)
    log = {
        "timestamp": timeNow.strftime("%H:%M:%S"),
        "value": value
    }
    wFile.write(json.dumps(log) + "\n")
    wFile.close()
    return jsonify(log)

@app.route('/newLog', methods=['POST'])
def run_function():
    result = generateLog()
    return result

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)