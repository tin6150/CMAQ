#!/bin/csh

#### compile and install cmaq and its dependencies.
#### done as function, which is really section
#### run as:
#### ./setup.csh 2>&1 |  tee setup.log    # sh
#### ./setup.csh      |& tee setup.log    # csh

#### this is new version of setup*csh, for CMAQ 5.2.1
#### had converted from sh to csh when giving up setup45.csh
#### maybe functional...
#### but moving on to compile Lucas' Adjoin model, which seems to be wiht CMAQ 4.5...
#### see setup_adjoin.sh  (hmm... back to bash...)


#### CMAQ 5.2.1: build tutorial https://github.com/USEPA/CMAQ/blob/5.2.1/DOCS/Tutorials/CMAQ_GettingStarted.md


#### argggg... no fn in csh :(  http://www.grymoire.com/Unix/CshTop10.txt
#### what about fish?

#########################################
### formerly fn called env_prep() {  ####
#########################################

	### ** CSH Anoyance ** csh craps:
	### set path = ( $path /bin /usr/local/bin /usr/bin /usr/bin/X11 ~/bin /sbin /usr/sbin . )
    ### or (use braces {} are required around var name and quotes).
	### setenv PATH            "${PATH}:${AMGEN_HOME}/bin"
	### *** CONCLUSION: Best use space and the lower case version!!
	### LD_LIBRARY_PATH seems to be okay with the setenv LD_LIBRARY_PATH and colon separated list...
	echo "    **>> ========================================== <<**"
	echo "    **>> start of env_prep in setup.csh             <<**"
	echo "    **>> ========================================== <<**"
	date


	# notice how syntax highlight treat PATH vs path differently!
	if(! ${?PATH} ) then
		set path = ( /bin ) # ie seed PATH since it was never defined

	endif
	if(! ${?LD_LIBRARY_PATH}) then
		setenv LD_LIBRARY_PATH "/lib" # ie seed LD_LIBRARY_PATH since it was never defined
	endif

	setenv PATH "/usr/local/bin:${PATH}"
	#setenv PATH "/usr/lib64/openmpi/bin:${PATH}"
	setenv LD_LIBRARY_PATH "/usr/local/lib:${LD_LIBRARY_PATH}"

    #echo ${LD_LIBRARY_PATH}
	#echo ${PATH}

	##setenv compiler gcc # pgi
	setenv CC       "cc" 
	setenv CCFLAGS  "-g"                       # not mpicc or ortecc ? (using that tutorial says for now)
	setenv CPPFLAGS '-DNDEBUG -DgFortran'
	setenv FC 		gfortran 
	setenv myFC 	/usr/bin/gfortran # seems to be needed by bldit_bcon.csh:270
	setenv FCFLAGS 	"-g"
	setenv FFLAGS 	'-g -w'
	setenv CXX 		'g++'
	setenv compilerString  gcc  # needed by run_cctm.csh, but didn't think i need to set it myself in here... but hopefully solve complain.

	#setenv SRCBASE /local/home/tin/tin-gh    # as appropriate 
	setenv SRCBASE 	`pwd`                     # eg /Downloads/CMAQ  # from git clone
	setenv DSTBASE 	"/opt/CMAS5.2.1/rel"
	mkdir -p $DSTBASE

	#setenv BIN 	`uname -s``uname -r | cut -d. -f1`
	setenv BIN 		'Linux2_x86_64gfort'

	#echo "dumping  env..."
	#env
########################################
#### } # end of former fn  env_prep ####
########################################

# skip setup_ioapi for now
#--goto end_ioapi
#goto being_setup_cmaq52

#tmp exit
#goto hell


being_setup_ioapi:
#### cmaq ioapi build: https://www.cmascenter.org/ioapi/documentation/all_versions/html/AVAIL.html#build
#### will use ioapi 3.2
#### pre-downloaded into my git repo from https://www.cmascenter.org/ioapi/download/ioapi-3.2.tar.gz inside ioapi/
#####################################################
#### setup_ioapi() { # begin of former fn in .sh ####
#####################################################
		echo "    **>> ========================================== <<**"
		echo "    **>> start of setup_ioapi in setup.csh          <<**"
		date
		echo "    **>> ========================================== <<**"
		setenv 		BASEDIR 	${SRCBASE}/Api 			# source dir, eg /Downloads/CMAQ/Api
		mkdir -p 	$BASEDIR/$BIN 						# BIN is now Linux2_x86_64gfort

		cd $BASEDIR     #cd into .../Api
		## just to be obvious that I have done some edits and using them in the build
		## copy file first...
		/bin/cp -p Makefile.centos7gcc Makefile       # some edit done, now using gcc-gfortran 
		setenv INSTDIR ${DSTBASE}/lib/ioapi_3 # /opt/CMAS5.2.1/rel/lib/ioapi_3
		mkdir -p $INSTDIR                     # install destination
		#++ not sure if below HOME=... syntax still work in csh
		make HOME=${BASEDIR}/ioapi           |& tee make.log
		make HOME=${BASEDIR}/ioapi  install  |& tee make.install.log
		# in 3.1? only 1 file: /opt/CMAS4.5.1/rel/lib/ioapi_3/libioapi.a
		# in 3.2, seems to include m3tools 
		# /opt/CMAS5.2.1/rel/Linux2_x86_64gfort/libioapi.a and m3* 
		# seems to be stuck in here :(  which is why docker build time out...   FIXME
		# echo "Installing M3TOOLS in /opt/CMAS5.2.1/rel/Linux2_x86_64gfort"
		## Installing M3TOOLS in /opt/CMAS5.2.1/rel/Linux2_x86_64gfort
		## cd /Downloads/CMAQ/Api/Linux2_x86_64gfort; cp airs2m3         bcwndw          camxtom3        datshift        dayagg factor          findwndw        greg2jul        gregdate        gridprobe insertgrid      jul2greg        juldate         juldiff         julshift kfxtract        latlon          m3agmax         m3agmask        m3cple m3combo         m3diff          m3edhdr         m3fake          m3hdr m3interp        m3mask          m3merge         m3pair          m3probe m3stat          m3totxt         m3tproc         m3tshift        m3wndw m3xtract        mtxblend        mtxbuild        mtxcalc         mtxcple presterp        presz           projtool        selmrg2d        timeshift vertot          vertimeproc     vertintegral    wrfgriddesc     wrftom3 mpasdiff        mpasstat        mpastom3 /opt/CMAS5.2.1/rel/Linux2_x86_64gfort
		## make[1]: Leaving directory `/Downloads/CMAQ/Api/m3tools'




		cd ${SRCBASE}
end_ioapi:
#########################################
#### } # end of former setup_ioapi() ####
#########################################





being_setup_cmaq52:
######################################################
#### setup_cmaq52() { # begin of former fn in .sh ####
######################################################
	echo "    `` #rst food ``"
	echo "    **>> ========================== <<**"
	echo "    **>> starting setup_cmq52 fn... <<**"
	date
	echo "    **>> ========================== <<**"

	# may end up just calling this config script directly from Dockerfile
	/bin/cp -p ./config_cmaq.tin.csh ./config_cmaq.csh 
	pwd
	echo "    **>> ========================================== <<**"
	echo "    **>> calling ./config_cmaq.csh ... <<**"
	date
	echo "    **>> ========================================== <<**"
	## ++ seems like invokation of these helper script has error with setenv... 
	## setenv: Variable name must contain alphanumeric characters.
	source ./config_cmaq.csh gcc              # probably just creating bunch of links

	# ++ download test data, will have this done into my git repo already
	#    https://github.com/USEPA/CMAQ/blob/5.2.1/DOCS/Tutorials/CMAQ_Benchmark.md

	# ++ set username?  it created /home/username literary!

	echo "    **>> ========================================== <<**"
	echo "    **>> calling ./bldit_project.csh ... <<**"
	date
	echo "    **>> ========================================== <<**"
	./bldit_project.csh gcc |& tee bldit_project.log 
		## ++ mkdir: cannot create directory /home/username/CMAQ_Project/POST/combine/scripts/spec_def_files: File exists
		## edit /home/tin/tin-gh/CMAQ/PREP/bcon/scripts ???


	#DIRSTACK=`pwd`
	setenv CMAQ_HOME `pwd`
	cd ${CMAQ_HOME}/PREP/bcon/scripts/
	pwd
	echo "    **>> ========================================== <<**"
	echo "    **>> calling ./bldit_bcon.csh ... <<**"
	date
	echo "    **>> ========================================== <<**"
	./bldit_bcon.csh gcc |& tee bldit_bcon.log
		## ++ myFC: Undefined variable.  # declared above now


	cd $CMAQ_HOME

	#### actually build cmaq here:
	cd ${CMAQ_HOME}/CCTM/scripts
	pwd
	echo "    **>> ========================================== <<**"
	echo "    **>> calling ./bldit_cctm.csh ... <<**"
	date
	echo "    **>> ========================================== <<**"
	./bldit_cctm.csh gcc |& tee bldit_cctm.log
		## ++ myFC: Undefined variable.  # declared above now

	cd $CMAQ_HOME


	#### run b enchmark script
	cd ${CMAQ_HOME}/CCTM/scripts
	pwd
	echo "    **>> ========================================== <<**"
	echo "    **>> calling ./run_cctm.csh ... <<**"
	date
	echo "    **>> ========================================== <<**"
	./run_cctm.csh |& tee run.benchmark.log
	#### maybe problem here... continue tomorrow...   FIXME ++ 

		## ++ setenv: Variable name must contain alphanumeric characters.
		## ++ compilerString: Undefined variable.


	echo $?
	echo "    **>> ========================================== <<**"
	echo "    **>> end of setup_cmaq52 fn. <<**"
	date
	echo "    **>> ========================================== <<**"
	cd $CMAQ_HOME
	pwd


#########################################
#### } # end of former setup_ioapi() ####
#########################################


hell:
exit 0

#### csh was supposed to be more c-like
#### yet i have no way to emulate main() 

################################################################################
# vim modeline, also see alias `vit`
# vim:  noexpandtab nosmarttab noautoindent nosmartindent tabstop=4 shiftwidth=4 paste formatoptions-=cro 