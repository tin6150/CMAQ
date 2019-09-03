# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/Makefile,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

SHELL=/bin/sh

 LIBNAME = libse_snl.a
#LIBNAME = libse_snl.debug.a

#FC = mpxlf90
#FSTD = -qfixed=132 -qarch=auto -qtune=auto
#FFLAGS = $(FSTD) -O3 -qstrict -Q
##FLAGS = $(FSTD) -g -qfloat=nans

#MPI = /usr/local/mpich-1.2.4/include
 MPI = /share/linux/bin/mpich-ch_p4/include

#FC = /usr/pgi/linux86/bin/pgf90
 FC = /share/linux/pgi/linux86/5.0/bin/pgf90
#FC = /opt/intel/compiler70/ia32/bin/ifc
#FC = /share/linux/intel7.1/compiler70/ia32/bin/ifc
#FC = /share/linux/intel8.0/bin/ifc
#FC = /share/linux/intel8.0/bin/ifort
 FSTD = -Mfixed -Mextend -O2
#FDBG = -Mfixed -Mextend -g
#FSTD = -FI -extend_source -O2 -w
#FSTD = -w -extend_source -c -O2
#FSTD = -w -extend_source -c -O0
#FFLAGS = $(FSTD) -Mbounds -Mchkfpstk -g
 FFLAGS = $(FSTD) -I $(MPI)
#FFLAGS = $(FDBG) -I $(MPI)

#> the following order is important
 OBJS = \
 se_comm_info_ext.o \
 se_disp_info_ext.o \
 se_domain_info_ext.o \
 se_ori_ext.o \
 se_pe_info_ext.o \
 se_subgrid_info_ext.o \
 se_reconfig_grid_info_ext.o \
 se_bndy_copy_info_ext.o \
 se_internal_util_module.o \
 se_global_max_module.o \
 se_global_min_module.o \
 se_global_sum_module.o \
 se_util_module.o \
 se_data_send_module.o \
 se_data_recv_module.o \
 se_slice_module.o \
 se_comm_module.o \
 se_gather_module.o \
 se_data_copy_module.o \
 se_reconfig_grid_module.o \
 se_bndy_copy_module.o \
 swap_sandia.o \
 swap_sandia_routines.o \
 se_init_module.o \
 se_term_module.o \
 se_modules.o

$(LIBNAME) : $(OBJS)
	$(FC) $(FFLAGS) -c $(?:.o=.f)
	ar -rv $@ $?
	chmod 644 $@

# mv *.o *.a $M3LIB/stenex
# $(FC) $(FFLAGS) -c $(?:.o=.f)

