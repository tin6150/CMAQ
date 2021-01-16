

this should be mostly same as serial version of SAPRC99
checked diff as:

  136  19/09/19 23:56:07 diff makefile ../built_gcc_gfortran_serial_SAPRC99ROS/makefile.gpada+mpi_f90 
  142  19/09/19 23:57:17 diff environment-user ../built_gcc_gfortran_serial_SAPRC99ROS/environment-user.gpanda 


parallel version, environment-user no longer define -lnetcdff
and define PartOpt

< # export LIB_NETCDF=-lnetcdff
---
> export LIB_NETCDF=-lnetcdff
44c44
< export ParOpt=""
---
> #export ParOpt=""

