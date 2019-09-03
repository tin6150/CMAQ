/****************************************************************************
 *
 * Project Title: Environmental Decision Support System
 * File: @(#)sms.h	11.1
 *
 * COPYRIGHT (C) 1995, MCNC--North Carolina Supercomputing Center
 * All Rights Reserved
 *
 * See file COPYRIGHT for conditions of use.
 *
 * Environmental Programs Group
 * MCNC--North Carolina Supercomputing Center
 * P.O. Box 12889
 * Research Triangle Park, NC  27709-2889
 *
 * env_progs@mcnc.org
 *
 * Pathname: /pub/storage/edss/framework/src/model_mgr/bldmod/SCCS/s.sms.h
 * Last updated: 08 Jul 1996 16:42:54
 *
 ****************************************************************************/


#include <sys/types.h>

#include "edssTypes.h"

#if defined(CRAY) || defined(__osf__) || _WIN32 || __unix__
typedef unsigned char boolean_t;
#define B_TRUE 1
#define B_FALSE 0
#endif	/* CRAY */

/* changed to 256 from 128: tlt 15aug95 */
/* changed to 1024 from 256  sch 8oct98  */
/* changed to 2048 from 1024  sch 28may99  */
#define NAME_SIZE 2048

#define N_INCLUDE_FILES (100)
#define N_SRC_FILES (250)
#define N_MODULES (25)
#define N_GRIDS (30)

/*
 * errors
 */
#define ERROR_MEMORY_FULL	1001	/* there was not enough memory */
#define ERROR_FILE			1002	/* a file was not found or did not
									 * have the proper state */
#define ERROR_GET			1003	/* the SCCS get command failed */
#define ERROR_RM			1004	/* problem during rm */
#define ERROR_LN			1005	/* problem during ln */
#define ERROR_MV			1006	/* problem during mv */
#define ERROR_UNCERTAIN_REPLACE 1007 	/* it's not clear that we should
										 * replace the file. */
#define ERROR_DUPE			1008	/* two files have the same name */
#define ERROR_STRING_LENGTH	1009	/* a string is too long */
#define ERROR_UNAME			1010	/* error calling uname */
#define ERROR_RESOLVE_MODULE 1011	/* error resolving directory for
									 * module */
#define ERROR_CD			1012	/* error in changing directory */
#define ERROR_INVALID_OPTION 1013	/* invalid option or combination
									 * of options */

/* tim's return values */
#define FAILURE (-1)
#define SUCCESS (0)

/* the enumerations in lang_type are used as indices in static table lang_tab
   in file sms.c.  If you change this typedef, you have to change the table
   as well */
   
typedef enum
	{
	c_lang,
	c_plus_plus_lang,
	f_lang,
	h_lang,
	hh_lang,
	ext_lang,
	other_lang		/* other_lang should be last in the list */
	} lang_type;

typedef enum
	{
	file_src,		    /* a g-file */
	latest_release_src,	/* the release version, a g-file */
	dev_src,		    /* the development version, an s-file */
	version_src,		/* a specified version, and s-file */
	release_time_src,	/* the latest version at a specified time, and s-file */
 	local_dir		/* location of file is in local directory */
	} source_type;

typedef enum
	{
	parse_mode,
	/* show_mode, */
	no_compile_mode,
	no_link_mode,
	build_mode
	} mode_type;

typedef enum
	{
	sams_default_archive,
	local_archive,
	remote_archive
	} archive_location_type;
	
typedef enum
	{
	irix4_os,
	irix5_os,
	sunos5_os,
	osf1_os,
	cray_os,
	win_32,
	other_os
	} os_type;

typedef struct
	{
	char dirname[NAME_SIZE];
	char filename[NAME_SIZE];
	} filename_type;	/* used internally by parser and scanner */

typedef struct
	{
	char module_name[NAME_SIZE];
	char dirname[NAME_SIZE];
	char filename[NAME_SIZE];
	lang_type language;
	source_type where;
	char version_num[16];    /* rrr.vvv.bbb.sss */
	char date[7];	   /* yymmdd */
	char time[7];	   /* hhmmss */
	char cpp_flags[NAME_SIZE]; 
	char def_flags[NAME_SIZE]; 
	char compile_flags[NAME_SIZE];
	} file_struct_type;

typedef struct
	{
	int array_size;
	int list_size;
	file_struct_type * curr_ptr;
	file_struct_type list[N_SRC_FILES];
	} file_list_type;

typedef struct
	{
	char module_name[NAME_SIZE];
	source_type where;
	char dirname[NAME_SIZE];
	char version_num[16];    /* rrr.vvv.bbb.sss */
	char date[7];	   /* yymmdd */
	char time[7];	   /* hhmmss */
	char cpp_flags[NAME_SIZE];
	char def_flags[NAME_SIZE];
   	char compile_flags[other_lang + 1][NAME_SIZE];
	} module_struct_type;

typedef struct
	{
	int array_size;
	int list_size;
	module_struct_type * curr_ptr;
	module_struct_type list[N_MODULES];
	} module_list_type;

typedef struct
    {
    char symbolname[NAME_SIZE];
    char dirname[NAME_SIZE];
    char filename[NAME_SIZE];
    boolean_t apply_grid_names;
    } include_struct_type;

typedef struct
    {
    int array_size;
    int list_size;
    include_struct_type * curr_ptr;
    include_struct_type list[N_INCLUDE_FILES];
    } include_list_type;

typedef char gridname_type[NAME_SIZE];

typedef struct
	{
    int array_size;
    int list_size;
    gridname_type * curr_ptr;
	gridname_type list[N_GRIDS];
	} grid_list_type;

typedef struct
	{
	char description[NAME_SIZE];
	char architecture[32];
	char os_name_vers[32];	     /* name [+ version] */
	os_type os;
	char exename[NAME_SIZE];
	boolean_t verbose;
	mode_type mode;
	boolean_t show_only;
	boolean_t make;
	boolean_t compile_all;
	boolean_t one_step;
	boolean_t clean_up;
	boolean_t fast_check;
	archive_location_type archive_location;
	char wd[NAME_SIZE];	/* working directory */
	char compilers[other_lang + 1][NAME_SIZE];
	char fpp[NAME_SIZE];
	char cpp_flags[NAME_SIZE];
	char def_flags[NAME_SIZE];
	char compile_flags[other_lang + 1][NAME_SIZE + NAME_SIZE];
	char libraries[NAME_SIZE];
	char link_flags[NAME_SIZE];
	include_list_type includes;
	grid_list_type grids;
	module_list_type modules;
	file_list_type files;
	file_list_type local_files;
	file_list_type archive_files;
	} model_def_type;


/* methods */
/* module methods */
int get_module_dirname ( char module_name[], char dirname[] );
int get_module_files ( char module_name[], file_list_type * file_list, 
                       source_type module_src, char version[], char date[] );
/* int get_all_module_files ( module_list_type * module_list, file_list_type * file_list );
*/
int get_all_module_files ( model_def_type * model );
 
/* int merge_file_lists 
	( 
	module_list_type * module_list,
	file_list_type * archive_list,
	file_list_type * local_list, 
	file_list_type * merged_list
	); */
int merge_file_lists ( model_def_type * model );

/* file methods */
lang_type get_file_type ( char filename[] );
void copy_file_struct ( file_struct_type * from_struct, 
                        file_struct_type * to_struct );

/* file list methods */
void init_file_list ( file_list_type * file_list );
int append_file ( file_list_type * file_list );
void first_file ( file_list_type * file_list );
void last_file ( file_list_type * file_list );
int next_file ( file_list_type * file_list );
void print_file_struct ( file_struct_type * file );
void print_file_list ( file_list_type * list );

/* module list methods */
void init_module_struct ( module_struct_type * module );
void init_module_list ( module_list_type * module_list );
int append_module ( );
void first_module ( module_list_type * module_list );
void last_module ( module_list_type * module_list );
int next_module ( module_list_type * module_list );
void print_module_struct ( module_struct_type * module );
void print_module_list ( module_list_type * list );

/* include list methods */
void init_include_list ( include_list_type * include_list );
int append_include ( include_list_type * include_list );
void first_include ( include_list_type * include_list );
void last_include ( include_list_type * include_list );
int next_include ( include_list_type * include_list );
void print_include_struct ( include_struct_type * include );
void print_include_list ( include_list_type * list );

/* grid list methods */
void init_grid_list ( grid_list_type * grid_list );
int append_grid ( grid_list_type * grid_list );
void first_grid ( grid_list_type * grid_list );
void last_grid ( grid_list_type * grid_list );
int next_grid ( grid_list_type * grid_list );
void print_gridname ( gridname_type * grid );
void print_grid_list ( grid_list_type * list );

/* model def methods */
void init_model_def ( model_def_type * model_def );
void print_model_def ( model_def_type * model_def );

/* yacc and lex routines */
int bld_parse ( model_def_type * model );
int yylex();
void yyerror ( char *s );

/* string manipulation routines */
int string_cat ( char * dest, const char * src, int array_size );
int string_copy ( char * dest, const char * src, int array_size );
int resolve_name ( const char * input, char * output, int array_size );

/* from action.c */
int retrieve_and_build(model_def_type *pglobal);
