
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
    app.run(host="127.0.0.1", port=int(os.environ["CDSW_APP_PORT"]))
    