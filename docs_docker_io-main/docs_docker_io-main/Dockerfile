# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /Sosotech-Doc

# Copy the current directory contents into the container at /app
COPY . /Sosotech-Doc

# Install mkdocs and the material theme
RUN pip install --no-cache-dir mkdocs mkdocs-material

# Expose port 8000 to the outside world
EXPOSE 8087

# Run mkdocs to serve the site
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8087"]
#----------

# FROM python:alpine3.17
# COPY ./Sosotech-Doc/ /Sosotech-Doc/

# RUN pip install mkdocs

# RUN mkdocs new Sosotech.Doc

# EXPOSE 80

# WORKDIR /Sosotech-Doc/

# ENTRYPOINT ["mkdocs"]
# #CMD [ "python", "server.py" ]
# CMD ["serve", "--dev-addr=0.0.0.0:80"]
# #CMD ["serve", "mkdocs.yaml"]