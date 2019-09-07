%{
/****************************************************************************
 *
 * Project Title: Environmental Decision Support System
 * File: @(#)bld_scanner.l	11.1
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
 * Last updated: 01 Jun 1998 16:41:44
 *
 ****************************************************************************/


/****************************************************************************
 * This source file has been modified to work within the Models-3 framework *
 *                                  by                                      *
 * The National Exposure Research Laboratory, Atmospheric Modeling Division *
 *                                                                          *
 *                                                                          *
 *  The major changes include:                                              *
 *                                                                          *
 *      - changing the archive software to CVS                              *
 *      - adding code to work on a Windows NT platform (Digital Fortran 90) *
 *      - adding code to work with remote CVS                               *
 *                                                                          *
 ****************************************************************************/


/*******************************************************************************
*
*       NAME:	scanner.l
*
*   FUNCTION:	Scanner for SMS .r files. 
*
*      USAGE:	
*
*       DATE:	1 June 1994
*
*     AUTHOR:	Tim Turner
*
*	BUGS:	
*
*  REVISIONS:	
*
*******************************************************************************/
#include <stdio.h>
#include <string.h>

/* int atoi( char * ); */

#include "sms.h"
#include "tokens.h"

#define noshare /*noshare*/

#define NEW_DEBUG

/* noshare extern  char default_dir[]; */
noshare		char command_string[1024];
noshare extern int yylineno;			/* line number maintained by yylex() */

static char ldirname[NAME_SIZE];
static char temp_string[2048];
static int status;

#ifdef LEXDEBUG
#	define allprint(c) printf ( "%c", c )
#	define sprint(s) printf ( "%s", s )
#endif

/* I'm guessing! */
yywrap()
	{
	BEGIN INITIAL;
	yylineno = 1;

	command_string[0] = 
		ldirname[0] = 
		temp_string[0] = 
		/* default_dir[0] = */
		(char) '\0';
	
	return (1);
	}
%}

%a 20000
%e 1000
%k 2000
%n 2000
%o 30000
%p 18000

WHITE		[ \t\n]+
SKIP		[ \t\n]*
IDENTIFIER	[A-Z:a-z0-9_$*\-]+
NAMECHARS 	[A-Z:a-z0-9_$*\-/]+
INTEGER		[0-9]+

%S DIR_MODE
%S BASE_MODE
%S EXT_MODE
%S DQ_SLASH_MODE
%S DQ_STRING_MODE
%S SQ_SLASH_MODE
%S SQ_STRING_MODE

%%
"//".*$				;	/* this is a comment */

<DIR_MODE>"."?{NAMECHARS}("."{NAMECHARS})*"/"  	\
				{
				/* more directory name */
				string_cat ( ldirname, yytext, NAME_SIZE );
				}

{NAMECHARS}("."{NAMECHARS})*"/"	\
				{
				BEGIN DIR_MODE;
				string_copy ( ldirname, yytext, NAME_SIZE );
				}

[\.~]?"/"			{
				BEGIN DIR_MODE;
				string_copy ( ldirname, yytext, NAME_SIZE );
				}

[A-Fa-f]":"			{
				BEGIN DIR_MODE;
				string_copy ( ldirname, yytext, NAME_SIZE );
				}

<DIR_MODE>"."?{NAMECHARS}("."{NAMECHARS})*	\
				{
				BEGIN INITIAL;
				string_copy ( yylval.file.dirname, ldirname, NAME_SIZE );
				string_copy ( yylval.file.filename, yytext, NAME_SIZE );
				return ( FILENAME );
				}

<DIR_MODE>({WHITE}|$)		{
				BEGIN INITIAL;
				string_copy ( yylval.file.dirname, ldirname, NAME_SIZE );
				return ( DIRNAME );
				}

<DIR_MODE>";"			{
				BEGIN INITIAL;
				unput( (int)*yytext);
				string_copy ( yylval.file.dirname, ldirname, NAME_SIZE );
				return ( DIRNAME );
				}

[Mm][Oo][Dd][Uu][Ll][Ee]	{
				return ( MODULE );
				}

[Mm][Oo][Dd][Ee][Ll]		{
				return ( MODEL );
				}

[Mm][Ii][Ss][Cc]		{
				return ( MISC );
				}

[Rr][Ee][Ll][Ee][Aa][Ss][Ee]	{
				return ( RELEASE );
				}

[Dd][Ee][Vv][Ee][Ll][Oo][Pp][Mm][Ee][Nn][Tt]	{
				return ( DEVELOPMENT );
				}

[Ll][Aa][Tt][Ee][Ss][Tt]	{
				return ( LATEST );
				}

-[dD]				{
				return ( D_OPTION );
				}

[Ii][Nn][Cc][Ll][Uu][Dd][Ee]	{
				return ( INCLUDE );
				}

[Aa][Pp][Pp][Ll][Yy]_[Gg][Rr][Ii][Dd]_[Nn][Aa][Mm][Ee][Ss]	{
				return ( APPLY_GRID_NAMES );
				}

[Gg][Ll][Oo][Bb][Aa][Ll]	{
				return (  GLOBAL );
				}

[Vv][Ee][Rr][Bb][Oo][Ss][Ee]	{
				return (  VERBOSE );
				}

[Pp][Aa][Rr][Ss][Ee]_[Oo][Nn][Ll][Yy]	{
				return (  PARSE_ONLY );
				}

[Nn][Oo]_[Cc][Oo][Mm][Pp][Ii][Ll][Ee]	{
				return ( NO_COMPILE );
				}

[Nn][Oo]_[Ll][Ii][Nn][Kk]	{
				return ( NO_LINK );
				}

[Ss][Hh][Oo][Ww]_[Oo][Nn][Ll][Yy]	{
				return ( SHOW_ONLY );
				}

[Cc][Oo][Mm][Pp][Ii][Ll][Ee]_[Aa][Ll][Ll]	{
				return (  COMPILE_ALL );
				}

[Oo][Nn][Ee]_[Ss][Tt][Ee][Pp]	{
				return (  ONE_STEP );
				}

[Cc][Ll][Ee][Aa][Nn]_[Uu][Pp]	{
				return (  CLEANUP );
				}

[Gg][Rr][Ii][Dd]	{
				return (  GRID );
				}

[Dd][Ee][Ff][Aa][Uu][Ll][Tt]_[Dd][Ii][Rr][Ee][Cc][Tt][Oo][Rr][Yy]	{
				return ( DEFAULT_DIR );
				}

[Cc]_[Cc][Oo][Mm][Pp][Ii][Ll][Ee][Rr]	{
				return (  C_COMPILER );
				}

[Cc]"++"_[Cc][Oo][Mm][Pp][Ii][Ll][Ee][Rr]	{
				return (  CPLUS_COMPILER );
				}


[Ff]77_[Cc][Oo][Mm][Pp][Ii][Ll][Ee][Rr]	{
				return (  F_COMPILER );
				}

[Ff]_[Cc][Oo][Mm][Pp][Ii][Ll][Ee][Rr]	{
				return (  F_COMPILER );
				}

[Cc]_[Ff][Ll][Aa][Gg][Ss]	{
				return (  C_FLAGS );
				}

[Cc]"++"_[Ff][Ll][Aa][Gg][Ss]	{
				return (  CPLUS_FLAGS );
				}

[Ff]77_[Ff][Ll][Aa][Gg][Ss]	{
				return (  F_FLAGS );
				}

[Ff]_[Ff][Ll][Aa][Gg][Ss]	{
				return (  F_FLAGS );
				}

[Ff][Pp][Pp]			{
				return (  FPP );
				}

[Cc][Pp][Pp]_[Ff][Ll][Aa][Gg][Ss]	{
				return (  CPP_FLAGS );
				}

[Dd][Ee][Ff]_[Ff][Ll][Aa][Gg][Ss]	{
				return (  DEF_FLAGS );
				}

[Ll][Ii][Nn][Kk]_[Ff][Ll][Aa][Gg][Ss]	{
				return (  LINK_FLAGS );
				}

[Ll][Ii][Bb][Rr][Aa][Rr][Ii][Ee][Ss]	{
				return (  LIBRARIES );
				}

{INTEGER}			{
				yylval.int_value = atoi ( yytext );
				return ( INTEGER );
				}

<INITIAL>\"[^"\\]*\\		{
				/* The end quote was backslashed.  This isn't the end of
				 * the string */
				status = string_copy ( temp_string, yytext + 1, NAME_SIZE );

#				ifdef SCAN_DEBUG
				printf ( "scanner: quote within a quote at line %d: \n{%s}\n",
					     yylineno, temp_string );
#				endif

				BEGIN DQ_SLASH_MODE;
				}

<INITIAL>\"[^"\\]*\"		{
				/* This is the end of the string.  Ship it */
				/* strip the quotes */
				/* yytext[strlen(yytext)-1] = (char) '\0'; */
				status = string_copy ( yylval.string_value, yytext + 1, NAME_SIZE );

				if ( status == SUCCESS )
					{
					yylval.string_value[strlen(yylval.string_value)-1] = 
						(char) '\0';
					}

				return ( STRING );
				}

<DQ_SLASH_MODE>\"		{
				temp_string[strlen ( temp_string ) - 1] = (char) '"';
				BEGIN DQ_STRING_MODE;
				}

<DQ_SLASH_MODE>[^"]		{
#				ifdef SCAN_DEBUG
				printf ( "scanner: backslashed character is 0x%x, '%c'\n",
				         (int)*yytext, (int)*yytext );
#				endif
				unput( (int)*yytext);
				BEGIN DQ_STRING_MODE;
				}

<DQ_STRING_MODE>[^"\\]*\\		{
				/* The end quote was backslashed.  This isn't the end of
				 * the string */
				/***********************
				yytext[strlen(yytext)-2] = (char) '"';
				yytext[strlen(yytext)-1] = (char) '\0';
				 ***********************/
				status = string_cat ( temp_string, yytext, NAME_SIZE );

				BEGIN DQ_SLASH_MODE;

#				ifdef SCAN_DEBUG
				printf ( "scanner: another quote within a quote at line %d: \n{%s}\n",
					     yylineno, temp_string );
#				endif
				}

<DQ_STRING_MODE>[^"\\]*\"	{
				/* This is the end of the string.  Ship it */
				/* strip the quotes */
#					ifdef SCAN_DEBUG
				printf ( "scanner: end of string at %d.  yytext is \n{%s}\n",
					     yylineno, yytext );
#					endif

				/* yytext[strlen(yytext) - 1] = (char) '\0'; */

				status = string_cat ( temp_string, yytext, NAME_SIZE );

				if ( status == SUCCESS )
					{
					temp_string[strlen(temp_string)-1] = (char) '\0';
					}

				string_copy ( yylval.string_value, temp_string, NAME_SIZE );
				BEGIN INITIAL;

#				ifdef SCAN_DEBUG
				printf ( "scanner: end of string: \n{%s}\n",
					     temp_string );
#				endif

				return ( STRING );
				}

<INITIAL>\'[^'\\]*\\		{
				/* The end quote was backslashed.  This isn't the end of
				 * the string */
				status = string_copy ( temp_string, yytext + 1, NAME_SIZE );

#				ifdef SCAN_DEBUG
				printf ( "scanner: quote within a quote at line %d: \n{%s}\n",
					     yylineno, temp_string );
#				endif

				BEGIN SQ_SLASH_MODE;
				}

<INITIAL>\'[^'\\]*\'		{
				/* This is the end of the string.  Ship it */
				/* strip the quotes */
				/* yytext[strlen(yytext)-1] = (char) '\0'; */
				status = string_copy ( yylval.string_value, yytext + 1, NAME_SIZE );

				if ( status == SUCCESS )
					{
					yylval.string_value[strlen(yylval.string_value)-1] = 
						(char) '\0';
					}

				return ( STRING );
				}

<SQ_SLASH_MODE>\'		{
				temp_string[strlen ( temp_string ) - 1] = (char) '\'';
				BEGIN SQ_STRING_MODE;
				}

<SQ_SLASH_MODE>[^']		{
				unput( (int)*yytext);
				BEGIN SQ_STRING_MODE;
				}

<SQ_STRING_MODE>[^'\\]*\\		{
				/* The end quote was backslashed.  This isn't the end of
				 * the string */
				status = string_cat ( temp_string, yytext, NAME_SIZE );

				BEGIN SQ_SLASH_MODE;

#				ifdef SCAN_DEBUG
				printf ( "scanner: another quote within a quote at line %d: \n{%s}\n",
					     yylineno, temp_string );
#				endif
				}

<SQ_STRING_MODE>[^'\\]*\'	{
				/* This is the end of the string.  Ship it */
				/* strip the quotes */
#					ifdef SCAN_DEBUG
				printf ( "scanner: end of string at %d.  yytext is \n{%s}\n",
					     yylineno, yytext );
#					endif

				status = string_cat ( temp_string, yytext, NAME_SIZE );

				if ( status == SUCCESS )
					{
					temp_string[strlen(temp_string)-1] = (char) '\0';
					}

				string_copy ( yylval.string_value, temp_string, NAME_SIZE );
				BEGIN INITIAL;

#				ifdef SCAN_DEBUG
				printf ( "scanner: end of string: \n{%s}\n",
					     temp_string );
#				endif

				return ( STRING );
				}

{IDENTIFIER}			{
				string_copy ( yylval.string_value, yytext, NAME_SIZE );
				return ( IDENTIFIER );
				}

"."?{IDENTIFIER}("."{IDENTIFIER})*	\
				{
				BEGIN INITIAL;
				yylval.file.dirname[0] = '\0';
				string_copy ( yylval.file.filename, yytext, NAME_SIZE );
				return ( FILENAME );
				}

<INITIAL>{WHITE}		{	/* white space */
				; 	/* do nothing */
				}

"."				{
				return ( DOT );
				}

"{"				{
				return ( LEFT_CURL );
				}

"}"				{
				return ( RIGHT_CURL );
				}

"="				{
				return ( ASSIGN );
				}

","				{
				return ( COMMA );
				}

"("				{
				return ( LEFT_PAREN );
				}

")"				{
				return ( RIGHT_PAREN );
				}

";"				{
				return ( SEMICOLON );
				}

"/"				{
				BEGIN DIR_MODE;
				}

"-"				{
				return ( HYPHEN );
				}

.				{
				fprintf ( stderr, 
					  "SMS_SCANNER :: unexpected character %c at line %d\n", 
				          *yytext, yylineno );

				/* log_message ( command_string ); */
				}
