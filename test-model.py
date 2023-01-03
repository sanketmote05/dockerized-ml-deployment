# This file simply tests if our model works and can provide an output
"""
Use this as a test before we deploy the model as an API end point
simply run this on command line as follows

python3 test-model.py

Expected output:
Petal Length: 2.0 Predicted Petal Width : 0.467

"""

import predict
test_data={"petal_length": 2.0}
print(f'Petal Length: {test_data["petal_length"]} Predicted Petal Width : {predict.predict(test_data):0.3f}')
