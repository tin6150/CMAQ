 EXEC       = REFMT_PING
 FC         = /share/linux/pgi/linux86/5.0/bin/pgf90
 IOAPI      = /project/wind1/yoj/lib/ioapi_22
 NTCDF      = /project/wind1/yoj/lib/netCDF/Linux
 F_FLAGS    = -Mfixed -Mextend -O2 -I.
 LINK_FLAGS = -Bstatic

CPP_FLAGS =

LIBRARIES = \
 -L$(IOAPI)/Linux2_x86pg -lioapi \
 -L$(NTCDF) -lnetcdf

INCLUDES = \
 -DSUBST_IOPARMS=\"$(IOAPI)/fixed_src/PARMS3.EXT\" \
 -DSUBST_IOFDESC=\"$(IOAPI)/fixed_src/FDESC3.EXT\" \
 -DSUBST_IODECL=\"$(IOAPI)/fixed_src/IODECL3.EXT\"

OBJECTS = \
 refmt_ping.o

.SUFFIXES: .F

$(EXEC): $(OBJECTS)
	$(FC) $(LINK_FLAGS) $(OBJECTS) $(LIBRARIES) -o $@

.F.o:
	$(FC) -c $(F_FLAGS) $(CPP_FLAGS) $(INCLUDES) $<


