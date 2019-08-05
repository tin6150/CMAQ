# Container for libs needed by cmaq (hdf5, netcdf, with fortran lib)

FROM tin6150/lib4cmaq:latest
MAINTAINER Tin

#RUN  echo "Building CMAQ... this isn't likely working yet" 

# CMAQ 5.2.1 build tutorial: https://github.com/USEPA/CMAQ/blob/5.2.1/DOCS/Tutorials/CMAQ_GettingStarted.md

#### make ioapi 3.1.  i have the source downloaded in the my git repo of CMAQ ####
RUN mkdir -p Downloads &&  cd Downloads ;\
    git clone -b tin_521_docker https://tin6150@github.com/tin6150/CMAQ.git ;\
    cd CMAQ ;\
    git log > cmaq.git.log ;\
    #export BIN='Linux2_x86_64gfort'     ;\
    # better to write the setup.sh script to compile cmaq, so that it can be used on actual host or singularity
    # if docker doesn't work
    ./setup.sh 2>&1 | tee setup.log ;\
    echo $? > _CMAQ_BUILD_END_



RUN  cd / \
  && touch    _TOP_DIR_OF_CONTAINER_  \
  && date  >> _TOP_DIR_OF_CONTAINER_  \
  && echo  "cmaq 2019.0804.2233"  >> _TOP_DIR_OF_CONTAINER_  



#ENTRYPOINT ["cat", "/Downloads/netcdf-fortran-4.4.5/_END_BUILD_NETCDF_"]
#ENTRYPOINT ["cat", "/Downloads/CMAQ/_CMAQ_BUILD_END_"]
#ENTRYPOINT ["cat", "/_TOP_DIR_OF_CONTAINER_"]

# not defining an ENTRYPOINT will default to a shell inside the container
# otherwise, run with exec bash to get shell:
# docker exec -it tin6150/cmaq -v /home/tin:/home bash 
