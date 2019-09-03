C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/STENEX/src/se_snl/se_modules.f,v 1.1.1.1 2005/09/09 18:58:42 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C --------------------------------------------------------------------------
C Purpose:
C
C   to provide an interface between the stencil exchange library and the
C application code
C
C Revision history:
C
C   Orginal version: 11/05/99 by David Wong
C                    02/27/01 by David Wong
C                      -- include two use statements: use se_term_module and
C                         use se_reconfig_grid_module
C                    11/27/01 by David Wong
C                      -- include a new module: se_bndy_copy_module
C --------------------------------------------------------------------------

	module se_modules

          use se_init_module
          use se_term_module

          use se_util_module

          use se_comm_module
          use se_slice_module
          use se_data_copy_module
          use se_gather_module

          use se_reconfig_grid_module

          use se_bndy_copy_module

          use se_global_max_module
          use se_global_min_module
          use se_global_sum_module

        end module se_modules
