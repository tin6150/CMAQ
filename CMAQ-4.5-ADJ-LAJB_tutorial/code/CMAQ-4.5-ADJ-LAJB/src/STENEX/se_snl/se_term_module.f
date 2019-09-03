C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_term_module.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Purpose:
C
C   to terminate stenex library
C
C Revision history:
C
C   Orginal version: 11/30/00 by David Wong
C --------------------------------------------------------------------------

        module se_term_module

          implicit none

          contains

	  subroutine se_term 

	  use se_domain_info_ext

  	  implicit none

          integer :: error

          deallocate (se_gl_ind)

          return
          end subroutine se_term 

        end module se_term_module
