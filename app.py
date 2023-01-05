# How to call the Predict Functon below to make online predictions from Terminal / Command line
"""
Step 1 :Run the app.py  through the command on CML terminal 
gunicorn --bind 127.0.0.1:8090 app:app

Step 2: Open another terminal and run  
curl -X POST   -H "accept: application/json" -H "Content-Type: application/json" -d "{\"petal_length\":2.0  }" http://127.0.0.1:8090/predict

Expected Output is
{"petal_length":2.0,"petal_width":0.467264135120556}

"""


from flask import Flask, jsonify, g, request
import os
import predict as pr

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello, this is a Sample App that Predicts Petal width given the petal length!"


@app.route(
    "/predict",
    methods=["POST"],
)
def predict():
    """
    The main predict endpoint.
    """
    request_json = request.get_json()
    length = request_json["petal_length"]


    # Get the prediction.
    # Note: You can add additional logic here as well, e.g. database look up, etc.
    prediction = pr.predict(request_json)
    return jsonify(
            {
                "petal_length": length,
                "petal_width": prediction
            }
          )
  
  
    
if __name__ == "__main__":
    host_ip = os.environ["APP_IP_ADDRESS"]
    # In CML the 0.0.0.0 address is already taken but in docker containers we need this address below
    # so make sure that APP_IP_ADDRESS environment variable is set in CML project
    if host_ip is None :
      host_ip = "0.0.0.0" 
    app.run(host=host_ip, port=int(os.environ["CDSW_APP_PORT"]))
    