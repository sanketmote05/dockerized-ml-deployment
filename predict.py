# Read the fitted model from the file model.pkl
# and define a function that uses the model to
# predict petal width from petal length

"""
Way to test this model is as follows
import predict as pr
print(f'Petal Length: {test_data["petal_length"]} Predicted Petal Width : {predict.predict(test_data):0.3f}')

"""


import pickle

model = pickle.load(open('model.pkl', 'rb'))

def predict(args):
  petal_length = float(args.get('petal_length'))
  result = model.predict([[petal_length]])
  return result[0][0]
