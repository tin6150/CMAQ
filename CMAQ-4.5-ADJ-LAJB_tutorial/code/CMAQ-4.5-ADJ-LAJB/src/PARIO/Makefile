# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PARIO/src/Makefile,v 1.1.1.1 2005/09/09 16:18:17 sjr Exp $

SHELL=/bin/sh

 LIBNAME = libpario.a
#LIBNAME = libpario.debug.a

#IOAPI = /work/wdx/tools/ioapi_3/ioapi/fixed_src
#FC = mpxlf90
#FSTD = -qfixed=132 -qarch=auto -qtune=auto
#FFLAGS = $(FSTD) -I $(IOAPI) -O3 -qstrict -Q
##FLAGS = $(FSTD) -I $(IOAPI) -g -qfloat=nans

#MPI = /usr/local/mpich-1.2.4/include
 MPI = /share/linux/bin/mpich-ch_p4/include

#IOAPI = /project/air5/yoj/work/ioapi_22/fixed_src
#IOAPI = /home/cwong/yoj/tut02/tool/ioapi_3/ioapi/fixed_src
 IOAPI = /project/wind1/yoj/lib/ioapi_22/fixed_src
#FC = /usr/pgi/linux86/bin/pgf90
 FC = /share/linux/pgi/linux86/5.0/bin/pgf90
#FC = /opt/intel/compiler70/ia32/bin/ifc
#FC = /share/linux/intel7.1/compiler70/ia32/bin/ifc

 FSTD = -Mfixed -Mextend -O2
#FDBG = -Mfixed -Mextend -g
#FSTD = -FI -extend_source -O2 -w
#FFLAGS = $(FSTD) -I $(IOAPI) -Mbounds -Mchkfpstk -g
 FFLAGS = $(FSTD) -I $(MPI) -I $(IOAPI)
#FFLAGS = $(FDBG) -I $(MPI) -I $(IOAPI)

 OBJS= \
 pinterpb_mod.o \
 piomaps_mod.o \
 boundary.o \
 get_write_map.o \
 growbuf.o \
 gtndxhdv.o \
 initm3io.o \
 interpol.o \
 pinterpb.o \
 pio_init.o \
 pm3err.o \
 pm3exit.o \
 pm3warn.o \
 pshut3.o \
 pwrite3.o \
 pwrgrdd.o \
 readbndy.o \
 subdmap.o \
 wrsubmap.o

$(LIBNAME) : $(OBJS)
	$(FC) $(FFLAGS) -c $(?:.o=.f)
	ar -rv $@ $?
	chmod 644 $@

# mv *.o *.a $M3TOOLS/pario
# $(FC) $(FFLAGS) -c $(?:.o=.f)
