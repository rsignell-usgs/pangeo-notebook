# pangeo-notebook
Dockerfile for creating pangeo.esipfed.org notebook

Here's where I manually build my container and upload to dockerhub, typically the procedure is:

First I edit the `worker-template.yaml` to specify the image we will be using for the worker, which I make the same as the notebook image we are about to build.  I find it convenient to tag with the current date, so I do something like:
````
image: esip/pangeo-notebook:2019-03-28
```

I then build the new container with that tag, so for example:
```
 docker build --no-cache  -t esip/pangeo-notebook:2019-03-28 . >& docker.log &
```
Assuming the build went well, I then upload to dockerhub:
```
docker push esip/pangeo-notebook:2019-03-28
```
