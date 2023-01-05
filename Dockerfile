
## Creating a PBJ ( Powered by Jupyter Runtime) to 
FROM ubuntu:22.04
USER root

# Install Python
# Note that the package python-is-python3 will alias python3 as python
RUN apt-get update && apt-get install -y --no-install-recommends \
   python3.10 python3-pip python-is-python3 xz-utils
# Configure pip to install packages under /usr/local
# when building the Runtime image
RUN pip3 config set install.user false
RUN pip install --upgrade pip
RUN apt install --yes python-dev-is-python3 gcc curl
# Install the Jupyter kernel gateway.
# The IPython kernel is automatically installed 
# under the name python3,
# so below we set the kernel name to python3.
RUN pip3 install "jupyter-kernel-gateway==2.5.1"

# Associate uid and gid 8536 with username cdsw
RUN \
  addgroup --gid 8536 cdsw && \
  adduser --disabled-password --gecos "CDSW User" --uid 8536 --gid 8536 cdsw


# Relax permissions to facilitate installation of Cloudera
# client files at startup
RUN for i in /bin /opt /usr /usr/share/java; do \
   mkdir -p ${i}; \
   chown cdsw ${i}; \
   chmod +rw ${i}; \
   for subfolder in `find ${i} -type d` ; do \
      chown cdsw ${subfolder}; \
      chmod +rw ${subfolder}; \
   done \
 done

RUN for i in /etc /etc/alternatives; do \
mkdir -p ${i}; \
chmod 777 ${i}; \
done

# Install any additional packages.
# apt-get install ...
# pip install ...



# Final touches are done by the cdsw user to avoid
# permission issues in CML
USER cdsw

# Set up Python symlink to /usr/local/bin/python3
RUN ln -s $(which python) /usr/local/bin/python3

# configure pip to install packages to /home/cdsw
# once the Runtime image is loaded into CML
RUN /bin/bash -c "echo -e '[install]\nuser = true'" > /etc/pip.conf

# Custom Setup
WORKDIR /home/cdsw
COPY ["app.py", "cdsw-build.sh", "model.pkl", "predict.py", "requirements.txt", "./"]
EXPOSE 8090

ENV PATH="$PATH:/home/cdsw/.local/bin"
ENV APP_IP_ADDRESS="0.0.0.0"
ENV CDSW_APP_PORT="8090"
RUN sh cdsw-build.sh

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8090", "app:app"]

# Set Runtime label and environment variables metadata
#ML_RUNTIME_EDITOR and ML_RUNTIME_METADATA_VERSION must not be changed.
ENV ML_RUNTIME_EDITOR="PBJ Workbench" \
    ML_RUNTIME_METADATA_VERSION="2" \
    ML_RUNTIME_KERNEL="Python 3.10" \
    ML_RUNTIME_EDITION="Custom Edition" \
    ML_RUNTIME_SHORT_VERSION="1.0" \
    ML_RUNTIME_MAINTENANCE_VERSION="1" \
    ML_RUNTIME_JUPYTER_KERNEL_GATEWAY_CMD="/usr/local/bin/jupyter kernelgateway" \
    ML_RUNTIME_JUPYTER_KERNEL_NAME="python3" \
    ML_RUNTIME_DESCRIPTION="My first Custom PBJ Runtime"
          

ENV ML_RUNTIME_FULL_VERSION="$ML_RUNTIME_SHORT_VERSION.$ML_RUNTIME_MAINTENANCE_VERSION" 

LABEL com.cloudera.ml.runtime.editor=$ML_RUNTIME_EDITOR \
	    com.cloudera.ml.runtime.kernel=$ML_RUNTIME_KERNEL \
	    com.cloudera.ml.runtime.edition=$ML_RUNTIME_EDITION \
	    com.cloudera.ml.runtime.full-version=$ML_RUNTIME_FULL_VERSION \
      com.cloudera.ml.runtime.short-version=$ML_RUNTIME_SHORT_VERSION \
      com.cloudera.ml.runtime.maintenance-version=$ML_RUNTIME_MAINTENANCE_VERSION \
      com.cloudera.ml.runtime.description=$ML_RUNTIME_DESCRIPTION \
      com.cloudera.ml.runtime.runtime-metadata-version=$ML_RUNTIME_METADATA_VERSION