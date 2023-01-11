# Getting Started with Hybrid Deployments of Models developed in CML 

This demo explains how we can deploy models developed in CML in an environment where there is no CML or CDSW Setup.<br>
For example: In a production environment installation. 

## Prerequistes
The target environment should have docker binaries installed. Since this demo deploys a docker image in the target environment as a container.

## Files

* `README.md` -- This project's readme in Markdown format.
* `requirements.txt` -- Dependencies that need to be installed.
* `cdsw-build.sh` -- A custom build script. This will pip install our dependencies, primarily the scikit-learn library.
* `fit.py` -- A model training example. Generates the model.pkl file that contains the fitted parameters of our model.
* `predict.py` --  A sample function to be deployed as a model. Uses `model.pkl` produced by `fit.py` to make predictions about petal width.
* `test-model.py` -- Simple test function that makes sure that our model works and provides a prediction given a payload
* `app.py` -- This is a small flask application to run our model 
* `model.pkl` -- our simple model that gives a petal width prediction based on the passed petal_length value as a dictionary
## SETUP 
*  Go to Project settings, click on advanced TAB and add the following <br>
environment variable 
`APP_IP_ADDRESS=127.0.0.1`

## Instructions for first building and testing the model 
1. Launch a new Workbench session.
2. delete the model.pkl file. 
3. Launch terminal and run the following to set the requirements package <br>
`sh cdsw-build.sh`
4. Once step3 is completed, execute the fit.py in the session by clicking on the Run button on the menu
5. This should build the model, verify you see a model.pkl file 
6. Next, in the same session run test-model.py file by clicking on the run.<br>
This ensures that our model has been indeed successully built and can be now hosted as an API end point
6. next we set up gunicorn as our webserver with the following command <br>
`gunicorn --bind 127.0.0.1:8090 app:app`
7. Validate that the model now can be invoked from the Command line terminal in CML by running the following command. <br>
`curl -X POST   -H "accept: application/json" -H "Content-Type: application/json" -d "{\"petal_length\":3.0  }" http://127.0.0.1:8090/predict`
8. You should see the output as follows, this means our model is able to now serve the prediction for the petal length of 3.0. 
`{"petal_length":3.0,"petal_width":0.8834665439726568}`

<br> 
At this point our Model is now ready for deployment . Follow the instructions in the README.md in the FOR_DEPLOYMENT_ONLY Folder. 

