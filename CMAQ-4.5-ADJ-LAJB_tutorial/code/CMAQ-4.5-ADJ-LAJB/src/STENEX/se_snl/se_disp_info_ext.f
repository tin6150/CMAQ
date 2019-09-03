
C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_disp_info_ext.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Note: all these variables with prefix se_ are for stencil exchange library
C       only
C
C to define maximum displacement variables:
C
C   se_mndis -- maximun displacement in the north direction
C   se_medis -- maximun displacement in the east direction
C   se_msdis -- maximun displacement in the south direction
C   se_mwdis -- maximun displacement in the west direction
C --------------------------------------------------------------------------

	module se_disp_info_ext

          integer :: se_mndis, se_medis, se_msdis, se_mwdis

        end module se_disp_info_ext
