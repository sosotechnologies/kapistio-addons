## Docker build and deploy
```docker build -t sosodocs .```

```docker run -itd -p 80:80 --rm sosodocs```

```docker run -t -i -p 80:80 sosodocs```

And that is all, you should be able to navigate to http://127.0.0.1:80 and see the documentation website running.

### USING AWS
Check to see if you can successfully login to ecr [my example ecr code below, USE YOURS ], you have to be root, 

```
sudo su -
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 088789840359.dkr.ecr.us-east-1.amazonaws.com
```

13. ### Build and Push Docker
```sudo docker build -t sosodocs .```

***Tag the sosodoc image***

```sudo docker tag sosodocs 088789840359.dkr.ecr.us-east-1.amazonaws.com/soso-repository:mkdocs-v1```

***Push image to repo***

```sudo docker push 088789840359.dkr.ecr.us-east-1.amazonaws.com/soso-repository:mkdocs-v1```
