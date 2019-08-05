# Container for libs needed by cmaq (hdf5, netcdf, with fortran lib)

FROM tin6150/lib4cmaq:latest
MAINTAINER Tin

#RUN  echo "Building CMAQ... this isn't likely working yet" 

#### make ioapi 3.1.  i have the source downloaded in the my git repo of CMAQ ####
RUN mkdir -p Downloads &&  cd Downloads ;\
    git clone -b tin_521_docker https://tin6150@github.com/tin6150/CMAQ.git ;\
    cd CMAQ ;\
    git log > cmaq.git.log ;\
    export BIN='Linux2_x86_64gfort'     ;\
    echo $? > _CMAQ_BUILD_END_



RUN  cd / \
  && touch    _TOP_DIR_OF_CONTAINER_  \
  && date  >> _TOP_DIR_OF_CONTAINER_  \
  && echo  "cmaq 2019.0804.2100"  >> _TOP_DIR_OF_CONTAINER_  



ENTRYPOINT ["cat", "/Downloads/netcdf-fortran-4.4.5/_END_BUILD_NETCDF_"]

