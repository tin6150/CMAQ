
This docker dir was added by me (Tin).



RUN
===

::

	docker run -it -v $HOME:/home/tin tin6150/cmaq


BUILD
=====

::

	docker build -t tin6150/os4cmaq   -f Dockerfile.os4cmaq   .  | tee Dockerfile.os4cmaq.log  && \
	docker build -t tin6150/lib4cmaq  -f Dockerfile.lib4cmaq  .  | tee Dockerfile.lib4cmaq.log && \
	docker build -t tin6150/cmaq      -f Dockerfile           .  | tee Dockerfile.log 
	#docker build -t tin6150/adjoin    -f Dockerfile.adjoin    .  | tee Dockerfile.adjoin.log 

	docker build -t bofh/cmaq         -f Dockerfile           .  | tee bofh.Dockerfile.log 



REGISTRY
========

::
	docker login 
	docker image push tin6150/os4cmaq

	docker pull       tin6150/os4cmaq
	docker pull       tin6150/lib4cmaq
	docker pull       tin6150/cmaq


HUB
===

ref: https://docs.docker.com/docker-hub/builds/

have to configure the build on docker hub web site.  
would be nice if there is a config file like .travis.yml to configure it [well, maybe not in yaml format]

autobuild using docker hub is prefered over the local BUILD and REGISTRY process above.  It is slow, but it keeps log online for easier review.



