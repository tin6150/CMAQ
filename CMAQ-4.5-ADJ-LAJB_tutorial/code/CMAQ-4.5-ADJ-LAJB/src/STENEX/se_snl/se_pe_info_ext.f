
C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_pe_info_ext.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Note: all these variables with prefix se_ are for stencil exchange library 
C       only
C
C to define processor info variables:
C
C   se_numprocs -- number of processors allocated
C   se_npcol    -- number of processors allocated along column dimension
C   se_nprow    -- number of processors allocated along row dimension
C   se_my_pe    -- my logical processor number
C --------------------------------------------------------------------------

	module se_pe_info_ext

          integer :: se_numprocs
          integer :: se_npcol
          integer :: se_nprow
          integer :: se_my_pe

        end module se_pe_info_ext
