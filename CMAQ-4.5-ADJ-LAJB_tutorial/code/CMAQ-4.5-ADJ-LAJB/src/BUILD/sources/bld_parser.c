/* RCS file, release, date & time of last delta, author, state, [and locker] */
/* $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/BUILD/src/sources/bld_parser.c,v 1.1.1.1 2005/09/09 19:26:42 sjr Exp $  */

/* what(1) key, module and SID; SCCS file; date and time of last delta: */
/* %W% %P% %G% %U% */

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
 * Last updated: 29 Jan 2001
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



typedef union
#ifdef __cplusplus
	YYSTYPE
#endif
 
	{
	int int_value;
	float float_value;
	char string_value[NAME_SIZE];
	filename_type file;
	} YYSTYPE;
# define ASSIGN 257
# define FILENAME 258
# define DIRNAME 259
# define MODEL 260
# define MODULE 261
# define MISC 262
# define RELEASE 263
# define DEVELOPMENT 264
# define LATEST 265
# define INCLUDE 266
# define APPLY_GRID_NAMES 267
# define GLOBAL 268
# define VERBOSE 269
# define PARSE_ONLY 270
# define SHOW_ONLY 271
# define NO_COMPILE 272
# define NO_LINK 273
# define COMPILE_ALL 274
# define ONE_STEP 275
# define CLEANUP 276
# define DEFAULT_DIR 277
# define GRID 278
# define C_COMPILER 279
# define CPLUS_COMPILER 280
# define F_COMPILER 281
# define C_FLAGS 282
# define CPLUS_FLAGS 283
# define F_FLAGS 284
# define FPP 285
# define CPP_FLAGS 286
# define DEF_FLAGS 287
# define LIBRARIES 288
# define LINK_FLAGS 289
# define STRING 290
# define IDENTIFIER 291
# define INTEGER 292
# define D_OPTION 293
# define DOT 294
# define LEFT_CURL 295
# define RIGHT_CURL 296
# define COMMA 297
# define LEFT_PAREN 298
# define RIGHT_PAREN 299
# define SEMICOLON 300
# define HYPHEN 301
# define TILDE 302
# define SLASH 303


#ifdef __STDC__
#include <stdlib.h>
#include <string.h>
#else
#include <malloc.h>
#include <memory.h>
#endif

#ifndef _WIN32
#include <values.h>
#endif

#if defined(__cplusplus) || defined(__STDC__)

#if defined(__cplusplus) && defined(__EXTERN_C__)
extern "C" {
#endif
#ifndef yyerror
#if defined(__cplusplus)
	void yyerror(const char *);
#endif
#endif
#ifndef yylex
	int yylex(void);
#endif
	int bld_parse ( model_def_type * model );
#if defined(__cplusplus) && defined(__EXTERN_C__)
}
#endif

#endif

#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern int yyerrflag;
YYSTYPE yylval;
YYSTYPE yyval;
typedef int yytabelem;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#if YYMAXDEPTH > 0
int yy_yys[YYMAXDEPTH], *yys = yy_yys;
YYSTYPE yy_yyv[YYMAXDEPTH], *yyv = yy_yyv;
#else	/* user does initial allocation */
int *yys;
YYSTYPE *yyv;
#endif
static int yymaxdepth = YYMAXDEPTH;
# define YYERRCODE 256

#include <stdio.h>

void yyerror(s)

	char *s;
	{
	fprintf ( stderr, "bldmod: %s at line number %d\n", s, yylineno );
 	}

static const yytabelem yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 85
# define YYLAST 234
static const yytabelem yyact[]={

    86,    90,    89,    87,    88,    91,    92,    93,    19,    20,
    21,    41,    41,   119,    12,    41,    41,    41,    41,    41,
    48,   131,   130,   123,    41,   118,   117,   116,   115,   114,
    83,   121,    41,    25,    79,    25,   129,    24,    18,    70,
   128,    61,    42,    29,   127,    23,   126,   125,   120,    71,
    63,    62,    64,    65,    66,    35,    36,    37,    67,    38,
    39,    68,    69,    82,    47,    46,    45,    44,    40,    26,
   136,    80,    12,    35,    36,    37,    25,    38,    39,    41,
    86,    90,    89,    87,    88,    91,    92,    93,    10,     9,
   100,    98,   100,     4,    98,   112,   111,   113,    50,   109,
    95,    85,    17,   110,    96,    49,     6,   134,    27,    11,
    57,    33,    14,    22,    31,    28,    16,     8,   108,    72,
    32,    43,    15,     7,    94,    84,    34,    60,    59,    58,
    56,    55,    54,    53,    52,    51,    30,    13,    74,    75,
    76,    77,    78,    34,    73,     5,     3,     2,    81,     1,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,    99,   101,   102,   103,     0,    97,     0,     0,
     0,   104,   105,     0,     0,   106,     0,   107,     0,     0,
     0,     0,     0,     0,     0,     0,   122,     0,     0,     0,
     0,     0,     0,     0,     0,   124,     0,     0,     0,     0,
     0,     0,     0,     0,   132,     0,    81,   135,   133,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,   137,     0,   135 };
static const yytabelem yypact[]={

-10000000,-10000000,  -167,  -173,  -219,  -173,-10000000,-10000000,  -255,  -231,
  -219,  -257,-10000000,-10000000,-10000000,  -209,  -232,  -258,  -214,  -233,
  -234,  -235,  -236,-10000000,  -281,-10000000,-10000000,-10000000,-10000000,  -227,
  -251,  -211,  -209,-10000000,-10000000,  -214,  -214,  -214,  -214,  -214,
-10000000,-10000000,-10000000,  -266,-10000000,-10000000,-10000000,-10000000,  -221,  -227,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
  -237,  -189,  -219,  -165,  -166,  -166,  -166,  -166,  -214,  -214,
  -219,  -227,  -168,-10000000,  -271,  -272,  -273,  -274,  -275,-10000000,
  -288,-10000000,-10000000,  -252,  -269,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,  -277,-10000000,-10000000,  -253,-10000000,  -254,
-10000000,  -256,  -260,  -264,  -278,  -279,  -166,  -227,  -168,-10000000,
-10000000,  -166,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,  -222,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,  -166,-10000000,-10000000,  -166 };
static const yytabelem yypgo[]={

     0,   149,   147,   146,   145,   137,   102,   104,   105,   136,
    98,   135,   134,   133,   132,   131,   130,   110,   129,   128,
   127,    97,   125,   101,   124,   100,   103,   106,   123,   122,
   120,   119,   118,   117,   116,   113,   108,   111,    99,   107,
    96,    95 };
static const yytabelem yyr1[]={

     0,     1,     2,     5,     6,     6,     3,     3,     9,     8,
     8,     8,    10,    10,    10,    10,    10,    10,    10,    10,
    10,    11,    11,    20,    12,    22,    22,    23,    23,    23,
    23,    23,    23,    23,    23,    13,    24,    24,    25,    14,
    15,    15,    15,    16,    17,    17,    17,    17,    17,    18,
    19,     4,     4,    29,    31,    27,    28,    28,    28,    28,
    28,    28,    28,    28,    28,    33,    36,    34,    35,    30,
    30,    30,    37,    32,    32,    32,    39,    38,    38,    40,
    40,    41,     7,    26,    21 };
static const yytabelem yyr2[]={

     0,     8,     1,     1,     3,     5,     9,    11,     3,     2,
     4,     0,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     5,     7,     7,     6,     2,     4,     3,     3,     3,
     3,     3,     3,     3,     3,     6,     2,     4,     3,     7,
     7,     7,     7,     7,     7,     7,     7,     7,     7,     7,
     7,     2,     4,     1,     1,    11,     7,     7,     9,     7,
     7,     7,     7,     5,     5,     5,     3,     3,    11,     2,
     4,     0,     2,     2,     4,     0,     1,     6,     2,     2,
     4,     3,     3,     3,     3 };
static const yytabelem yychk[]={

-10000000,    -1,    -2,    -3,   260,    -4,   -27,   -28,   -33,   262,
   261,    -7,   291,    -5,   -27,   -29,   -34,    -6,   293,   263,
   264,   265,   -35,   300,   292,   290,   300,   -36,    -7,   300,
    -9,    -6,   -30,   -37,   -17,   282,   283,   284,   286,   287,
   300,   290,   300,    -6,   300,   300,   300,   300,   301,    -8,
   -10,   -11,   -12,   -13,   -14,   -15,   -16,   -17,   -18,   -19,
   -20,   268,   278,   277,   279,   280,   281,   285,   288,   289,
   266,   300,   -31,   -37,    -6,    -6,    -6,    -6,    -6,   300,
   292,   -10,   300,   267,   -22,   -23,   269,   272,   273,   271,
   270,   274,   275,   276,   -24,   -25,    -7,   -26,   259,   -21,
   258,   -21,   -21,   -21,    -6,    -6,    -7,    -8,   -32,   -38,
   -26,   -40,   -41,   -21,   300,   300,   300,   300,   300,   301,
   300,   300,   -23,   300,   -25,   300,   300,   300,   300,   300,
   300,   300,   -21,   -38,   -39,   -41,   292,   -40 };
static const yytabelem yydef[]={

     2,    -2,     0,     0,     0,     3,    51,    53,     0,     0,
     0,     0,    82,     1,    52,    71,     0,     0,     0,     0,
     0,     0,     0,    63,    67,     4,    64,    65,    66,    11,
     0,     8,    54,    69,    72,     0,     0,     0,     0,     0,
    56,     5,    57,     0,    59,    60,    61,    62,     0,     6,
     9,    12,    13,    14,    15,    16,    17,    18,    19,    20,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,    11,    75,    70,     0,     0,     0,     0,     0,    58,
     0,    10,    21,     0,     0,    25,    27,    28,    29,    30,
    31,    32,    33,    34,     0,    36,    38,     0,    83,     0,
    84,     0,     0,     0,     0,     0,     0,     7,    55,    73,
    76,    78,    79,    81,    44,    45,    46,    47,    48,     0,
    22,    24,    26,    35,    37,    39,    40,    41,    42,    43,
    49,    50,    23,    74,     0,    80,    68,    77 };
typedef struct
#ifdef __cplusplus
	yytoktype
#endif
{ char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	1	/* allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"ASSIGN",	257,
	"FILENAME",	258,
	"DIRNAME",	259,
	"MODEL",	260,
	"MODULE",	261,
	"MISC",	262,
	"RELEASE",	263,
	"DEVELOPMENT",	264,
	"LATEST",	265,
	"INCLUDE",	266,
	"APPLY_GRID_NAMES",	267,
	"GLOBAL",	268,
	"VERBOSE",	269,
	"PARSE_ONLY",	270,
	"SHOW_ONLY",	271,
	"NO_COMPILE",	272,
	"NO_LINK",	273,
	"COMPILE_ALL",	274,
	"ONE_STEP",	275,
	"CLEANUP",	276,
	"DEFAULT_DIR",	277,
	"GRID",	278,
	"C_COMPILER",	279,
	"CPLUS_COMPILER",	280,
	"F_COMPILER",	281,
	"C_FLAGS",	282,
	"CPLUS_FLAGS",	283,
	"F_FLAGS",	284,
	"FPP",	285,
	"CPP_FLAGS",	286,
	"DEF_FLAGS",	287,
	"LIBRARIES",	288,
	"LINK_FLAGS",	289,
	"STRING",	290,
	"IDENTIFIER",	291,
	"INTEGER",	292,
	"D_OPTION",	293,
	"DOT",	294,
	"LEFT_CURL",	295,
	"RIGHT_CURL",	296,
	"COMMA",	297,
	"LEFT_PAREN",	298,
	"RIGHT_PAREN",	299,
	"SEMICOLON",	300,
	"HYPHEN",	301,
	"TILDE",	302,
	"SLASH",	303,
	"-unknown-",	-1	/* ends search */
};

char * yyreds[] =
{
	"-no such reduction-",
	"program : program_entry globals modules program_end",
	"program_entry : /* empty */",
	"program_end : /* empty */",
	"string : STRING",
	"string : string STRING",
	"globals : MODEL identifier SEMICOLON global_defines",
	"globals : MODEL identifier remark SEMICOLON global_defines",
	"remark : string",
	"global_defines : global_define",
	"global_defines : global_defines global_define",
	"global_defines : /* empty */",
	"global_define : include_statement",
	"global_define : global_statement",
	"global_define : grid_statement",
	"global_define : default_dir",
	"global_define : compiler_exe",
	"global_define : preprocessor",
	"global_define : compiler_flags",
	"global_define : libraries",
	"global_define : link_flags",
	"include_statement : include_head SEMICOLON",
	"include_statement : include_head APPLY_GRID_NAMES SEMICOLON",
	"include_head : INCLUDE identifier filename",
	"global_statement : GLOBAL global_flags SEMICOLON",
	"global_flags : global_flag",
	"global_flags : global_flags global_flag",
	"global_flag : VERBOSE",
	"global_flag : NO_COMPILE",
	"global_flag : NO_LINK",
	"global_flag : SHOW_ONLY",
	"global_flag : PARSE_ONLY",
	"global_flag : COMPILE_ALL",
	"global_flag : ONE_STEP",
	"global_flag : CLEANUP",
	"grid_statement : GRID grids SEMICOLON",
	"grids : grid",
	"grids : grids grid",
	"grid : identifier",
	"default_dir : DEFAULT_DIR dirname SEMICOLON",
	"compiler_exe : C_COMPILER filename SEMICOLON",
	"compiler_exe : CPLUS_COMPILER filename SEMICOLON",
	"compiler_exe : F_COMPILER filename SEMICOLON",
	"preprocessor : FPP filename SEMICOLON",
	"compiler_flags : C_FLAGS string SEMICOLON",
	"compiler_flags : CPLUS_FLAGS string SEMICOLON",
	"compiler_flags : F_FLAGS string SEMICOLON",
	"compiler_flags : CPP_FLAGS string SEMICOLON",
	"compiler_flags : DEF_FLAGS string SEMICOLON",
	"libraries : LIBRARIES string SEMICOLON",
	"link_flags : LINK_FLAGS string SEMICOLON",
	"modules : module",
	"modules : modules module",
	"module : module_statement",
	"module : module_statement module_defs",
	"module : module_statement module_defs module_file_groups",
	"module_statement : module_head module_version SEMICOLON",
	"module_statement : module_head string SEMICOLON",
	"module_statement : module_head D_OPTION string SEMICOLON",
	"module_statement : module_head RELEASE SEMICOLON",
	"module_statement : module_head DEVELOPMENT SEMICOLON",
	"module_statement : module_head LATEST SEMICOLON",
	"module_statement : module_head date SEMICOLON",
	"module_statement : module_head SEMICOLON",
	"module_statement : MISC SEMICOLON",
	"module_head : MODULE module_name",
	"module_name : identifier",
	"module_version : INTEGER",
	"date : INTEGER HYPHEN INTEGER HYPHEN INTEGER",
	"module_defs : module_def",
	"module_defs : module_defs module_def",
	"module_defs : /* empty */",
	"module_def : compiler_flags",
	"module_file_groups : module_file_group",
	"module_file_groups : module_file_groups module_file_group",
	"module_file_groups : /* empty */",
	"module_file_group : dirname",
	"module_file_group : dirname module_files",
	"module_file_group : module_files",
	"module_files : module_file",
	"module_files : module_files module_file",
	"module_file : filename",
	"identifier : IDENTIFIER",
	"dirname : DIRNAME",
	"filename : FILENAME",
};
#endif /* YYDEBUG */
/*
 * Copyright (c) 1993 by Sun Microsystems, Inc.
 */

#pragma ident	"@(#)yaccpar	6.15	97/12/08 SMI"

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( yychar >= 0 || ( yyr2[ yytmp ] >> 1 ) != 1 )\
	{\
		yyerror( "syntax error - cannot backup" );\
		goto yyerrlab;\
	}\
	yychar = newtoken;\
	yystate = *yyps;\
	yylval = newvalue;\
	goto yynewstate;\
}
#define YYRECOVERING()	(!!yyerrflag)
#define YYNEW(type)	malloc(sizeof(type) * yynewmax)
#define YYCOPY(to, from, type) \
	(type *) memcpy(to, (char *) from, yymaxdepth * sizeof (type))
#define YYENLARGE( from, type) \
	(type *) realloc((char *) from, yynewmax * sizeof(type))
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-10000000)

/*
** global variables used by the parser
*/
YYSTYPE *yypv;			/* top of value stack */
int *yyps;			/* top of state stack */

int yystate;			/* current state */
int yytmp;			/* extra var (lasts between blocks) */

int yynerrs;			/* number of errors */
int yyerrflag;			/* error recovery flag */
int yychar;			/* current input token number */



#ifdef YYNMBCHARS
#define YYLEX()		yycvtok(yylex())
/*
** yycvtok - return a token if i is a wchar_t value that exceeds 255.
**	If i<255, i itself is the token.  If i>255 but the neither 
**	of the 30th or 31st bit is on, i is already a token.
*/
#if defined(__STDC__) || defined(__cplusplus)
int yycvtok(int i)
#else
int yycvtok(i) int i;
#endif
{
	int first = 0;
	int last = YYNMBCHARS - 1;
	int mid;
	wchar_t j;

	if(i&0x60000000){/*Must convert to a token. */
		if( yymbchars[last].character < i ){
			return i;/*Giving up*/
		}
		while ((last>=first)&&(first>=0)) {/*Binary search loop*/
			mid = (first+last)/2;
			j = yymbchars[mid].character;
			if( j==i ){/*Found*/ 
				return yymbchars[mid].tvalue;
			}else if( j<i ){
				first = mid + 1;
			}else{
				last = mid -1;
			}
		}
		/*No entry in the table.*/
		return i;/* Giving up.*/
	}else{/* i is already a token. */
		return i;
	}
}
#else/*!YYNMBCHARS*/
#define YYLEX()		yylex()
#endif/*!YYNMBCHARS*/

/*
** yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
#if defined(__STDC__) || defined(__cplusplus)
int bld_parse ( model_def_type * model )
#else
int bld_parse ( model )
model_def_type * model;
#endif
{
	register YYSTYPE *yypvt = 0;	/* top of value stack for $vars */

#if defined(__cplusplus) || defined(lint)
/*
	hacks to please C++ and lint - goto's inside
	switch should never be executed
*/
	static int __yaccpar_lint_hack__ = 0;
	switch (__yaccpar_lint_hack__)
	{
		case 1: goto yyerrlab;
		case 2: goto yynewstate;
	}
#endif

	/*
	** Initialize externals - yyparse may be called more than once
	*/
	yypv = &yyv[-1];
	yyps = &yys[-1];
	yystate = 0;
	yytmp = 0;
	yynerrs = 0;
	yyerrflag = 0;
	yychar = -1;

#if YYMAXDEPTH <= 0
	if (yymaxdepth <= 0)
	{
		if ((yymaxdepth = YYEXPAND(0)) <= 0)
		{
			yyerror("yacc initialization error");
			YYABORT;
		}
	}
#endif

	{
		register YYSTYPE *yy_pv;	/* top of value stack */
		register int *yy_ps;		/* top of state stack */
		register int yy_state;		/* current state */
		register int  yy_n;		/* internal state number info */
	goto yystack;	/* moved from 6 lines above to here to please C++ */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	yynewstate:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;
		goto yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	yystack:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	yy_stack:
		/*
		** put a state and value onto the stacks
		*/
#if YYDEBUG
		/*
		** if debugging, look up token value in list of value vs.
		** name pairs.  0 and negative (-1) are special values.
		** Note: linear search is used since time is not a real
		** consideration while debugging.
		*/
		if ( yydebug )
		{
			register int yy_i;

			printf( "State %d, token ", yy_state );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++yy_ps >= &yys[ yymaxdepth ] )	/* room on stack? */
		{
			/*
			** reallocate and recover.  Note that pointers
			** have to be reset, or bad things will happen
			*/
			long yyps_index = (yy_ps - yys);
			long yypv_index = (yy_pv - yyv);
			long yypvt_index = (yypvt - yyv);
			int yynewmax;
#ifdef YYEXPAND
			yynewmax = YYEXPAND(yymaxdepth);
#else
			yynewmax = 2 * yymaxdepth;	/* double table size */
			if (yymaxdepth == YYMAXDEPTH)	/* first time growth */
			{
				char *newyys = (char *)YYNEW(int);
				char *newyyv = (char *)YYNEW(YYSTYPE);
				if (newyys != 0 && newyyv != 0)
				{
					yys = YYCOPY(newyys, yys, int);
					yyv = YYCOPY(newyyv, yyv, YYSTYPE);
				}
				else
					yynewmax = 0;	/* failed */
			}
			else				/* not first time */
			{
				yys = YYENLARGE(yys, int);
				yyv = YYENLARGE(yyv, YYSTYPE);
				if (yys == 0 || yyv == 0)
					yynewmax = 0;	/* failed */
			}
#endif
			if (yynewmax <= yymaxdepth)	/* tables not expanded */
			{
				yyerror( "yacc stack overflow" );
				YYABORT;
			}
			yymaxdepth = yynewmax;

			yy_ps = yys + yyps_index;
			yy_pv = yyv + yypv_index;
			yypvt = yyv + yypvt_index;
		}
		*yy_ps = yy_state;
		*++yy_pv = yyval;

		/*
		** we have a new state - find out what to do
		*/
	yy_newstate:
		if ( ( yy_n = yypact[ yy_state ] ) <= YYFLAG )
			goto yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		yytmp = yychar < 0;
#endif
		if ( ( yychar < 0 ) && ( ( yychar = YYLEX() ) < 0 ) )
			yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( yydebug && yytmp )
		{
			register int yy_i;

			printf( "Received token " );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( yy_n += yychar ) < 0 ) || ( yy_n >= YYLAST ) )
			goto yydefault;
		if ( yychk[ yy_n = yyact[ yy_n ] ] == yychar )	/*valid shift*/
		{
			yychar = -1;
			yyval = yylval;
			yy_state = yy_n;
			if ( yyerrflag > 0 )
				yyerrflag--;
			goto yy_stack;
		}

	yydefault:
		if ( ( yy_n = yydef[ yy_state ] ) == -2 )
		{
#if YYDEBUG
			yytmp = yychar < 0;
#endif
			if ( ( yychar < 0 ) && ( ( yychar = YYLEX() ) < 0 ) )
				yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( yydebug && yytmp )
			{
				register int yy_i;

				printf( "Received token " );
				if ( yychar == 0 )
					printf( "end-of-file\n" );
				else if ( yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( yy_i = 0;
						yytoks[yy_i].t_val >= 0;
						yy_i++ )
					{
						if ( yytoks[yy_i].t_val
							== yychar )
						{
							break;
						}
					}
					printf( "%s\n", yytoks[yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register const int *yyxi = yyexca;

				while ( ( *yyxi != -1 ) ||
					( yyxi[1] != yy_state ) )
				{
					yyxi += 2;
				}
				while ( ( *(yyxi += 2) >= 0 ) &&
					( *yyxi != yychar ) )
					;
				if ( ( yy_n = yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( yyerrflag )
			{
			case 0:		/* new error */
				yyerror( "syntax error" );
				goto skip_init;
			yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				yy_pv = yypv;
				yy_ps = yyps;
				yy_state = yystate;
			skip_init:
				yynerrs++;
				/* FALLTHRU */
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( yy_ps >= yys )
				{
					yy_n = yypact[ *yy_ps ] + YYERRCODE;
					if ( yy_n >= 0 && yy_n < YYLAST &&
						yychk[yyact[yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						yy_state = yyact[ yy_n ];
						goto yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( yydebug )
						printf( _POP_, *yy_ps,
							yy_ps[-1] );
#	undef _POP_
#endif
					yy_ps--;
					yy_pv--;
				}
				/*
				** there is no state on stack with "error" as
				** a valid shift.  give up.
				*/
				YYABORT;
			case 3:		/* no shift yet; eat a token */
#if YYDEBUG
				/*
				** if debugging, look up token in list of
				** pairs.  0 and negative shouldn't occur,
				** but since timing doesn't matter when
				** debugging, it doesn't hurt to leave the
				** tests here.
				*/
				if ( yydebug )
				{
					register int yy_i;

					printf( "Error recovery discards " );
					if ( yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( yy_i = 0;
							yytoks[yy_i].t_val >= 0;
							yy_i++ )
						{
							if ( yytoks[yy_i].t_val
								== yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							yytoks[yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				yychar = -1;
				goto yy_newstate;
			}
		}/* end if ( yy_n == 0 ) */
		/*
		** reduction by production yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				yy_n, yyreds[ yy_n ] );
#endif
		yytmp = yy_n;			/* value to switch over */
		yypvt = yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using yy_state here as temporary
		** register variable, but why not, if it works...
		** If yyr2[ yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int yy_len = yyr2[ yy_n ];

			if ( !( yy_len & 01 ) )
			{
				yy_len >>= 1;
				yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
				yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
					*( yy_ps -= yy_len ) + 1;
				if ( yy_state >= YYLAST ||
					yychk[ yy_state =
					yyact[ yy_state ] ] != -yy_n )
				{
					yy_state = yyact[ yypgo[ yy_n ] ];
				}
				goto yy_stack;
			}
			yy_len >>= 1;
			yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
			yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
				*( yy_ps -= yy_len ) + 1;
			if ( yy_state >= YYLAST ||
				yychk[ yy_state = yyact[ yy_state ] ] != -yy_n )
			{
				yy_state = yyact[ yypgo[ yy_n ] ];
			}
		}
					/* save until reenter driver code */
		yystate = yy_state;
		yyps = yy_ps;
		yypv = yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( yytmp )
	{
		
case 2:{
#				ifdef PARSE_DEBUG
				printf ( "bld_parser.y:  PARSE_DEBUG is defined\n" );				
#				endif

				ldirname[0] = (char) '\0';
				options_level = global_level;
				misc_id = 0;
				} break;
case 3:{
				/* get_all_module_files ( model ); */
				
#				ifdef PARSE_DEBUG				
				printf ( "archive " );
				print_file_list ( & ( model->archive_files ) );
				
				printf ( "local " );
				print_file_list ( & ( model->local_files ) );
#				endif

				/* merge_file_lists ( model ); */
				} break;
case 4:{
				strcpy ( yyval.string_value, yypvt[-0].string_value );
				} break;
case 5:{
				/*********
				sprintf ( $<string_value>$, "%s %s%s", 
				          $<string_value>1, "\\\n", $2 );
				**********/
				strcpy ( yyval.string_value, yypvt[-1].string_value );
				string_cat ( yyval.string_value, "\\\n", NAME_SIZE );
				string_cat ( yyval.string_value, yypvt[-0].string_value, NAME_SIZE );
				} break;
case 6:{
				strcpy ( model->exename, yypvt[-2].string_value );
				/* printf ( "model name is '%s'\n", model->exename ); */
				} break;
case 7:{
				strcpy ( model->exename, yypvt[-3].string_value );
				/* printf ( "model name is '%s'\n", model->exename ); */
				strcpy ( model->description, yypvt[-2].string_value );
				} break;
case 8:{
				strcpy ( yyval.string_value, yypvt[-0].string_value );
				} break;
case 21:{
				model->includes.curr_ptr->apply_grid_names = B_FALSE;
				} break;
case 22:{
				model->includes.curr_ptr->apply_grid_names = B_TRUE;
				} break;
case 23:{
				append_include ( & ( model->includes ) );
				strcpy ( model->includes.curr_ptr->symbolname, yypvt[-1].string_value );
				strcpy ( model->includes.curr_ptr->dirname, yypvt[-0].file.dirname );
				strcpy ( model->includes.curr_ptr->filename, yypvt[-0].file.filename );
				dos_slash( model->includes.curr_ptr->dirname );
				dos_slash( model->includes.curr_ptr->filename );
				/* printf ( "includename %s = %s%s\n", $<string_value>2, $<file>3.dirname, $<file>3.filename ); */
				} break;
case 27:{
				model->verbose = B_TRUE;
				} break;
case 28:{
				model->mode = no_compile_mode;
				} break;
case 29:{
				model->mode = no_link_mode;
				} break;
case 30:{
				model->show_only = B_TRUE;
				} break;
case 31:{
				model->mode = parse_mode;
				} break;
case 32:{
				model->compile_all = B_TRUE;
				} break;
case 33:{
				model->one_step = B_TRUE;
				} break;
case 34:{
				model->clean_up = B_TRUE;
				} break;
case 38:{
				append_grid ( & ( model->grids ) );
				strcpy ( * ( model->grids.curr_ptr ), yypvt[-0].string_value );
				} break;
case 39:{
				switch ( (int) yypvt[-1].file.dirname[0] )
					{
					case '/':
						strcpy ( model->wd, yypvt[-1].file.dirname );
						break;

					case '~':
						if ( yypvt[-1].file.dirname[1] != (char) '/' )
							{
							fprintf ( stderr, "Can't handle dirname %s. Exiting\n", yypvt[-1].file.dirname );
							return (1);
							}

						string_copy ( model->wd, getenv ( "HOME" ), NAME_SIZE );
						string_cat ( model->wd, yypvt[-1].file.dirname + 1, NAME_SIZE );
						break;

					case '.':
						string_copy ( model->wd, getenv ( "PWD" ), NAME_SIZE );

						printf ( "PWD is %s\n", model->wd );

						string_cat ( model->wd, "/", NAME_SIZE );

						if ( yypvt[-1].file.dirname[1] == (char) '/' )
							{
							string_cat ( model->wd, yypvt[-1].file.dirname + 2, NAME_SIZE );
							}
						else
							{
							string_cat ( model->wd, yypvt[-1].file.dirname, NAME_SIZE );
							}

						break;

					default:
						string_copy ( model->wd, getenv ( "PWD" ), NAME_SIZE );
						string_cat ( model->wd, "/", NAME_SIZE );
						string_cat ( model->wd, yypvt[-1].file.dirname, NAME_SIZE );
						break;
					}
				} break;
case 40:{
				sprintf ( model->compilers[c_lang], "%s%s", yypvt[-1].file.dirname,
				          yypvt[-1].file.filename );
				dos_slash( model->compilers[c_lang] );
				} break;
case 41:{
				sprintf ( model->compilers[c_plus_plus_lang], "%s%s", yypvt[-1].file.dirname,
				          yypvt[-1].file.filename );
				dos_slash( model->compilers[c_plus_plus_lang] );
				} break;
case 42:{
				sprintf ( model->compilers[f_lang], "%s%s", yypvt[-1].file.dirname,
				          yypvt[-1].file.filename );
				dos_slash( model->compilers[f_lang] );
				} break;
case 43:{
                                sprintf ( model->fpp, "%s%s", yypvt[-1].file.dirname,
                                          yypvt[-1].file.filename );
                                dos_slash( model->fpp );
                                } break;
case 44:{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->compile_flags[c_lang], 
						         cmp_flags(yypvt[-1].string_value ));
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->compile_flags[c_lang], 
						         cmp_flags(yypvt[-1].string_value ));
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				} break;
case 45:{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->compile_flags[c_plus_plus_lang], 
						         cmp_flags(yypvt[-1].string_value ));
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->compile_flags[c_plus_plus_lang], 
						         cmp_flags(yypvt[-1].string_value ));
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				} break;
case 46:{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->compile_flags[f_lang], 
						         cmp_flags(yypvt[-1].string_value ));
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
						         cmp_flags(yypvt[-1].string_value ));
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				} break;
case 47:{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->cpp_flags, yypvt[-1].string_value );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->cpp_flags, 
						         yypvt[-1].string_value );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				} break;
case 48:{
				switch ( options_level )
					{
					case global_level:
						strcpy ( model->def_flags, yypvt[-1].string_value );
						break;

					case module_level:
						if ( model->one_step )
							{
							fprintf ( stderr, "Warning: module-level compiler "
							"flags are ignored when option one_step is in "
							"effect.\n" );
							}
							
						strcpy ( model->modules.curr_ptr->def_flags, 
						         yypvt[-1].string_value );
						break;

					case file_level:
						break;

					default:
						fprintf ( stderr, "System error.  Unknown option level. Exiting\n" );
						return ( 1 );
					}
				} break;
case 49:{
#				ifdef PARSE_DEBUG
				printf ( "libraries input string is:\n\"%s\"\n", yypvt[-1].string_value );
#				endif

				strcpy ( model->libraries, yypvt[-1].string_value );
				dos_slash( model->libraries );
				
#				ifdef PARSE_DEBUG
				printf ( "libraries string is:\n\"%s\"\n", model->libraries );
				printf ( "link_flags string is:\n%s\n", model->link_flags );
#				endif
				} break;
case 50:{
				strcpy ( model->link_flags, yypvt[-1].string_value );
				} break;
case 53:{
				options_level = module_level;

				/* now use global default directory as starting point for
				   any further files */
				string_copy ( ldirname, model->wd, NAME_SIZE );
				} break;
case 54:{
				} break;
case 55:{
				strcpy ( ldirname, "" );
				} break;
case 56:{
				(model->modules.curr_ptr)->where = version_src;
				strcpy ( (model->modules.curr_ptr)->version_num,
				         yypvt[-1].string_value );
				} break;
case 57:{
				(model->modules.curr_ptr)->where = version_src;
				strcpy ( (model->modules.curr_ptr)->version_num,
				         yypvt[-1].string_value );
				} break;
case 58:{
				(model->modules.curr_ptr)->where = local_dir;  
				strcpy ( (model->modules.curr_ptr)->dirname,    
				         yypvt[-1].string_value );
				dos_slash( (model->modules.curr_ptr)->dirname );
				} break;
case 59:{
				(model->modules.curr_ptr)->where = latest_release_src;
				} break;
case 60:{
				(model->modules.curr_ptr)->where = dev_src;
				} break;
case 61:{
				(model->modules.curr_ptr)->where = latest_release_src;
				fprintf ( stderr, "source type LATEST not supported\n" );
				} break;
case 62:{
				(model->modules.curr_ptr)->where = release_time_src;
				strcpy ( (model->modules.curr_ptr)->date, yypvt[-1].string_value );
				} break;
case 63:{
				(model->modules.curr_ptr)->where = latest_release_src;
#				ifdef PARSE_DEBUG
				printf ( "module source is %d\n", 
				         (model->modules.curr_ptr)->where );
#				endif
				} break;
case 64:{
				append_module ( & ( model->modules ) );
				init_module_struct ( model->modules.curr_ptr );

				misc_id++;
				sprintf ( model->modules.curr_ptr->module_name, "#misc_%02d", misc_id );

				(model->modules.curr_ptr)->where = file_src;
				} break;
case 65:{				
				/* create entry in module_list */
				append_module ( & ( model->modules ) );
				init_module_struct ( model->modules.curr_ptr );
				strcpy ( (model->modules.curr_ptr)->module_name, 
				         yypvt[-0].string_value );
				} break;
case 66:{
				/* strcpy ( $<string_value>$, $<string_value>1 ); */
				} break;
case 67:{
				sprintf ( yyval.string_value, "%d", yypvt[-0].int_value ); 
				} break;
case 68:{
				sprintf ( yyval.string_value, "%.2d%.2d%.2d", yypvt[-4].int_value, yypvt[-2].int_value, yypvt[-0].int_value );
				} break;
case 76:{
				switch ( (int) yypvt[-0].file.dirname[0] )
					{
					case '/':
						strcpy ( ldirname, yypvt[-0].file.dirname );
						dos_slash( ldirname );
						break;

					case '~':
						if ( yypvt[-0].file.dirname[1] != (char) '/' )
							{
							fprintf ( stderr, "Can't handle dirname %s. Exiting\n", yypvt[-0].file.dirname );
							return (1);
							}

						string_copy ( ldirname, getenv ( "HOME" ), NAME_SIZE );
						string_cat ( ldirname, yypvt[-0].file.dirname + 1, NAME_SIZE );
						dos_slash( ldirname );
						break;

					case '.':
						string_copy ( ldirname, model->wd, NAME_SIZE );

						if ( yypvt[-0].file.dirname[1] == (char) '/' )
							{
							strcat ( ldirname, yypvt[-0].file.dirname + 2 );
							}
						else
							{
							strcat ( ldirname, yypvt[-0].file.dirname );
							}

						dos_slash( ldirname );

						break;

					default:
						string_copy ( ldirname, model->wd, NAME_SIZE );
						strcat ( ldirname, yypvt[-0].file.dirname );
						dos_slash( ldirname );
						break;
					}

#				ifdef PARSE_DEBUG
				printf ( "dirname = %s\n", ldirname );
#				endif
				} break;
case 81:{
				/* if this filename matches one which already
				   exists for this module, replace the old one */
					/* this is a new filename.  Make a new list entry */

				append_file ( & ( model->local_files ) );
				string_copy ( model->local_files.curr_ptr->module_name, 
				         model->modules.curr_ptr->module_name, NAME_SIZE );

				if ( ( yypvt[-0].file.dirname[0] != '/' ) &&
				     ( yypvt[-0].file.dirname[0] != '~' ) )
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

				strcat ( model->local_files.curr_ptr->dirname, yypvt[-0].file.dirname );
				strcpy ( model->local_files.curr_ptr->filename, yypvt[-0].file.filename );
				dos_slash( model->local_files.curr_ptr->dirname );
				dos_slash( model->local_files.curr_ptr->filename );

				/* now get language type */
				model->local_files.curr_ptr->language = 
					file_lang = get_file_type ( yypvt[-0].file.filename );

				model->local_files.curr_ptr->where = file_src;

				/* get module options */
#				ifdef PARSE_DEBUG
				printf ( "inserting module-level flags into file %s%s\n",
				         yypvt[-0].file.dirname, yypvt[-0].file.filename );
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
				         yypvt[-0].file.dirname, yypvt[-0].file.filename );
#				endif
				} break;
case 82:{
				resolve_name ( yypvt[-0].string_value, yyval.string_value, NAME_SIZE );
				} break;
case 83:{
				resolve_name ( yypvt[-0].file.dirname, yyval.file.dirname, NAME_SIZE );
				resolve_name ( yypvt[-0].file.filename, yyval.file.filename, NAME_SIZE );
				} break;
case 84:{
				resolve_name ( yypvt[-0].file.dirname, yyval.file.dirname, NAME_SIZE );
				resolve_name ( yypvt[-0].file.filename, yyval.file.filename, NAME_SIZE );
				} break;
	}
	goto yystack;		/* reset registers in driver code */
}
