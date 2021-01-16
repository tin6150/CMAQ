
Dockerfile.cmaq build  425e5555 2019.0811
---------------

was going to rewrite setup.sh and blow away old var names littered in setup45.sh
hopefully define all lib correctly then :)


Fatal Error: Can't open module file 'm3utilio.mod' for reading at (1): No such file or directory


context:

modName 4 M3UTILIO -------------
modName,modFile 5 BC_PARMS BC_PARMS.F
USE/MODULE dependencies defined
Makefile generated
mpif90 -c -ffixed-form -ffixed-line-length-132 -funroll-loops -finit-character=32 -O3 -funroll-loops -finit-character=32 -Wtabs -Wsurprising -I /Downloads/CMAQ/lib/x86_64/gcc/ioapi/modules -I /Downloads/CMAQ/lib/x86_64/gcc/ioapi/include_files BC_PARMS.F
Warning: Nonexistent include directory "/Downloads/CMAQ/lib/x86_64/gcc/ioapi/modules"
mpif90 -c -ffixed-form -ffixed-line-length-132 -funroll-loops -finit-character=32 -O3 -funroll-loops -finit-character=32 -Wtabs -Wsurprising -I /Downloads/CMAQ/lib/x86_64/gcc/ioapi/modules -I /Downloads/CMAQ/lib/x86_64/gcc/ioapi/include_files UTILIO_DEFN.F
Warning: Nonexistent include directory "/Downloads/CMAQ/lib/x86_64/gcc/ioapi/modules"
UTILIO_DEFN.F:71.12:
USE M3UTILIO, INTERPB => INTERP3
1
Fatal Error: Can't open module file 'm3utilio.mod' for reading at (1): No such file or directory     **<<**
make: *** [UTILIO_DEFN.o] Error 1
**ERROR** while running make command
else
endif
mv Makefile Makefile.gcc
if ( -e Makefile.gcc && -e Makefile ) rm Makefile
ln -s Makefile.gcc Makefile
if ( 0 != 0 ) then
if ( -e /Downloads/CMAQ/PREP/bcon/scripts/BLD_BCON_v52_profile_gcc/BCON_v52_profile.cfg ) then
mv BCON_v52_profile.cfg.bld /Downloads/CMAQ/PREP/bcon/scripts/BLD_BCON_v52_profile_gcc/BCON_v52_profile.cfg
exit
/Downloads/CMAQ/CCTM/scripts
**>> calling ./bldit_cctm.csh ... <<**


	**>> problem went away?  now using a new setup.csh, don't seems to see this anymore 09/14 <<**


2019.0914
----------

Dockerfile.cmaq build  d4001b3d5ef8736d96c287526e02b4acdc7b2955  

/opt/CMAS5.2.1/rel/Linux2_x86_64gfort/libioapi.a(m3msg2.o): In function `m3msg2_':
m3msg2.F:(.text+0x1e): undefined reference to `GOMP_critical_name_start'
m3msg2.F:(.text+0x8d): undefined reference to `GOMP_critical_name_end'
/opt/CMAS5.2.1/rel/Linux2_x86_64gfort/libioapi.a(m3msg2.o): In function `m3mesg_':
m3msg2.F:(.text+0xd4): undefined reference to `GOMP_critical_name_start'
m3msg2.F:(.text+0x14d): undefined reference to `GOMP_critical_name_end'


likely in gfortran
compiling for jproc

so need to find out if ioapi build with fortran... 
hopefully not cuz using ioapi 3.2 (Lucas may have been using 3.0)

nm -o on libioapi.a shows... (so, undefined? from where it got that??)
/opt/CMAS5.2.1/rel/Linux2_x86_64gfort/libioapi.a:modgctp.o:                 U GOMP_critical_name_start


netcdf not compiled with fortran?


