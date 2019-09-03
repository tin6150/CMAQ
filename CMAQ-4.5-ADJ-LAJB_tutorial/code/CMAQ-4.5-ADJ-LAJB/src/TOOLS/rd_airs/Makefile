# make file to build rd_airs program

# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/TOOLS/src/rd_airs/Makefile,v 1.1.1.1 2005/09/09 19:17:32 sjr Exp $ 

PROGRAM = rd_airsV1.0.exe

# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'/share/linux/ioapi_pg/include/PARMS3.EXT\' \
 -DSUBST_IOFDESC=\'/share/linux/ioapi_pg/include/FDESC3.EXT\' \
 -DSUBST_IODECL=\'/share/linux/ioapi_pg/include/IODECL3.EXT\' \
 -DSUBST_XSTAT=\'/share/linux/ioapi_pg/include/STATE3.EXT\'

FC = pgf90
FC_FLAGS = -c -Mextend $(INCLUDES)

LIBRARIES = -L /share/linux/ioapi_pg/lib -lioapi \
            -L /share/linux/netcdf_3.5/lib -lnetcdf


OBJS=	\
 module_envvar.o \
 module_sites.o \
 parser.o \
 rd_airs.o


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)
 
.F.o:
	$(FC) $(FC_FLAGS) $<
 



