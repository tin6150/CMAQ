%{
/****************************************************************************
 *
 * Project Title: Environmental Decision Support System
 * File: @(#)bld_parser.y	11.1
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
 * Pathname: /pub/storage/edss/framework/src/model_mgr/bldmod/SCCS/s.bld_parser.y
 * Last updated: 08 Jul 1996 16:41:38
 *
 ****************************************************************************/

/*******************************************************************************
*
*       NAME:	bld_parser.y
*
*   FUNCTION:	parses sms build file source, returning list of file 
*               descriptors.  
*
*      USAGE:	model_type model;
*               status = bld_parse ( & model );
*
*       DATE:	1 June 1994
*
*     AUTHOR:	Tim Turner
*
*   COMMENTS:	
*
*  REVISIONS:	
	
	10/19/94	Tim Turner
	Formerly a module name within a module statement could be either a
	directory or an identifier.  Now it can only be an identifier. 
*
*******************************************************************************/

/* #define PARSE_DEBUG */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "sms.h"
char bld_parser_SCCS_ID[] = "@(#)bld_parser.y	1.23 /pub/storage/edss/framework/devtool/build/SCCS/s.bld_parser.y 27 Jun 1994 10:55:15";

extern int yylineno;			/* line number maintained by yylex() */

/*  prototype for strscan function  */
int strscan( char *, char * );
int strtran( char* strng, char* sub1, char* sub2 );
void substr( char* str1, int kstart, int klen, char* sub );

/* directory info */
static char ldirname[NAME_SIZE];

/* suffix for miscellaneous module name */
static int misc_id = 0;

/* options info */
static enum { global_level, module_level, file_level } options_level;
lang_type file_lang;



/* function to replace $xxxx with %xxxx% used for DOS enviromental variables */
void dos_env( char* fname )
{
   int i,pos1,pos2;
   char oldstr[35];
   char newstr[35];
   char vname[35];


        while( (pos1=strscan( "$", fname)) >=0 )
        {
            if(fname[pos1+1]=='{')    /*  check for ${xxxxx} string */
            {
               pos2=strscan( "}",&fname[pos1]);
               if(pos2 > 1 && pos2 <30)
               {
                  substr( fname, pos1, pos2+1, oldstr );
                  substr( fname, pos1+2, pos2-2, vname );
                  strcpy( newstr, "%" );
                  strcat( newstr, vname );
                  strcat( newstr, "%");
                  strtran( fname, oldstr, newstr );
                  continue;
               }
            }

            /*  check for $xxxxx string */
            pos2 = 0;
            for(i=pos1+1; i<pos1+30 && pos2==0 && fname[i]!='\0'; i++)
               if( fname[i] < '0' ||
                   (fname[i]>'9' && fname[i]<'A') ||
                   (fname[i]>'Z' && fname[i]<'a') ||
                    fname[i]>'z' ) pos2=i;

            if(pos2==0) return;  /*  cannot find end of variable string */

            substr( fname, pos1, pos2-pos1, oldstr );
            substr( fname, pos1+1, pos2-pos1-1, vname );
            strcpy( newstr, "%" );
            strcat( newstr, vname );
            strcat( newstr, "%");
            strtran( fname, oldstr, newstr );
        }

return;
}


/* function to reverse slashes for DOS files */
void dos_slash( char* fname )
{
#ifdef _WIN32
	int i;

	/*  replace all backslashes used for line continuations with spaces  */
	for(i=0; fname[i]!='\0'; i++) if(fname[i]==92 && fname[i+1]==10)
	  fname[i]=' ';

        /*  replace UNIX $xxxx with DOS %xxxx% environmental variables */
        dos_env( fname );

	/*  replace slashes with backslashes  */
	for(i=0; fname[i]!='\0'; i++) if(fname[i]=='/') fname[i] = 92;
#endif
return;
}

/* function to reverse slashes for Include path in compile flags for win32 */
char* cmp_flags( char* flags )
{
#ifdef _WIN32
        int i,loc,j;

        /*  replace UNIX $xxxx with DOS %xxxx% environmental variables */
        dos_env( flags );


        /*  search for /I in flags string  */
        loc=strscan("/I", flags);
        if( loc >= 0 )
        {
           j=0;
           for(i=loc+2; flags[i]!='\0' && j<2; i++)
           {
                  if(flags[i]=='/') flags[i] = 92;
                  if(j==0 && flags[i]!=' ') j=1;
                  if(j==1 && flags[i]==' ') j=2;

           }
        }
        return flags;

        /*  search for -I in flags string  */
        loc=strscan("-I", flags);
        if( loc >= 0 )
        {
           j=0;
           for(i=loc+2; flags[i]!='\0' && j<2; i++)
           {
                  if(flags[i]=='/') flags[i] = 92;
                  if(j==0 && flags[i]!=' ') j=1;
                  if(j==1 && flags[i]==' ') j=2;

           }
        }


#endif
return flags;
}

%}

%union 
	{
	int int_value;
	float float_value;
	char string_value[NAME_SIZE];
	filename_type file;
	}

%token ASSIGN
%token <file> FILENAME
%token <file> DIRNAME
%token MODEL
%token MODULE
%token MISC
%token RELEASE
%token DEVELOPMENT
%token LATEST
%token INCLUDE
%token APPLY_GRID_NAMES
%token GLOBAL
%token VERBOSE
%token PARSE_ONLY
%token SHOW_ONLY
%token NO_COMPILE
%token NO_LINK
%token COMPILE_ALL
%token ONE_STEP
%token CLEANUP
%token DEFAULT_DIR
%token GRID
%token C_COMPILER
%token CPLUS_COMPILER
%token F_COMPILER
%token C_FLAGS
%token CPLUS_FLAGS
%token F_FLAGS
%token FPP     
%token CPP_FLAGS
%token DEF_FLAGS
%token LIBRARIES
%token LINK_FLAGS
%token <string_value> STRING
%token <string_value> IDENTIFIER
%token <int_value> INTEGER
%token D_OPTION
%token DOT
%token LEFT_CURL
%token RIGHT_CURL
%token COMMA
%token LEFT_PAREN
%token RIGHT_PAREN
%token SEMICOLON
%token HYPHEN
%token TILDE
%token SLASH

%%
program			:	program_entry globals modules program_end
				;


program_entry	:	/* empty */
				{
#				ifdef PARSE_DEBUG
				printf ( "bld_parser.y:  PARSE_DEBUG is defined\n" );				
#				endif

				ldirname[0] = (char) '\0';
				options_level = global_level;
				misc_id = 0;
				}
				;


program_end		:	/* empty */ 
				{
				/* get_all_module_files ( model ); */
				
#				ifdef PARSE_DEBUG				
				printf ( "archive " );
				print_file_list ( & ( model->archive_files ) );
				
				printf ( "local " );
				print_file_list ( & ( model->local_files ) );
#				endif

				/* merge_file_lists ( model ); */
				}
				;

string			:	STRING
				{
				strcpy ( $<string_value>$, $1 );
				}
				|	string STRING
				{
				/*********
				sprintf ( $<string_value>$, "%s %s%s", 
				          $<string_value>1, "\\\n", $2 );
				**********/
				strcpy ( $<string_value>$, $<string_value>1 );
				string_cat ( $<string_value>$, "\\\n", NAME_SIZE );
				string_cat ( $<string_value>$, $2, NAME_SIZE );
				}
				;
				
globals			:	MODEL identifier SEMICOLON global_defines
				{
				strcpy ( model->exename, $<string_value>2 );
				/* printf ( "model name is '%s'\n", model->exename ); */
				}
				|	MODEL identifier remark SEMICOLON global_defines
				{
				strcpy ( model->exename, $<string_value>2 );
				/* printf ( "model name is '%s'\n", model->exename ); */
				strcpy ( model->description, $<string_value>3 );
				}
				;

remark			:	string
				{
				strcpy ( $<string_value>$, $<string_value>1 );
				}

global_defines	:	global_define
				|	global_defines global_define
				|	/* empty */
				;

global_define	:	include_statement
				|	global_statement
				|	grid_statement
				|	default_dir
				|	compiler_exe
				|	preprocessor
				|	compiler_flags
				|	libraries
				|	link_flags
				;

include_statement	:	include_head SEMICOLON
				{
				model->includes.curr_ptr->apply_grid_names = B_FALSE;
				}
				|	include_head APPLY_GRID_NAMES SEMICOLON
				{
				model->includes.curr_ptr->apply_grid_names = B_TRUE;
				}
				;
 
include_head	:	INCLUDE identifier filename 
				{
				append_include ( & ( model->includes ) );
				strcpy ( model->includes.curr_ptr->symbolname, $<string_value>2 );
				strcpy ( model->includes.curr_ptr->dirname, $<file>3.dirname );
				strcpy ( model->includes.curr_ptr->filename, $<file>3.filename );
				dos_slash( model->includes.curr_ptr->dirname );
				dos_slash( model->includes.curr_ptr->filename );
				/* printf ( "includename %s = %s%s\n", $<string_value>2, $<file>3.dirname, $<file>3.filename ); */
				}
				;

global_statement	:	GLOBAL global_flags SEMICOLON
				;

global_flags	:	global_flag
				|	global_flags global_flag
				;

global_flag		:	VERBOSE
				{
				model->verbose = B_TRUE;
				}
				|	NO_COMPILE
				{
				model->mode = no_compile_mode;
				}
				|	NO_LINK
				{
				model->mode = no_link_mode;
				}
				|	SHOW_ONLY
				{
				model->show_only = B_TRUE;
				}
				|	PARSE_ONLY
				{
				model->mode = parse_mode;
				}
				|	COMPILE_ALL
				{
				model->compile_all = B_TRUE;
				}
				|	ONE_STEP
				{
				model->one_step = B_TRUE;
				}
				|	CLEANUP
				{
				model->clean_up = B_TRUE;
				}
				;

grid_statement	:	GRID grids SEMICOLON;
				;

grids			:	grid
				|	grids grid
				;

grid			:	identifier
				{
				append_grid ( & ( model->grids ) );
				strcpy ( * ( model->grids.curr_ptr ), $<string_value>1 );
				}
				;

default_dir		:	DEFAULT_DIR dirname SEMICOLON
				{
				switch ( (int) $<file>2.dirname[0] )
					{
					case '/':
						strcpy ( model->wd, $<file>2.dirname );
						break;

					case '~':
						if ( $<file>2.dirname[1] != (char) '/' )
							{
							fprintf ( stderr, "Can't handle dirname %s. Exiting\n", $<file>2.dirname );
							return (1);
							}

						string_copy ( model->wd, getenv ( "HOME" ), NAME_SIZE );
						string_cat ( model->wd, $<file>2.dirname + 1, NAME_SIZE );
						break;

					case '.':
						string_copy ( model->wd, getenv ( "PWD" ), NAME_SIZE );

						printf ( "PWD is %s\n", model->wd );

						string_cat ( model->wd, "/", NAME_SIZE );

						if ( $<file>2.dirname[1] == (char) '/' )
							{
							string_cat ( model->wd, $<file>2.dirname + 2, NAME_SIZE );
							}
						else
							{
							string_cat ( model->wd, $<file>2.dirname, NAME_SIZE );
							}

						break;

					default:
						string_copy ( model->wd, getenv ( "PWD" ), NAME_SIZE );
						string_cat ( model->wd, "/", NAME_SIZE );
						string_cat ( model->wd, $<file>2.dirname, NAME_SIZE );
						break;
					}
				}
				;

compiler_exe	:	C_COMPILER filename SEMICOLON
				{
				sprintf ( model->compilers[c_lang], "%s%s", $<file>2.dirname,
				          $<file>2.filename );
				dos_slash( model->compilers[c_lang] );
				}
				|	CPLUS_COMPILER filename SEMICOLON
				{
				sprintf ( model->compilers[c_plus_plus_lang], "%s%s", $<file>2.dirname,
				          $<file>2.filename );
				dos_slash( model->compilers[c_plus_plus_lang] );
				}
				|	F_COMPILER filename SEMICOLON
				{
				sprintf ( model->compilers[f_lang], "%s%s", $<file>2.dirname,
				          $<file>2.filename );
				dos_slash( model->compilers[f_lang] );
				}
				;

preprocessor    :       FPP filename SEMICOLON
                                {
                                sprintf ( model->fpp, "%s%s", $<file>2.dirname,
                                          $<file>2.filename );
                                dos_slash( model->fpp );
                                }
                                ;
 
compiler_flags	:	C_FLAGS	string SEMICOLON
				{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->compile_flags[c_lang], 
						         $<string_value>2 );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->compile_flags[c_lang], 
						         $<string_value>2 );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				}
				|	CPLUS_FLAGS string SEMICOLON
				{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->compile_flags[c_plus_plus_lang], 
						         $<string_value>2 );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->compile_flags[c_plus_plus_lang], 
						         $<string_value>2 );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				}
				|	F_FLAGS string SEMICOLON
				{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->compile_flags[f_lang], 
						         $<string_value>2 );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						/* printf ( "assigning f flags %s to model->modules.curr_ptr->compile_flags[%d]\n", 
						            $<string_value>2, (int) f_lang ); */
						strcpy ( model->modules.curr_ptr->compile_flags[f_lang], 
						         $<string_value>2 );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				}
				|	CPP_FLAGS string SEMICOLON
				{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->cpp_flags, $<string_value>2 );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->cpp_flags, 
						         $<string_value>2 );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				}
				|	DEF_FLAGS string SEMICOLON
				{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->def_flags, $<string_value>2 );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->def_flags, 
						         $<string_value>2 );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				}
				;


libraries		:	LIBRARIES string SEMICOLON
				{
#				ifdef PARSE_DEBUG
				printf ( "libraries input string is:\n\"%s\"\n", $<string_value>2 );
#				endif

				strcpy ( model->libraries, $<string_value>2 );
				dos_slash( model->libraries );
				
#				ifdef PARSE_DEBUG
				printf ( "libraries string is:\n\"%s\"\n", model->libraries );
				printf ( "link_flags string is:\n%s\n", model->link_flags );
#				endif
				}
				;

link_flags		:	LINK_FLAGS string SEMICOLON
				{
				strcpy ( model->link_flags, $<string_value>2 );
				}
				;

modules			:	module
				| 	modules module
				/*|*/	/* empty */
				;

module			:	module_statement 
				{
				options_level = module_level;

				/* now use global default directory as starting point for
				   any further files */
				string_copy ( ldirname, model->wd, NAME_SIZE );
				}
					module_defs 
				{
				}
					module_file_groups
				{
				strcpy ( ldirname, "" );
				}
				;

module_statement	:	module_head module_version SEMICOLON
				{
				(model->modules.curr_ptr)->where = version_src;
				strcpy ( (model->modules.curr_ptr)->version_num,
				         $<string_value>2 );
				}
				|	module_head string SEMICOLON
				{
				(model->modules.curr_ptr)->where = version_src;
				strcpy ( (model->modules.curr_ptr)->version_num,
				         $<string_value>2 );
				}
				|	module_head D_OPTION string SEMICOLON
				{
				(model->modules.curr_ptr)->where = local_dir;  
				strcpy ( (model->modules.curr_ptr)->dirname,    
				         $<string_value>3 );
				dos_slash( (model->modules.curr_ptr)->dirname );
				}
				|	module_head RELEASE SEMICOLON
				{
				(model->modules.curr_ptr)->where = latest_release_src;
				}
				|	module_head DEVELOPMENT SEMICOLON
				{
				(model->modules.curr_ptr)->where = dev_src;
				}
				|	module_head LATEST SEMICOLON
				{
				(model->modules.curr_ptr)->where = latest_release_src;
				fprintf ( stderr, "source type LATEST not supported\n" );
				}
				|	module_head date SEMICOLON
				{
				(model->modules.curr_ptr)->where = release_time_src;
				strcpy ( (model->modules.curr_ptr)->date, $<string_value>2 );
				}
				|	module_head SEMICOLON
				{
				(model->modules.curr_ptr)->where = latest_release_src;
#				ifdef PARSE_DEBUG
				printf ( "module source is %d\n", 
				         (model->modules.curr_ptr)->where );
#				endif
				}
				|	MISC SEMICOLON
				{
				append_module ( & ( model->modules ) );
				init_module_struct ( model->modules.curr_ptr );

				misc_id++;
				sprintf ( model->modules.curr_ptr->module_name, "#misc_%02d", misc_id );

				(model->modules.curr_ptr)->where = file_src;
				}
				;

module_head		:	MODULE module_name
				{				
				/* create entry in module_list */
				append_module ( & ( model->modules ) );
				init_module_struct ( model->modules.curr_ptr );
				strcpy ( (model->modules.curr_ptr)->module_name, 
				         $<string_value>2 );
				}
				;
				
module_name		:	identifier
				{
				/* strcpy ( $<string_value>$, $<string_value>1 ); */
				}
				;

module_version		:	INTEGER
				{
				sprintf ( $<string_value>$, "%d", $1 ); 
				}
				;

date			:	INTEGER HYPHEN INTEGER HYPHEN INTEGER
				{
				sprintf ( $<string_value>$, "%.2d%.2d%.2d", $1, $3, $5 );
				}
				;

module_defs		:	module_def
				|	module_defs module_def
				|	/* empty */
				;

module_def		:	compiler_flags /* for now */
				;

module_file_groups	:	module_file_group
				|	module_file_groups module_file_group
				|	/* empty */
				;

module_file_group	:	dirname 
				{
				switch ( (int) $<file>1.dirname[0] )
					{
					case '/':
						strcpy ( ldirname, $<file>1.dirname );
						dos_slash( ldirname );
						break;

					case '~':
						if ( $<file>1.dirname[1] != (char) '/' )
							{
							fprintf ( stderr, "Can't handle dirname %s. Exiting\n", $<file>1.dirname );
							return (1);
							}

						string_copy ( ldirname, getenv ( "HOME" ), NAME_SIZE );
						string_cat ( ldirname, $<file>1.dirname + 1, NAME_SIZE );
						dos_slash( ldirname );
						break;

					case '.':
						string_copy ( ldirname, model->wd, NAME_SIZE );

						if ( $<file>1.dirname[1] == (char) '/' )
							{
							strcat ( ldirname, $<file>1.dirname + 2 );
							}
						else
							{
							strcat ( ldirname, $<file>1.dirname );
							}

						dos_slash( ldirname );

						break;

					default:
						string_copy ( ldirname, model->wd, NAME_SIZE );
						strcat ( ldirname, $<file>1.dirname );
						dos_slash( ldirname );
						break;
					}

#				ifdef PARSE_DEBUG
				printf ( "dirname = %s\n", ldirname );
#				endif
				}
					module_files
				|	module_files
				;

module_files	:	module_file
				|	module_files module_file
				;

module_file		:	filename
				{
				/* if this filename matches one which already
				   exists for this module, replace the old one */
					/* this is a new filename.  Make a new list entry */

				append_file ( & ( model->local_files ) );
				string_copy ( model->local_files.curr_ptr->module_name, 
				         model->modules.curr_ptr->module_name, NAME_SIZE );

				if ( ( $<file>1.dirname[0] != '/' ) &&
				     ( $<file>1.dirname[0] != '~' ) )
					{
#					ifdef PARSE_DEBUG
					printf ( "prepending current dirname %s to pathname\n",
					         ldirname );
#					endif

					string_copy ( model->local_files.curr_ptr->dirname, 
					              ldirname, NAME_SIZE );
					}
				else
					{
					model->local_files.curr_ptr->dirname[0] = '\0';
					}

				strcat ( model->local_files.curr_ptr->dirname, $<file>1.dirname );
				strcpy ( model->local_files.curr_ptr->filename, $<file>1.filename );
				dos_slash( model->local_files.curr_ptr->dirname );
				dos_slash( model->local_files.curr_ptr->filename );

				/* now get language type */
				model->local_files.curr_ptr->language = 
					file_lang = get_file_type ( $<file>1.filename );

				model->local_files.curr_ptr->where = file_src;

				/* get module options */
#				ifdef PARSE_DEBUG
				printf ( "inserting module-level flags into file %s%s\n",
				         $<file>1.dirname, $<file>1.filename );
				printf ( "language is %d, flags = %s\n", file_lang,
				         model->modules.curr_ptr->compile_flags[file_lang] );
#				endif

				string_copy ( model->local_files.curr_ptr->cpp_flags, 
				              model->modules.curr_ptr->cpp_flags, NAME_SIZE );
				string_copy ( model->local_files.curr_ptr->compile_flags,
				         model->modules.curr_ptr->compile_flags[file_lang],
				         NAME_SIZE );

#				ifdef PARSE_DEBUG
				printf ( "filename = %s%s\n", 
				         $<file>1.dirname, $<file>1.filename );
#				endif
				}

identifier 		:	IDENTIFIER
				{
				resolve_name ( $1, $<string_value>$, NAME_SIZE );
				}

dirname 		:	DIRNAME
				{
				resolve_name ( $1.dirname, $<file>$.dirname, NAME_SIZE );
				resolve_name ( $1.filename, $<file>$.filename, NAME_SIZE );
				}

filename 		:	FILENAME
				{
				resolve_name ( $1.dirname, $<file>$.dirname, NAME_SIZE );
				resolve_name ( $1.filename, $<file>$.filename, NAME_SIZE );
				}
%%
#include <stdio.h>

void yyerror(s)

	char *s;
	{
	fprintf ( stderr, "bldmod: %s at line number %d\n", s, yylineno );
 	}
