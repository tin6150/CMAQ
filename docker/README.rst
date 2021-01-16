
This docker dir was added by me (Tin).



RUN
===

::

	docker run  -it -v $HOME:/home/tin tin6150/cmaq
	docker exec -it uranus_hertz bash                 # additional terminal into existing running container


BUILD
=====

::

	docker build -t tin6150/os4cmaq   -f Dockerfile.os4cmaq   .  | tee Dockerfile.os4cmaq.log  && \
	docker build -t tin6150/lib4cmaq  -f Dockerfile.lib4cmaq  .  | tee Dockerfile.lib4cmaq.log && \
	docker build -t tin6150/cmaq      -f Dockerfile           .  | tee Dockerfile.log 
	docker build -t tin6150/adjoin    -f Dockerfile.adjoin    .  | tee Dockerfile.adjoin.log      # no longer needed

	# actually, could build locally with just the same tag.  run can invoke by image id?  but this is less confusing for human :)
	docker build -t bofh/lib4cmaq     -f Dockerfile.lib4cmaq  .  | tee bofh.Dockerfile.lib4cmaq.log 
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



X11 GUI app
===========

docker run -it  -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY  --name xterm   --rm  tin6150/os4cmaq /usr/bin/xterm
# works.  used Docker version 18.09.7, build 2d0083d (ubuntu 18.04)
# note that must use source and destination in -v map.
# cannot just use -v /tmp/.X11-unix , nor -v /tmp
# could use -e DISPLAY=:0
# probably don't need to run xhost +

