# Use the official ubuntu linux image as a parent image
FROM ubuntu:latest

# Set the working directory to /iac (infrastructure as code)
WORKDIR /iac
RUN mkdir /iac/jumpbox

# Copy the current directory contents into the container at /app
ADD . /iac/jumpbox

#Setup the operating environment
ADD docker/bootstrap.sh /root/.
RUN chmod +x /root/bootstrap.sh
RUN bash -c "/root/bootstrap.sh"

ENTRYPOINT ["/bin/bash"]
