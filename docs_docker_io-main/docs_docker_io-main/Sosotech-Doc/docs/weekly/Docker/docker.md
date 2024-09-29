#  Install docker


## Sample use cases
5 Sample Build Deploy 
### 1. Docker and Mkdocs 
Build and deploy push Mkdocs to ECR/DockerHub
Clone this repo: [docs_docker_io](https://github.com/sosotechnologies/docs_docker_io.git)

***Install Docker***
```
sudo yum install docker -y
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
```

```docker build -t sosodocsimage .```

```docker run -itd -p 80:80 --rm sosodocsimage```

```docker run -t -i -p 80:80 sosodocsimage```

And that is all, you should be able to navigate to [Your-IP:80] and see the documentation website running.

***Create an ECR, tag and Push Image***

```
aws ecr create-repository --repository-name soso-repository --region us-east-1

sudo su -

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 088789840359.dkr.ecr.us-east-1.amazonaws.com

docker tag sosodocsimage 088789840359.dkr.ecr.us-east-1.amazonaws.com/soso-repository:v1

docker push 088789840359.dkr.ecr.us-east-1.amazonaws.com/soso-repository:v1
```

***Optional***
Tag Your docker image with a version 

 ```sudo docker tag sosodocs sosodocs:v1```

Delete the existing running container, 26b43376e040 is mine, get yours.

```sudo docker rm 26b43376e040```    
           OR
```sudo docker rm 26b43376e040 --force```

Re-run the new versioned-image

 ```sudo docker run -itd -p 80:80 --rm sosodocs:v1```

To remove container or image:

```
docker rm [container]
docker rmi [image]
```

