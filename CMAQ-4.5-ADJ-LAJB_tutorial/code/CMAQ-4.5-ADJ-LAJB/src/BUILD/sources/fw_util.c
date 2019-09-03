/****************************************************************************
 *
 * Project Title: Environmental Decision Support System
 * File: @(#)fw_util.c	1.3
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
 * Last updated: 01 Jun 1998 16:42:48
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


/*
 * fw_util.c
 *
 * Purpose:  Provide utility functions common to framework programs.
 *
 * Created by Ted Smith, MCNC,  March 20, 1990
 * 919-248-9232, smith_w@mcnc.org
 *
 */

const char fw_util_vers[] = "@(#)fw_util.c	1.3 /pub/storage/edss/framework/src/process_mgr/fw_common/SCCS/s.fw_util.c 26 Mar 1996 09:10:14";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* begin define for global variables */

const char *edssVersion = "Models 3 Version 1.1.3";
const char *edssDate = " 31 Oct 1997 ";
const char *edssCopyright = " ";

/* end   define for global variables */

/* begin function prototypes */
void printProgInfo (char *progName, char *progDate);
/* end   function prototypes */

/*** printProgInfo *************************************************
 *
 * Purpose: Print the software version information for a program
 *
 * progName    (input)   =    program name
 * progDate    (input)   =    program date
 *
 */
void printProgInfo (char *progName, char *progDate)
{
     fprintf (stderr, "\nProgram: %s/%s \n  %s/%s \n  %s\n\n", progName, 
		progDate, edssVersion, edssDate, edssCopyright);
 
     return;
}
