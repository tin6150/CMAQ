## **.rst is my annotated version** 

Notes on running CMAQ-v4.5-ADJ-LAJB or, for short, "CMAQ-v4.5-ADJ", or
"CMAQ-ADJ".

This is the code of the (or rather "one of the") adjoint of the Community
Multiscale Air Quality (CMAQ) model. The code has been adapted by Lucas
A. J. Bastien from the adjoint of CMAQ v4.5 initially written by Hakami et
al. (see Hakami et al. "The Adjoint of CMAQ", Environmental Science and
Technology, 2007, 41, 7807) and initially downloaded from:
http://people.cs.vt.edu/~asandu/Software/CMAQ_ADJ/CMAQ_ADJ.html on January 08th
2013.

Author: Lucas A. J. Bastien

################
# Introduction #
################

Here we give an example on how to run the code.

a) Vocabulary

I give names to my various modeling domains:

 - DOMTEST
 - DOMFULL
 - DOMFUL4
 - ...

I give names to my various simulation periods:

 - JULW1 (first week of July)
 - JULW2 (second week of July)
 - JULFM (July, the full month)
 - JULD1 (first day of July)
 - ...

I give names to my various chemical mechanisms:

 - BENZ (benzene in tracer mode)
 - SAPRC99ROS (SAPRC99 with Rosenbrock solver)              **mainly use SAPRC99ROS**
 - ...

I give name to my various receptors:

 - BAB (Bay Area air basin)
 - SJO (San Jose)
 - PIT (Pittsburg)
 - DOM (entire domain)
 - ...

b) Directory structure

Let us call $DIR_RUN that the directory where all the modeling inputs
and outputs are. For example:

 - MCIP outputs are in $DIR_RUN/MCIP
 - boundary conditions are in $DIR_RUN/BC
 - and so on

    *eg*
	DIR_RUN=/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/
	Ling/Huy puts everything in single folder instead?  see:
	/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ CCTM/SARMAP_KZMIN_F_O3/ADJ_RUN/ run_CCTM_258_7day.tin.csh

c) Running CCTM in forward mode

c.1) If we want to run the forward model with benzene in tracer mode,
for the domain DOMTEST and for the simulation period JULD1, we go
into:

$DIR_RUN/CCTM/DOMTEST_JULD1_BENZ
	*eg* /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ CCTM/CCTM/DOMTEST_JULD1_BENZ
	*eg* /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ CCTM/CCTM/SARMAP_206_O3  ?  or this has altered dir struct by Ling already?
	**>> cctm bin is not under the DIR_RUN  <**
	     /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/./built_gcc_gfortran_serial_SAPRC99ROS/bin/CCTM/cctm
	                       /Downloads/CMAQ/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/./built_gcc_gfortran_serial_SAPRC99ROS/bin/CCTM/cctm
	                       /Downloads/CMAQ/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/./built_gcc_gfortran_parallel_SAPRC99ROS/bin/CCTM/cctm
	                       /Downloads/CMAQ/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/./built_gcc_gfortran_serial_BENZ/bin/CCTM/cctm

c.2) We edit the run script located in that diretory
(run_CCTM.csh). This script does two things:

 - Set user-defined variable (name of the domain, dates of the
   simulation period, ...)

 - Call other scripts

c.3) We run the run script. What will happen is the following:

 - The global "commons" script will be sourced. This script is used by
   all the run scripts and loads the default environment (i.e. it
   defines environment variables that indicate the location and names
   of input files). If users want to use non-default values, then they
   should define the corresponding environment variables in the run
   script (they will have precedence over the default values).

 - The CCTM "commons" script. This script further sets the environment
   for CCTM and calls the CCTM executable.

d) Running CCTM in backward mode

Let us say that we have completed step c and that we want to run CCTM
in backward mode for the following parameters:

 - the pollutant is benzene
 - the receptor is the entire modeling domain
 - the population weighting uses the entire population (DP0010001)

d.1) We go into $DIR_RUN/CCTM/DOMTEST_JULD1_BENZ/ADJ_BENZ_DOM_DP0010001
	*eg* /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ CCTM/DOMTEST_JULD1_BENZ/ADJ_BENZ_DOM_DP0010001

d.2) We edit the run script
	 *eg* yet another run_CCTM.csh, in the dir above.

d.3) We run the run script. Just as before, it sources the global
"commons" script and then the CCTM "commons" script

e) Another example: running the post processor (for the parameters defined in d)

e.1) We go into $RUN_DIR/ADJPOST/DOMTEST_JULD1_BENZ/ADJ_BENZ_DOM_DP0010001
     *eg* /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ ADJPOST/DOMTEST_JULD1_BENZ/ADJ_BENZ_DOM_DP0010001/ run_ADJPOST.csh

e.2) We edit the run script

e.3) We run the run script. Just as before, it sources the global
"commons" script and then the ADJPOST "commons" script. The ADJPOST
commons script sets up ADJPOST-specific resources and then calls the
ADJPOST executable.

It's always the same structure!!

#######################
# Directory structure #
#######################

Here is the directory structure I use to run the code. $DIR_RUN is the
directory that contains the run scripts and all the model inputs and
outputs. It does not necessarily have to contain the model code.

$DIR_RUN/com_global.csh             # Script that sets generic resources. It is used by several components of the modeling system
$DIR_RUN/CCTM/                      # Directory that contains all CCTM-related scripts and all CCTM outputs
	*eg* /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ CCTM/ 
$DIR_RUN/CCTM/com_CCTM.csh          # Script that defines CCTM-specific resources
$DIR_RUN/CCTM/com_CCTM_inout.csh    # Script that defines CCTM-specific resources
$DIR_RUN/CCTM/DOMTEST_JULD1_BENZ/   # Directory that contains the run script and outputs of the CCTM simulation for domain "DOMTEST", simulation period "JULD1", and chemical mechanism "BENZ"
$DIR_RUN/CCTM/DOMTEST_JULD1_BENZ/run_CCTM.csh # Script that runs CCTM for domain "DOMTEST", simulation period "JULD1", and chemical mechanism "BENZ"
	*ie* run "lowest level" script, which will call the higher level script to define default params.
	/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ CCTM/DOMTEST_JULD1_BENZ/ run_CCTM.csh

To run CCTM for domain "DOMTEST", simulation period "JULD1", and chemical
mechanism "BENZ", run $DIR_RUN/CCTM/DOMTEST_JULD1_BENZ/run_CCTM.csh from its
directory. This scripts calls the more 'top-level" scripts ("../com_CCTM.csh",
"../com_CCTM_inout.csh", and "../../com_global.csh") to configure the
environment, then calls the CCTM binary.

!!! The scripts assume that this directory structure is used. Of course, feel
!!! free to adapt the approach, but you will have some work to do on the
!!! scripts.

Note: "com" in file names stands for "common".

Note: com_global.csh defines many variables. If you manually define some of
these variables in your run script (e.g. run_CCTM.csh), then your "manual"
variable definitions have precedence over variable definitions in
com_global.csh. In other words, com_global.csh defines default options. You can
overwrite these defaults settings by setting variables manually in the run
scripts (run_*.csh).

This approach is used for other components of the modeling system. For example
for JPROC:

$DIR_RUN/JPROC/                     # Directory that contains all JPROC-related scripts and all JPROC outputs
	*eg* /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/run/ JPROC/ 
	     but no run script here.
$DIR_RUN/JPROC/com_JPROC.csh        # Script that defines JPROC-specific resources
$DIR_RUN/JPROC/BENZ/                # Directory that contains the run script and outputs of the JPROC simulation for chemical mechanism "BENZ"
$DIR_RUN/JPROC/BENZ/run_JPROC.csh   # Script that runs JPROC for chemical mechanism "BENZ"

Note: if you move the whole $DIR_RUN directory tree or if you run the code on
another machine, you should have relatively little work to do to adjust to the
new environment. Mainly; you will have to modify the variables $DIR_RUN and
$DIR_CODE in $DIR_RUN/com_global.csh. To adjust as well:

- see ${DIR_RUN}/lawrencium-modules.csh in $DIR_RUN/com_global.csh.

##################
# RECEPTOR FILES #
##################

Receptor files are used for adjoint runs only.

I still need to write this section!!

####################################################
# DESCRIPTION OF RUN-TIME VARIABLES IN RUN SCRIPTS #
####################################################

I still need to write this section!!

#################
# MISCELLANEOUS #
#################

I still need to write this section!!
