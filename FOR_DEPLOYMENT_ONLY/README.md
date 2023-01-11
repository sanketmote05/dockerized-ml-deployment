# Deployment in the Target Environment

## Prerequisites
- Ensure that Docker is running in the target environment using this command. This should list the docker installation information on the target environment <br>
`docker info` 
- Ensure that you have curl installed in the deployment system , if not asked your sysadmin to install curl application on this environment

## Files
Clone or copy the _FOR_DEPLOYMENT_ONLY files in a folder location in the target environment
* `README.md` -- This project's readme in Markdown format specific for the Deployment Environment
* `requirements.txt` -- Dependencies that need to be manually installed if you
  are running analysis.py in ML Runtimes (not necessary if you are using Legacy
  Engines).
* `cdsw-build.sh` -- A custom build script used for models and experiments. This
will pip install our dependencies, primarily the scikit-learn library.
* `predict.py` --  A sample function to be deployed as a model. Uses `model.pkl`
 to make predictions about petal width.
* `model.pkl` - Our prediction model that has been trained in CML earlier and will now be deployed in the target environment
* `app.py` - Flask application that creates the endpoints for our model 
* `DockerFile` - This will build our docker container and deploy the model 
* `KeyDockerCommands.txt` - Some docker commands that are used for deployment below are saved and modified in this file

## Deployment Process
Please follow the following steps to deployment : <br>
- Launch Terminal 
- cd <path>/<your folder where you copied files>
- ensure docker is accessible from this  location by typing 
  `docker ps` 
- Build the docker Image
`docker build --no-cache --progress=plain -t petal-width-prediction .`
- If it successfully built then remove any existing containers with the name above 
`docker rm CONTAINER petal-width-predictor`
- Now run the docker container. Please note that it is assumed that the IP address below and  port below in target machine is available  <br> 
  i.e.  0.0.0.0:8090 is available if not, you will need to change it to an IP address and port that is provided for you in the target machine by your administrator <br>
  DO NOT change the binding port of the container i.e. the second 8090 in the command below <br>
`docker run -it --name petal-width-predictor  -p 0.0.0.0:8090:8090 petal-width-prediction:latest `
-  Ensure that you have installed Curl command and can call the same before executing the command below <br>
`curl -X POST   -H "accept: application/json" -H "Content-Type: application/json" -d "{\"petal_length\":3.0  }" http://127.0.0.1:8090/predict` <br>
You should get a response with the petal_width of 0.83 in a json format as below <br>
`{"petal_length":3.0,"petal_width":0.8834665439726568}`
## Debugging
If you are are not having a response from the model endpoint as above, then check that the model is deployed successfully through an ssh into the container. The command below allows you to sh into the container shell <br>
`docker exec -it petal-width-predictor sh`
