# Anomaly-detection-for-Logging-system
This is a project aimed at developing a pipelined system of log data collection and organizing the data through Unix commands to then a HDFS system that shovels the data for ML anomaly detection.

Example Tableau Visualization of the log data presented here: https://public.tableau.com/app/profile/kadhir.ponnambalam/viz/Log_DataVisualization/Sheet1

Required Downloads:
- MySQL
- Docker Desktop
- Python

Look into the following resources for download instructions:
- https://www.mysql.com/downloads/
- https://docs.docker.com/desktop/setup/install/windows-install/
- https://www.python.org/downloads/

For setup and running of the program:
Follow the video demo here: https://www.youtube.com/watch?v=TJmfjUQGjUo

[1] Run the Python backend server logs.py
[2] Open the frontend on the server side and click to make new logs
[3] Once an adequate amount of logs have been made(greater that 20 at least) run the Unix/Bash Scripts 1 at a time
[4] Follow this order: rotation -> compression -> ship -> ingest_to_hdfs
[5] Verfify if the data has been added to your docker container
[6] Check the SQL database to see if the data has been transfered from the container
[7] On the frontend, click the button to detect the anomalies in the data
