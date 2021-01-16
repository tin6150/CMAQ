# Main Dockerfile for creating CMAQ in a container
# formerly Dockerfile.cmaq
# depends on a cascade of 2 other containers
 

FROM tin6150/lib4cmaq:latest
MAINTAINER Tin

#RUN  echo "Building CMAQ... this isn't likely working yet" 

# CMAQ 5.2.1 build tutorial: https://github.com/USEPA/CMAQ/blob/5.2.1/DOCS/Tutorials/CMAQ_GettingStarted.md

#### make ioapi 3.1.  i have the source downloaded in the my git repo of CMAQ ####
RUN touch    _TOP_DIR_OF_CONTAINER_  ;\
    echo "begining docker build process at " | tee -a _TOP_DIR_OF_CONTAINER_ ;\
    date | TZ=PST8PDT tee -a _TOP_DIR_OF_CONTAINER_ ;\
    mkdir -p Downloads &&  cd Downloads ;\
    #git clone -b ...; git pull; still does NOT always produce latest repo :(
    #git clone --quiet -b tin_521_docker https://tin6150@github.com/tin6150/CMAQ.git ;\
    git clone --quiet                   https://tin6150@github.com/tin6150/CMAQ.git ;\
    cd CMAQ ;\
    git fetch --quiet ;\
    git checkout tin_521_docker ;\
    git pull --quiet ;\
    git log > cmaq.git.log ;\
    #export BIN='Linux2_x86_64gfort'     ;\
    # better to write the setup.sh script to compile cmaq, so that it can be used on actual host or singularity
    # if docker doesn't work
    ./setup.csh 2>&1 | tee setup.log.rst ;\
    echo $? > _CMAQ_BUILD_END_ ;\

    # Adding a bash script to compile Lucas Adjoin models
    bash ./setup_adjoin.sh  2>&1 | tee setup.adjoin.log.rst ;\
    echo $? > _CMAQ_ADJOIN_BUILD_END_ ;\

     cd / \
  && ln -s /Downloads/CMAQ /cmaq   \
  && touch _TOP_DIR_OF_CONTAINER_  \
  && TZ=PST8PDT date  >> _TOP_DIR_OF_CONTAINER_  \
  && echo  "Dockerfile.cmaq 2019.0814.2218 (setenv fix, add myFC, compilerString)"  >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Dockerfile.cmaq 2019.0915.1350+ (using mpicc)"                          >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Dockerfile.cmaq 2019.1001 (setup_adjoin build *SAPRC99 ok)"             >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "(autobuild for other Dockerfile.* disabled)"                            >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "(Each RUN block must have changes or docker build web site will use a catche)" | tee -a _TOP_DIR_OF_CONTAINER_ \
  && echo  "Grand Finale"

#- TZ also layer above, in Dockerfile.lib4cmaq.  They can eventually be removed from here. ++ 
#- ENV TZ America/Los_Angeles  
ENV TZ EST5EDT
# ENV TZ likely changed/overwritten by container's /etc/csh.cshrc
ENV DOCKERFILE Dockerfile[.cmaq]
# does overwrite parent def of ENV DOCKERFILE
ENV TEST_DOCKER_ENV     this_env_will_be_avail_when_container_is_run_or_exec
ENV TEST_DOCKER_ENV_2   Can_use_ADD_to_make_ENV_avail_in_build_process
ENV TEST_DOCKER_ENV_REF https://vsupalov.com/docker-arg-env-variable-guide/#setting-env-values
# but how to append, eg add to PATH?

#ENTRYPOINT ["cat", "/Downloads/netcdf-fotran-4.4.5/_END_BUILD_NETCDF_"]
#ENTRYPOINT ["cat", "/Downloads/CMAQ/_CMAQ_BUILD_END_"]
#ENTRYPOINT ["cat", "/_TOP_DIR_OF_CONTAINER_"]

# if no defined ENTRYPOINT, default to bash inside the container
# parent container defined tcsh.
# can also run with exec bash to get shell:
# docker exec -it tin6150/cmaq -v $HOME:/home/tin  bash 
# careful not to cover /home/username (for this container)
