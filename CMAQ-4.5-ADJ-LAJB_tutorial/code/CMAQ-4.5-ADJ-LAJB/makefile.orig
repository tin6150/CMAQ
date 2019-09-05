# Portions of Models-3/CMAQ software were developed or based on information
# from various groups: Federal Government employees, contractors working on a
# United States Government contract, and non-Federal sources (including
# research institutions).  These research institutions have given the
# Government permission to use, prepare derivative works, and distribute copies
# of their work in Models-3/CMAQ to the public and to permit others to do so.
# EPA therefore grants similar permissions for use of the Models-3/CMAQ
# software, but users are requested to provide copies of derivative works to
# the Government without restrictions as to use by others.  Users are
# responsible for acquiring their own copies of commercial software associated
# with Models-3/CMAQ and for complying with vendor requirements.  Software
# copyrights by the MCNC Environmental Modeling Center are used with their
# permissions subject to the above restrictions.
#
# Author: Lucas A. J. Bastien
#
# Makefile for CMAQ v4.5-ADJ.

FORCE:

all: dir pario stenex jproc icon bcon cctm

pario: $(DIR_INSTL)/lib/PARIO/libpario.a

stenex: $(DIR_INSTL)/lib/STENEX/libstenex_se_snl.a $(DIR_INSTL)/lib/STENEX/libstenex_noop_f90.a

jproc: $(DIR_INSTL)/bin/JPROC/jproc

icon: $(DIR_INSTL)/bin/ICON/icon

bcon: $(DIR_INSTL)/bin/BCON/bcon

cctm: $(DIR_INSTL)/bin/CCTM/cctm

adjpost: $(DIR_INSTL)/bin/ADJPOST/adjpost

dir:
	mkdir -vp $(DIR_INSTL)
	mkdir -vp $(DIR_INSTL)/lib
	mkdir -vp $(DIR_INSTL)/lib/PARIO
	mkdir -vp $(DIR_INSTL)/lib/STENEX
	mkdir -vp $(DIR_INSTL)/bin
	mkdir -vp $(DIR_INSTL)/bin/JPROC
	mkdir -vp $(DIR_INSTL)/bin/ICON
	mkdir -vp $(DIR_INSTL)/bin/BCON
	mkdir -vp $(DIR_INSTL)/bin/CCTM
	mkdir -vp $(DIR_INSTL)/bin/ADJPOST
	mkdir -vp $(DIR_INSTL)/bld
	mkdir -vp $(DIR_INSTL)/bld/PARIO/
	mkdir -vp $(DIR_INSTL)/bld/PARIO/mod
	mkdir -vp $(DIR_INSTL)/bld/STENEX
	mkdir -vp $(DIR_INSTL)/bld/STENEX/noop_f90
	mkdir -vp $(DIR_INSTL)/bld/STENEX/noop_f90/mod
	mkdir -vp $(DIR_INSTL)/bld/STENEX/se_snl
	mkdir -vp $(DIR_INSTL)/bld/STENEX/se_snl/mod
	mkdir -vp $(DIR_INSTL)/bld/ICON
	mkdir -vp $(DIR_INSTL)/bld/JPROC
	mkdir -vp $(DIR_INSTL)/bld/JPROC/driver
	mkdir -vp $(DIR_INSTL)/bld/JPROC/driver/jproc_table
	mkdir -vp $(DIR_INSTL)/bld/JPROC/driver/jproc_table/mod
	mkdir -vp $(DIR_INSTL)/bld/ICON/driver
	mkdir -vp $(DIR_INSTL)/bld/ICON/driver/icon
	mkdir -vp $(DIR_INSTL)/bld/ICON/driver/icon/mod
	mkdir -vp $(DIR_INSTL)/bld/ICON/input
	mkdir -vp $(DIR_INSTL)/bld/ICON/input/$(ModInpt)
	mkdir -vp $(DIR_INSTL)/bld/ICON/input/$(ModInpt)/mod
	mkdir -vp $(DIR_INSTL)/bld/ICON/mech_conv
	mkdir -vp $(DIR_INSTL)/bld/ICON/mech_conv/$(DIR_ModMech)
	mkdir -vp $(DIR_INSTL)/bld/ICON/mech_conv/$(DIR_ModMech)/mod
	mkdir -vp $(DIR_INSTL)/bld/ICON/par/par_noop
	mkdir -vp $(DIR_INSTL)/bld/ICON/par/par_noop/mod
	mkdir -vp $(DIR_INSTL)/bld/BCON
	mkdir -vp $(DIR_INSTL)/bld/BCON/driver
	mkdir -vp $(DIR_INSTL)/bld/BCON/driver/bcon
	mkdir -vp $(DIR_INSTL)/bld/BCON/driver/bcon/mod
	mkdir -vp $(DIR_INSTL)/bld/BCON/input
	mkdir -vp $(DIR_INSTL)/bld/BCON/input/$(ModInpt)
	mkdir -vp $(DIR_INSTL)/bld/BCON/input/$(ModInpt)/mod
	mkdir -vp $(DIR_INSTL)/bld/BCON/mech_conv
	mkdir -vp $(DIR_INSTL)/bld/BCON/mech_conv/$(DIR_ModMech)
	mkdir -vp $(DIR_INSTL)/bld/BCON/mech_conv/$(DIR_ModMech)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM
	mkdir -vp $(DIR_INSTL)/bld/CCTM/driver
	mkdir -vp $(DIR_INSTL)/bld/CCTM/driver/$(DIR_ModDriver)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/driver/$(DIR_ModDriver)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/par
	mkdir -vp $(DIR_INSTL)/bld/CCTM/par/$(ModPar)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/par/$(ModPar)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/init
	mkdir -vp $(DIR_INSTL)/bld/CCTM/init/$(DIR_ModInit)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/init/$(DIR_ModInit)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjcon
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjcon/$(ModAdjc)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjcon/$(ModAdjc)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/couple
	mkdir -vp $(DIR_INSTL)/bld/CCTM/couple/$(ModCpl)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/couple/$(ModCpl)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/hadv
	mkdir -vp $(DIR_INSTL)/bld/CCTM/hadv/$(DIR_ModHadv)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/hadv/$(DIR_ModHadv)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/vadv
	mkdir -vp $(DIR_INSTL)/bld/CCTM/vadv/$(DIR_ModVadv)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/vadv/$(DIR_ModVadv)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/hdiff
	mkdir -vp $(DIR_INSTL)/bld/CCTM/hdiff/$(ModHdiff)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/hdiff/$(ModHdiff)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/vdiff
	mkdir -vp $(DIR_INSTL)/bld/CCTM/vdiff/$(ModVdiff)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/vdiff/$(ModVdiff)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/phot
	mkdir -vp $(DIR_INSTL)/bld/CCTM/phot/$(ModPhot)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/phot/$(ModPhot)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/ping
	mkdir -vp $(DIR_INSTL)/bld/CCTM/ping/$(DIR_ModPing)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/ping/$(DIR_ModPing)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/chem
	mkdir -vp $(DIR_INSTL)/bld/CCTM/chem/$(ModChem)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/chem/$(ModChem)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/aero
	mkdir -vp $(DIR_INSTL)/bld/CCTM/aero/$(ModAero)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/aero/$(ModAero)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/aero_depv
	mkdir -vp $(DIR_INSTL)/bld/CCTM/aero_depv/$(ModAdepv)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/aero_depv/$(ModAdepv)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/cloud
	mkdir -vp $(DIR_INSTL)/bld/CCTM/cloud/$(ModCloud)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/cloud/$(ModCloud)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/procan
	mkdir -vp $(DIR_INSTL)/bld/CCTM/procan/$(ModPa)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/procan/$(ModPa)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/util
	mkdir -vp $(DIR_INSTL)/bld/CCTM/util/$(ModUtil)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/util/$(ModUtil)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjoint
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjoint/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)/mod
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjutil
	mkdir -vp $(DIR_INSTL)/bld/CCTM/adjutil/mod
	mkdir -vp $(DIR_INSTL)/bld/ADJPOST
	mkdir -vp $(DIR_INSTL)/bld/ADJPOST/mod

clean:
	rm -rf $(DIR_INSTL)/bld
	rm -rf $(DIR_INSTL)/lib
	rm -rf $(DIR_INSTL)/bin

###############
# GIT_VERBOSE #
###############

# Force git_verbose.F to be re-recreated every time
$(DIR_SRC)/git_verbose.F: FORCE $(DIR_SRC)/create_git_verbose.bash
	$(DIR_SRC)/create_git_verbose.bash

# Force git_verbose.o to be re-built every time
$(DIR_INSTL)/bld/git_verbose.o: FORCE $(DIR_SRC)/git_verbose.F
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 $(SUBSTS) -c $(DIR_SRC)/git_verbose.F -o $(DIR_INSTL)/bld/git_verbose.o

#########
# PARIO #
#########

$(DIR_INSTL)/bld/PARIO/%.o: $(DIR_SRC)/PARIO/%.f
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 -I$(DIR_MPI)/include $(FC_FLAG_MOD)bld/PARIO/mod -c $(DIR_SRC)/PARIO/$*.f -o $(DIR_INSTL)/bld/PARIO/$*.o


$(DIR_INSTL)/lib/PARIO/libpario.a: $(OBJ_PARIO)
	ar rv $@ $(DIR_INSTL)/bld/PARIO/*.o

#################
# STENEX NORMAL #
#################

$(DIR_INSTL)/lib/STENEX/libstenex_se_snl.a: $(OBJ_STENEX_se_snl)
	ar rv $@ $(DIR_INSTL)/bld/STENEX/se_snl/*.o

$(DIR_INSTL)/bld/STENEX/se_snl/%.o: $(DIR_SRC)/STENEX/se_snl/%.f
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_MPI)/include $(FC_FLAG_MOD)$(DIR_INSTL)/bld/STENEX/se_snl/mod -c $(DIR_SRC)/STENEX/se_snl/$*.f -o $(DIR_INSTL)/bld/STENEX/se_snl/$*.o

###############
# STENEX NOOP #
###############

$(DIR_INSTL)/lib/STENEX/libstenex_noop_f90.a: $(OBJ_STENEX_noop_f90)
	ar rv $@ $(DIR_INSTL)/bld/STENEX/noop_f90/*.o

$(DIR_INSTL)/bld/STENEX/noop_f90/%.o: $(DIR_SRC)/STENEX/noop_f90/%.f
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_MPI)/include $(FC_FLAG_MOD)$(DIR_INSTL)/bld/STENEX/noop_f90/mod -c $(DIR_SRC)/STENEX/noop_f90/$*.f -o $(DIR_INSTL)/bld/STENEX/noop_f90/$*.o

#########
# JPROC #
#########

$(DIR_INSTL)/bin/JPROC/jproc: $(OBJ_JPROC_jproc_table)
	$(FC_PAR) $(LINK_FLAGS) $^ -L$(DIR_IOAPI)/lib -lioapi -L$(DIR_NETCDF)/lib $(LIB_NETCDF) -o $@

$(DIR_INSTL)/bld/JPROC/driver/jproc_table/%.o: $(DIR_SRC)/JPROC/driver/jproc_table/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(INC_CONST) -I$(INC_MECH) $(SUBSTS) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/JPROC/driver/jproc_table/mod -c $< -o $@

########
# ICON #
########

$(DIR_INSTL)/bin/ICON/icon: $(OBJ_ICON_driver) $(OBJ_ICON_par) $(OBJ_ICON_input) $(OBJ_ICON_mech_conv)
	$(FC_PAR) $(LINK_FLAGS) $^ -L$(DIR_IOAPI)/lib -lioapi -L$(DIR_NETCDF)/lib $(LIB_NETCDF) -L$(DIR_INSTL)/lib/STENEX -lstenex_noop_f90 -o $@

$(DIR_INSTL)/bld/ICON/driver/icon/%.o: $(DIR_SRC)/ICON/driver/icon/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 -I$(INC_MECH) -I$(INC_TRAC) -I$(DIR_INSTL)/bld/STENEX/noop_f90/mod -I$(DIR_SRC)/ICON/icl/icl $(SUBSTS) $(SUBST_STENEX_NOOP) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/ICON/driver/icon/mod -c $< -o $@

$(DIR_INSTL)/bld/ICON/par/par_noop/%.o: $(DIR_SRC)/ICON/par/par_noop/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_INSTL)/bld/ICON/driver/icon/mod $(FC_FLAG_MOD)$(DIR_INSTL)/bld/ICON/par/par_noop/mod -c $< -o $@

$(DIR_INSTL)/bld/ICON/input/$(ModInpt)/%.o: $(DIR_SRC)/ICON/input/$(ModInpt)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 $(SUBSTS) -I$(INC_MECH) -I$(INC_TRAC) -I$(DIR_INSTL)/bld/ICON/driver/icon/mod -I$(DIR_SRC)/ICON/icl/icl $(FC_FLAG_MOD)$(DIR_INSTL)/bld/ICON/input/$(ModInpt)/mod -c $< -o $@

$(DIR_INSTL)/bld/ICON/mech_conv/$(DIR_ModMech)/%.o: $(DIR_SRC)/ICON/mech_conv/$(DIR_ModMech)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(INC_MECH) $(SUBSTS) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/ICON/mech_conv/$(DIR_ModMech)/mod -c $< -o $@

########
# BCON #
########

$(DIR_INSTL)/bin/BCON/bcon: $(OBJ_BCON_driver) $(OBJ_BCON_input) $(OBJ_BCON_mech_conv)
	$(FC_PAR) $(LINK_FLAGS) $^ -L$(DIR_IOAPI)/lib -lioapi -L$(DIR_NETCDF)/lib $(LIB_NETCDF) -o $@

$(DIR_INSTL)/bld/BCON/driver/bcon/%.o: $(DIR_SRC)/BCON/driver/bcon/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 -I$(INC_MECH) -I$(INC_TRAC) -I$(DIR_SRC)/BCON/icl/icl $(SUBSTS) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/BCON/driver/bcon/mod -c $< -o $@

$(DIR_INSTL)/bld/BCON/input/$(ModInpt)/%.o: $(DIR_SRC)/BCON/input/$(ModInpt)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 -I$(INC_MECH) -I$(INC_TRAC) -I$(DIR_SRC)/BCON/icl/icl -I$(DIR_INSTL)/bld/BCON/driver/bcon/mod $(SUBSTS) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/BCON/input/$(ModInpt)/mod -c $< -o $@

$(DIR_INSTL)/bld/BCON/mech_conv/$(DIR_ModMech)/%.o: $(DIR_SRC)/BCON/mech_conv/$(DIR_ModMech)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(INC_MECH) $(SUBSTS) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/BCON/mech_conv/$(DIR_ModMech)/mod -c $< -o $@

########
# CCTM #
########

LIBS=$(LIB_PARIO) -L$(DIR_INSTL)/lib/STENEX/ -lstenex_$(STENEX_POPT) -L$(DIR_IOAPI)/lib -lioapi -L$(DIR_NETCDF)/lib $(LIB_NETCDF) -L$(DIR_MPI)/lib -lmpi
F_FLAGS_ADD=-I$(DIR_MPI)/include -I$(INC_CONST) -I$(INC_FILES) -I$(INC_MECH) -I$(INC_TRAC) -I$(INC_PAR) -I$(INC_EMCTRL) -I$(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)/mod -I$(DIR_INSTL)/bld/CCTM/adjutil/mod -I$(DIR_INSTL)/bld/CCTM/driver/$(DIR_ModDriver)/mod -I$(DIR_INSTL)/bld/CCTM/vdiff/$(ModVdiff)/mod -I$(DIR_INSTL)/bld/STENEX/$(STENEX_POPT)/mod -I$(DIR_SRC)/ICL/procan/$(PAOpt) -I$(DIR_IOAPI)/fixed_src_f77 $(PAR_GOODIES) $(SUBSTS) $(SUBST_STENEX_POPT)
# There are two options for the include file for PROCAN. Not sure what the best is
#find ../repo/src/ -name PA_CTL.EXT
#../repo/src/PROCAN/icl/icl_noop/PA_CTL.EXT
#../repo/src/ICL/procan/pa/PA_CTL.EXT
#../repo/src/ICL/procan/pa_noop/PA_CTL.EXT

$(DIR_INSTL)/bin/CCTM/cctm: $(OBJ_CCTM)
	$(FC_PAR) $(LINK_FLAGS) $^ $(LIBS) -o $@

$(DIR_INSTL)/bld/CCTM/driver/$(DIR_ModDriver)/%.o: $(DIR_SRC)/CCTM/driver/$(DIR_ModDriver)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/driver/$(DIR_ModDriver)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/par/$(ModPar)/%.o: $(DIR_SRC)/CCTM/par/$(ModPar)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/par/$(ModPar)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/par/$(ModPar)/%.o: $(DIR_SRC)/CCTM/par/$(ModPar)/%.c
	$(CC_PAR) $(C_FLAGS) $(F_FLAGS_ADD) -c $< -o $@

$(DIR_INSTL)/bld/CCTM/init/$(DIR_ModInit)/%.o: $(DIR_SRC)/CCTM/init/$(DIR_ModInit)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/init/$(DIR_ModInit)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/adjcon/$(ModAdjc)/%.o: $(DIR_SRC)/CCTM/adjcon/$(ModAdjc)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/init/$(ModAdjc)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/couple/$(ModCpl)/%.o: $(DIR_SRC)/CCTM/couple/$(ModCpl)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/couple/$(ModCpl)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/hadv/$(DIR_ModHadv)/%.o: $(DIR_SRC)/CCTM/hadv/$(DIR_ModHadv)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/hadv/$(DIR_ModHadv)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/vadv/$(DIR_ModVadv)/%.o: $(DIR_SRC)/CCTM/vadv/$(DIR_ModVadv)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/vadv/$(DIR_ModVadv)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/hdiff/$(ModHdiff)/%.o: $(DIR_SRC)/CCTM/hdiff/$(ModHdiff)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/hdiff/$(ModHdiff)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/vdiff/$(ModVdiff)/%.o: $(DIR_SRC)/CCTM/vdiff/$(ModVdiff)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/vdiff/$(ModVdiff)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/phot/$(ModPhot)/%.o: $(DIR_SRC)/CCTM/phot/$(ModPhot)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/phot/$(ModPhot)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/ping/$(DIR_ModPing)/%.o: $(DIR_SRC)/CCTM/ping/$(DIR_ModPing)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/ping/$(DIR_ModPing)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/chem/$(ModChem)/%.o: $(DIR_SRC)/CCTM/chem/$(ModChem)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/chem/$(ModChem)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/aero/$(ModAero)/%.o: $(DIR_SRC)/CCTM/aero/$(ModAero)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/aero/$(ModAero)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/aero_depv/$(ModAdepv)/%.o: $(DIR_SRC)/CCTM/aero_depv/$(ModAdepv)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/aero_depv/$(ModAdepv)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/cloud/$(ModCloud)/%.o: $(DIR_SRC)/CCTM/cloud/$(ModCloud)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/cloud/$(ModCloud)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/procan/$(ModPa)/%.o: $(DIR_SRC)/CCTM/procan/$(ModPa)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/procan/$(ModPa)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/util/$(ModUtil)/%.o: $(DIR_SRC)/CCTM/util/$(ModUtil)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/util/$(ModUtil)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/adjoint/%.o: $(DIR_SRC)/CCTM/adjoint/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/adjoint/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)/%.o: $(DIR_SRC)/CCTM/adjoint/chem_$(ModAdjChem)/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)/%.o: $(DIR_SRC)/CCTM/adjoint/chem_$(ModAdjChem)/%.[Ff]90
	$(FC_PAR) $(F90_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/adjoint/chem_$(ModAdjChem)/mod -c $< -o $@

$(DIR_INSTL)/bld/CCTM/adjutil/%.o: $(DIR_SRC)/CCTM/adjutil/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) $(F_FLAGS_ADD) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/CCTM/adjutil/mod -c $< -o $@

###########
# ADJPOST #
###########

$(DIR_INSTL)/bin/ADJPOST/adjpost: $(OBJ_ADJPOST)
	$(FC_PAR) $(LINK_FLAGS) $^ -L$(DIR_IOAPI)/lib -lioapi -L$(DIR_NETCDF)/lib $(LIB_NETCDF) -o $@

$(DIR_INSTL)/bld/ADJPOST/%.o: $(DIR_SRC)/ADJPOST/%.[Ff]
	$(FC_PAR) $(F77_FLAGS) -I$(DIR_IOAPI)/fixed_src_f77 $(SUBSTS) $(FC_FLAG_MOD)$(DIR_INSTL)/bld/ADJPOST/mod -c $< -o $@
