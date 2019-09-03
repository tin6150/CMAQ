# RCS file, release, date & time of last delta, author, state, [and locker] 
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/noop_f90/Makefile,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

SHELL=/bin/sh

#DEBUG   = .debug
 DEBUG   =
#FC      = /usr/pgi/linux86/bin/pgf90
 FC      = /share/linux/pgi/linux86/5.0/bin/pgf90
 FFLAGS = -Mfixed -Mextend -O2

 LIBNAME = libsef90_noop$(DEBUG).a

 OBJS = \
 noop_comm_module.o \
 noop_data_copy_module.o \
 noop_gather_module.o \
 noop_global_max_module.o \
 noop_global_min_module.o \
 noop_global_sum_module.o \
 noop_init_module.o \
 noop_term_module.o \
 noop_slice_module.o \
 noop_util_module.o \
 noop_modules.o

$(LIBNAME) : $(OBJS)
	$(FC) $(FFLAGS) -c $(?:.o=.f)
	ar -rv $@ $?
	chmod 644 $@

