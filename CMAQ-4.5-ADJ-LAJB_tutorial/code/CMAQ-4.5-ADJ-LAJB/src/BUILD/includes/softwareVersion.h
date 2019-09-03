/****************************************************************************
 *
 * Project Title: Environmental Decision Support System
 * File: @(#)softwareVersion.h	5.1
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
 * Pathname: /pub/storage/edss/framework/src/process_mgr/fw_include/SCCS/s.softwareVersion.h
 * Last updated: 20 Mar 1996 13:04:04
 *
 ****************************************************************************/

#ifndef SOFTWARE_VERSION
#define SOFTWARE_VERSION

static const char *SCCS_ID_softwareVersion = "@(#)softwareVersion.h	5.1 /pub/storage/edss/framework/src/process_mgr/fw_include/SCCS/s.softwareVersion.h 20 Mar 1996 13:04:04";
static const char *edssVersion = "EDSS 0.3pre";
static const char *edssCopyright = "COPYRIGHT (C) 1995, MCNC--North Carolina Supercomputing Center";

#ifdef __cplusplus
extern "C" {
#endif

void printProgInfo (char *progName, char *progDate);

#ifdef __cplusplus
}
#endif

#endif
