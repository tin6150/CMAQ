
This docker dir was added by me (Tin).



RUN
===

::
	docker run -it -v $HOME:/home tin6150/os4cmaq


BUILD
=====

::

	docker build -t tin6150/os4cmaq   -f Dockerfile.os4cmaq
	docker build -t tin6150/lib4cmaq  -f Dockerfile.lib4cmaq
	docker build -t tin6150/cmaq      -f Dockerfile.cmaq


REGISTRY
========

::
	docker login 
	docker image push tin6150/os4cmaq
	docker pull       tin6150/os4cmaq


HUB
===

ref: https://docs.docker.com/docker-hub/builds/



