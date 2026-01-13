import random
import json
from datetime import datetime
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import mysql.connector 
import pandas as pd
from matplotlib import pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression

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

def getLogs():
    con = mysql.connector.connect(
        host='localhost',
        user='root',
        password='password',
        database='testdb'
    )
    cursor = con.cursor()
    cursor.execute("SELECT * FROM log_data")
    logs = cursor.fetchall()
    cursor.close()
    con.close()

    timeCreated = [row[0] for row in logs]
    values = [row[1] for row in logs]
    timeIngested = [row[2] for row in logs]

    return timeCreated, values, timeIngested

@app.route('/processLogs',methods=['POST'])
def processLogs():
    timeCreated, values, timeIngested = getLogs()

    df =pd.read_csv("trainingData.csv")
    df.head()

    score = 0
    for _ in range(5):
        X_train, X_test, y_train, y_test = train_test_split(df[['value']],df.is_anomaly,test_size=0.3)
        model = LogisticRegression()

        model.fit(X_train,y_train)

        model.predict(X_test)
        score = model.score(X_test,y_test)
        if score > 0.8:
            break
    values_df = pd.DataFrame(values, columns=['value'])
    anomalyDetection = model.predict(values_df)
    anomalies = []
    for i in range(len(anomalyDetection)):
        if anomalyDetection[i] == 1:
            json_string = {
                'timestamp': timeCreated[i],
                'value': values[i],
                'ingested_at': timeIngested[i].isoformat()
            }
            anomalies.append(json_string)
    return jsonify(anomalies)

@app.route('/newLog', methods=['POST'])
def run_function():
    result = generateLog()
    return result

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':

    app.run(debug=True)
