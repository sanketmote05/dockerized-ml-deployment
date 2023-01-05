
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
