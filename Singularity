Bootstrap: docker
From: tin6150/cmaq

# Singularity def, wrap around docker tin6150/cmaq 

%post
	touch "_ROOT_DIR_OF_CONTAINER_" ## also is "_CURRENT_DIR_CONTAINER_BUILD" 
	date >> _ROOT_DIR_OF_CONTAINER_
	echo "Singularity def 2019.0820 0830" >> _ROOT_DIR_OF_CONTAINER_
%runscript
    #pgcc $@
    /bin/tcsh
    #pgf95 $@

%help
    EPA CMAQ, tryin to get it to work in a container, may not work yet.
    

# build cmd:
# sudo /opt/singularity-2.6/bin/singularity build --writable cmaq_b0820a.img Singularity 2>&1  | tee singularity_build.log
#
# eg run cmd on bofh w/ singularity 2.6.2:
#      /opt/singularity-2.6/bin/singularity run     cmaq_b0820a.img
# sudo /opt/singularity-2.6/bin/singularity exec -w cmaq_b0820a.img /bin/tcsh

# eg run cmd on lrc, singularity 2.6-dist (maybe locally compiled)
#      singularity shell -w ./cmaq_b0820a.img
#      ++ need to add more dir binding...

# vim: nosmartindent tabstop=4 noexpandtab shiftwidth=4
