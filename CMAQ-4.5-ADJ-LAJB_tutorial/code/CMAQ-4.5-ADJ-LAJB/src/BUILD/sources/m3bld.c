/* RCS file, release, date & time of last delta, author, state, [and locker] */
/* $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/BUILD/src/sources/m3bld.c,v 1.1.1.1 2005/09/09 19:26:42 sjr Exp $  */

/* what(1) key, module and SID; SCCS file; date and time of last delta: */
/* %W% %P% %G% %U% */

/****************************************************************************
 *
 * Project Title: Environmental Decision Support System
 * File: @(#)build_main.c	11.1
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
 * Last updated: 29 Jan 2001          
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


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "softwareVersion.h"
#include "sms.h"

/* Added GLW */
/*#define PARSE_TEST*/
/*#define BLD_DEBUG*/

/* define function from action.c */
int strtran(char* strng, char* sub1, char* sub2);
int strtrans(char* strng, char* sub1, char* sub2);
int strscan( char* str1, char* str2);

char build_main_vers[] = "m3bld.c  Version 2.80 (April 2002)";

char szSystemCmd[256];

void print_usage ( char cmd_name[] )
	{
	fprintf ( stderr, "\nUsage: %s [-<option>...] filename\n", cmd_name );
	fprintf ( stderr, "       %s -help\n", cmd_name );
	fprintf ( stderr, "where <option> is one of the following:\n" );
	fprintf ( stderr, "  -all         compile all. Unconditionally build everything.\n" );
	fprintf ( stderr, "  -build       (default).  Read the input file and do what it says.\n" );
	fprintf ( stderr, "  -clean       Delete retrieved files after building.\n" );
	fprintf ( stderr, "  -fast_check  Replace migrated files without full checking (Cray).\n" );
	fprintf ( stderr, "  -help        Display users manual within Mosaic.\n" );
	fprintf ( stderr, "  -no_compile  fetch files but don't compile.\n" );
	fprintf ( stderr, "  -no_link     fetch and compile files but don't link.\n" );
	fprintf ( stderr, "  -one_step    One-step compile and link.\n" );
	fprintf ( stderr, "  -parse_only  Check syntax only.\n" );
	fprintf ( stderr, "  -show_only   Echo actions but don't do them.\n" );
	fprintf ( stderr, "  -make        Generate a Makefile.\n" );
	fprintf ( stderr, "  -verbose     Echo all actions.\n" );
	fprintf ( stderr, "\n" );
	}

void get_out ( char msg[] )
	{
	if ( strlen ( msg ) > (size_t) 0 )
		{
		fprintf ( stderr, "Error: %s\n", msg );
		}

	exit ( EXIT_FAILURE );
	}

/**** StartMosaicHelp **************************************
 *
 * Display the help document in Mosaic, if we are on a
 * workstation.
 *
 */
void StartMosaicHelp(void)
{
#ifdef CRAY
	printf("The help system is only available on workstations.\n\n");
#else
	if (getenv("DISPLAY") == NULL) 
		{
		fprintf(stderr, "The DISPLAY environment variable "
			"must be set.\n");
		}
	else if (getenv("EDSS_DOC") == NULL)
		{
		fprintf(stderr, "The EDSS_DOC environment variable "
			"must be set.\n");
		}
	else
		{
		sprintf(szSystemCmd, "mosaic -home %s/model_mgr/"
			"'users_manual.html#bldmod' &", getenv("EDSS_DOC"));
             /*   system(szSystemCmd);  */
		printf("Mosaic may take a few seconds to start.\n");
		}
#endif   /* CRAY */
}	/* StartMosaicHelp */

/*  function to return system's date and time  */
void showtime()
{
  struct tm *ptr;
  time_t currtime;

  currtime = time(NULL);
  ptr = localtime(&currtime);
  printf(asctime(ptr));
  return;
}

/*****************************************************************/
void getModRef( char * fname, char * modname, char * uses )
{
  FILE *fp;
  int len,i,k;
  char record[256];

   strcpy( modname, "" );
   strcpy( uses, "" );

   if( (fp = fopen(fname,"r")) != NULL )
   {
      while( !feof(fp) )
      {
         fgets( record, sizeof(record), fp );
 
         /*  change record to upper case */
         len = strlen(record);
         for(i=0; i<len; i++) if(record[i]>='a' && record[i]<='z') record[i]=record[i]-32;
         if( record[0]=='C' || record[0]=='!' ) continue;
         
         /* search for MODULE command in record */
         if( (k=strscan("   MODULE ", record)) >= 0 )
         {
            for(i=k+11; i<sizeof(record) && record[i]>32; i++); record[i]=0;
            strcpy( modname, &record[k+10] );
         }

         /* search for USE command in record */
         if( strlen(uses)<sizeof(uses)  &&  (k=strscan("   USE ", record)) >= 0 )
         {
            for(i=k+8; i<sizeof(record) && record[i]>32; i++); record[i]=0;
            strcat( uses, &record[k+7] );
         }                 
      }
      fclose(fp);
   }
 
  return;
}


/*****************************************************************/
void bldobjs( model_def_type * model_def, FILE *fp )
{
   int i,j,k,nfiles=0;
   int dupfile;
   int sorted=0, kswit, nf, nmods, swapcnt;
   char fname[256], dname[256];
   char objlist[N_SRC_FILES][80];
   char modname[N_SRC_FILES][32];
   char uses[N_SRC_FILES][256];
   char dumstr[256];

   fprintf(fp,"\n# List of Object files needed for linking");
   fprintf(fp,"\nOBJECTS =");
   /*  get list from archive_files  */
   k=1;
   for(i=0; i<model_def->archive_files.list_size ;i++)
   {
     if( (model_def->archive_files.list[i]).language == f_lang ||
         (model_def->archive_files.list[i]).language == c_lang ||
         (model_def->archive_files.list[i]).language == c_plus_plus_lang)
     {
       strcpy(fname,(model_def->archive_files.list[i]).filename);

       /*  call routine to check source file for Module and use commands */
       getModRef( fname, modname[nfiles], uses[nfiles] );

#ifdef _WIN32
       strtran(fname,".F",".obj");
       strtran(fname,".f",".obj");
       strtran(fname,".c",".obj");
       strtran(fname,".cc",".obj");
#else
       strtran(fname,".F",".o");
       strtran(fname,".f",".o");
       strtran(fname,".c",".o");
       strtran(fname,".cc",".o");
#endif
       strcpy( objlist[nfiles], fname );
       nfiles++;
     }
   }
   /*  get list from local_files  */
   for(i=0; i<model_def->local_files.list_size ;i++)
   {
     if( (model_def->local_files.list[i]).language == f_lang ||
         (model_def->local_files.list[i]).language == c_lang ||
         (model_def->local_files.list[i]).language == c_plus_plus_lang)
     {
       strcpy(fname,(model_def->local_files.list[i]).filename);
       strcpy(dname, model_def->local_files.list[i].dirname );
       strcat(dname,fname);

       /* check for duplicate source file name */
       dupfile=0;
       for(j=0; j<model_def->archive_files.list_size ;j++)
         if( strcmp(fname, model_def->archive_files.list[j].filename) == 0 ) dupfile=1;
       if(dupfile==1) continue;

       /*  call routine to check source file for Module and use commands */
       getModRef( dname, modname[nfiles], uses[nfiles] );

#ifdef _WIN32
       strtran(fname,".F",".obj");
       strtran(fname,".f",".obj");
       strtran(fname,".c",".obj");
       strtran(fname,".cc",".obj");
#else
       strtran(fname,".F",".o");
       strtran(fname,".f",".o");
       strtran(fname,".c",".o");
       strtran(fname,".cc",".o");
#endif
       strcpy( objlist[nfiles], fname );
       nfiles++;
     }
   }

   /*  sort objlist before printing  */
   nf = nfiles;
   while( sorted==0 && nf>1)
   {
      nf--;
      sorted=1;
      for(i=0; i<nf; i++)
      {
         /*  move module ahead of non-module */
         if( strlen(modname[i])==0 && strlen(modname[i+1])>0 ) 
         {
            sorted=0;
            strcpy(dumstr, objlist[i]);
            strcpy(objlist[i], objlist[i+1]); 
            strcpy(objlist[i+1], dumstr);

            strcpy(dumstr, modname[i]);
            strcpy(modname[i], modname[i+1]); 
            strcpy(modname[i+1], dumstr);

            strcpy(dumstr, uses[i]);
            strcpy(uses[i], uses[i+1]); 
            strcpy(uses[i+1], dumstr);
         }
      }
   }

   /*  put module objects in order  */
   for(nmods=0; nmods<nfiles && strlen(modname[nmods])>0; nmods++);  

   if( nmods > 1 )
   {
      swapcnt=0;
      for(i=0; i<nmods-1;)
      {
         kswit=0;
         for(k=i+1; k<nmods && kswit==0; k++)
         {
           if( strscan(modname[k],uses[i]) >=0 )
           {
               kswit=1;
               swapcnt++;
               strcpy(dumstr, objlist[i]);
               strcpy(objlist[i], objlist[k]); 
               strcpy(objlist[k], dumstr);

               strcpy(dumstr, modname[i]);
               strcpy(modname[i], modname[k]); 
               strcpy(modname[k], dumstr);

               strcpy(dumstr, uses[i]);
               strcpy(uses[i], uses[k]); 
               strcpy(uses[k], dumstr);
           }     
         }
         if( kswit==0 || swapcnt>nmods ){ swapcnt=0; i++; } /* move to next module */
      }
   }

   /*  print list of object files */
   for(i=0; i< nfiles; i++)  fprintf(fp,"\\\n %s ", objlist[i] );
   
   return;
}


/*****************************************************************/
int bldmake( model_def_type * model_def )
{
   FILE *fp;
   int i,j,k,nfiles;
   int dupfile;
   char fname[256];
   char fname_base[256];
   char cppflags[2048];   

/*  Try to open file for Makefile    */
   printf("\n Building Makefile \n");

   if( (fp = fopen("Makefile.orig","w")) == NULL )
   {
     printf("\n **Error** cannot create Makefile \n");
     return FAILURE;
   }

/*  define name of Model  */
   fprintf(fp,"MODEL = %s \n", model_def->exename );

/*  define compilers */
   fprintf(fp,"\n# Compiler Definitions");
   fprintf(fp,"\nFC   = %s",model_def->compilers[f_lang]);
   fprintf(fp,"\nCC    = %s",model_def->compilers[c_lang]);
   fprintf(fp,"\nCPLUS = %s",model_def->compilers[c_plus_plus_lang]);

/*  define precompiler */
   fprintf(fp,"\n\n# Preprocessor");
   fprintf(fp,"\nFPP  = %s",model_def->fpp);

/*  define F_FLAGS */
   fprintf(fp,"\n\n# Compiler Flags");
   fprintf(fp,"\nF_FLAGS = %s \n", model_def->compile_flags[ f_lang ] );
   fprintf(fp,"C_FLAGS = %s \n", model_def->compile_flags[ c_lang ] );
   fprintf(fp,"LINK_FLAGS = %s \n\n", model_def->link_flags );

/*  define CPP_FLAGS and print each -D on a new line*/
   strcpy( cppflags," ");                     /* set cppflags to space */
   strcat( cppflags,model_def->cpp_flags );   /* append cppflags to cpp_flags */
   strcat( cppflags," " );                    /* append a space */
   strcat( cppflags,model_def->def_flags );   /* append def_flags */

   /*  replace all backslashes used for line continuations with spaces  */
   for(i=0; cppflags[i]!='\0'; i++) if(cppflags[i]==92 && cppflags[i+1]<=32)
           cppflags[i]=' ';

   /* replace newline characters with spaces */
   for (i=0; cppflags[i] != '\0'; i++) if(cppflags[i]=='\n') cppflags[i]=32;
 
   strtrans( cppflags, " -D"," /D");

#ifdef AIX
   while( strtrans( cppflags, " /D"," \\\n -WF,-D") > 0);
#else
   while( strtrans( cppflags, " /D"," \\\n -D") > 0);
#endif

/**  print out CPP FLAGS  **/
   fprintf(fp,"CPP_FLAGS = %s \n", cppflags );

/*  libraries for linking  */
   fprintf(fp,"\n# Libraries\n");

   /*  replace all backslashes used for line continuations with spaces  */
   for(i=0; model_def->libraries[i]!='\0'; i++)
         if(model_def->libraries[i]==92 && model_def->libraries[i+1]<=32)
                                                model_def->libraries[i]=' ';

   /* replace newline characters with spaces */
   for (i=0; model_def->libraries[i] != '\0'; i++)
         if(model_def->libraries[i]=='\n') model_def->libraries[i]=32;

#if !defined(_WIN32)
   strtrans( model_def->libraries, " -L"," \\\n -L");
#endif
   fprintf(fp,"LIBRARIES = %s \n", model_def->libraries );



/*  print INCLUDES definition */
   fprintf(fp,"\n# Include file subsitution definitions");
   fprintf(fp,"\nINCLUDES = \\\n");

/*  print DSUBST_GRID_ID line  */
#ifdef AIX
   fprintf(fp," -WF,-DSUBST_GRID_ID= \\\n");
#else
   fprintf(fp," -DSUBST_GRID_ID= \\\n");
#endif

/*  print remaing include lines  */
   for(i=0; i<model_def->includes.list_size ;i++)
   {

#ifdef AIX
     fprintf(fp," -WF,-D%s=", (model_def->includes.list[i]).symbolname);
     fprintf(fp,"\\\"%s", (model_def->includes.list[i]).dirname);
     fprintf(fp,"%s\\\"", (model_def->includes.list[i]).filename);
#else
     fprintf(fp," -D%s=", (model_def->includes.list[i]).symbolname);

#ifdef _WIN32
     fprintf(fp,"\'%s", (model_def->includes.list[i]).dirname);
     fprintf(fp,"%s\'", (model_def->includes.list[i]).filename);
#else
     fprintf(fp,"\\\"%s", (model_def->includes.list[i]).dirname);
     fprintf(fp,"%s\\\"", (model_def->includes.list[i]).filename);
#endif
#endif

     if(i==model_def->includes.list_size - 1)
       fprintf(fp,"\n");
      else
       fprintf(fp," \\\n");
   }

   
/* build list of object files */
   bldobjs( model_def, fp );

/*  print SUFFIXES line */
   fprintf(fp,"\n\n.SUFFIXES: .F .f .c\n");
 
/*   start building the make lines  */
   fprintf(fp,"\n\n$(MODEL): $(OBJECTS)\n");
#ifdef _WIN32
   fprintf(fp,"\t$(FC) $(OBJECTS) /link $(LINK_FLAGS) $(LIBRARIES) /out:$(MODEL).exe\n");
   fprintf(fp,"\n.F{}.obj:\n");
   fprintf(fp,"\t$(FPP) /P /D_WIN32 $(CPP_FLAGS) $(INCLUDES) $? $*.for\n");
   fprintf(fp,"\t$(FC) -c $(F_FLAGS) $*.for\n");
   fprintf(fp,"\n.c.obj:\n\t$(CC) $(C_FLAGS) -c $<\n");
#else
   fprintf(fp,"\t$(FC) $(LINK_FLAGS) $(OBJECTS) $(LIBRARIES) -o $@\n");
   fprintf(fp,"\n.F.o:\n");
#endif


/*   for Cray */
#ifdef CRAY
   fprintf(fp,"\t$(FC) -F -eP $(F_FLAGS) $(CPP_FLAGS) $(INCLUDES) $? \n");
   fprintf(fp,"\tmv $*.i  $*.f90\n");
   fprintf(fp,"\t$(FC) -c -f fixed -F $(F_FLAGS) $*.f90 \n");
   fprintf(fp,"\n.f.o:\n\t$(FC) $(F_FLAGS) -c $<\n");
   fprintf(fp,"\n.c.o:\n\t$(CC) $(C_FLAGS) -c $<\n");
#endif


/*  for SUN and SGI  */
#if __sun || __sgi
   fprintf(fp,"\t$(FPP)  $(CPP_FLAGS) $(INCLUDES) $< $*.for\n");
   fprintf(fp,"\t$(FC) -c $(F_FLAGS) $*.for\n");
   fprintf(fp,"\n.f.o:\n\t$(FC) $(F_FLAGS) -c $<\n");
   fprintf(fp,"\n.c.o:\n\t$(CC) $(C_FLAGS) -c $<\n");
#endif

/*  for AIX and linux do not run pp */
#if defined(aix) || defined(__unix__)
   fprintf(fp,"\t$(FC) -c $(F_FLAGS) $(CPP_FLAGS) $(INCLUDES) $<\n");
   fprintf(fp,"\n.f.o:\n\t$(FC) $(F_FLAGS) -c $<\n");
   fprintf(fp,"\n.c.o:\n\t$(CC) $(C_FLAGS) -c $<\n");
#endif


/*   build list of compile lines for source file defined compile flags */
   /*  build list for archive files */
   nfiles = model_def->archive_files.list_size;
   for(i=0; i<nfiles ;i++)
   {
     /* if no local compile_flags, then skip */
     if( strlen((model_def->archive_files.list[i]).compile_flags) == 0) 
        continue;

     /* check for duplicate source file name */
     strcpy(fname,(model_def->archive_files.list[i]).filename);
     dupfile=0;
     for(j=0; j<nfiles ;j++)
       if( strcmp(fname, model_def->local_files.list[j].filename) == 0 ) dupfile=1;
     if(dupfile==1) continue;

     switch ((model_def->archive_files.list[i]).language)
     {
       case f_lang:

/*   for Cray */
#ifdef CRAY
         strtran(fname,".F",".o");
         strtran(fname,".f",".o");
         fprintf(fp,"\n%s: %s\n", fname, (model_def->archive_files.list[i]).filename);
         fprintf(fp,"\t$(FC) -F -eP %s  $(CPP_FLAGS) $(INCLUDES) $? \n",
		 (model_def->archive_files.list[i]).compile_flags );
         fprintf(fp,"\tmv $*.i  $*.f90\n");
         fprintf(fp,"\t$(FC) -c -f fixed -F $(F_FLAGS) $*.f90 \n");
#endif

/*  for Windows NT */
#ifdef _WIN32
         strtran(fname,".F",".obj");
         strtran(fname,".f",".obj");
         fprintf(fp,"\n%s: %s\n", fname, (model_def->archive_files.list[i]).filename);
         fprintf(fp,"\t$(FPP) /P /nologo /D_WIN32 $(CPP_FLAGS) $(INCLUDES) $? $*.for\n");
         
         fprintf(fp,"\t$(FC) -c %s $*.for\n",
                 (model_def->archive_files.list[i]).compile_flags);
#endif

/*  for SUN and SGI  */
#if __sun || __sgi
         strtran(fname,".F",".o");
         strtran(fname,".f",".o");
         fprintf(fp,"\n%s: %s\n", fname, (model_def->archive_files.list[i]).filename);
         fprintf(fp,"\t$(FPP)  $(CPP_FLAGS) $(INCLUDES) $< $*.for\n");
         fprintf(fp,"\t$(FC) -c %s $*.for\n",
                 (model_def->archive_files.list[i]).compile_flags);
#endif


/*  for AIX and linux do not run pp */
#if defined(aix) || defined(__unix__)
         fprintf(fp,"\t$(FC) -c %s $(CPP_FLAGS) $(INCLUDES) $<\n",
                 (model_def->archive_files.list[i]).compile_flags);
#endif
         break;

         
       case c_lang:
#ifdef _WIN32
         strtran(fname,".c",".obj");
#else
         strtran(fname,".c",".o");
#endif
         fprintf(fp,"\n%s: %s\n", fname, (model_def->archive_files.list[i]).filename);
         fprintf(fp,"\t$(CC) -c %s $<\n",
                  (model_def->archive_files.list[i]).compile_flags );
         break;
         
       case c_plus_plus_lang:
#ifdef _WIN32
         strtran(fname,".cc",".obj");
         strtran(fname,".c",".obj");
#else
         strtran(fname,".cc",".o");
         strtran(fname,".c",".o");
#endif
         fprintf(fp,"\n%s: %s\n", fname, (model_def->archive_files.list[i]).filename);
         fprintf(fp,"\t$(CPLUS) -c %s $? \n",
                  (model_def->archive_files.list[i]).compile_flags );
         break;
         
     }
   }

   /*  build make lines for local files  */
   nfiles = model_def->local_files.list_size;
   for(i=0; i<nfiles ;i++)
   {
     strcpy(fname,(model_def->local_files.list[i]).filename);
     strcpy(fname_base,(model_def->local_files.list[i]).filename);
     for(k=0; k<strlen(fname_base); k++) if(fname_base[k]=='.') fname_base[k]=0;

     switch ((model_def->local_files.list[i]).language)
     {
       case f_lang:
#ifdef CRAY
         strtran(fname,".F",".o");
         strtran(fname,".f",".o");

         fprintf(fp,"\n%s: %s%s\n", fname,(model_def->local_files.list[i]).dirname,
                 (model_def->local_files.list[i]).filename);
         if( strlen((model_def->local_files.list[i]).compile_flags) > 0)
         {
            fprintf(fp,"\t$(FC) -F -eP %s  $(CPP_FLAGS) $(INCLUDES) %s%s \n",
              (model_def->archive_files.list[i]).compile_flags,
              (model_def->local_files.list[i]).dirname,
              (model_def->local_files.list[i]).filename);
            fprintf(fp,"\tmv -f %s.i  %s.f90\n",fname_base,fname_base);
            fprintf(fp,"\t$(FC) -c -f fixed -F $(F_FLAGS) %s.f90 \n",fname_base);
         }
         else 
         {
            fprintf(fp,"\t$(FC) -F -eP $(F_FLAGS) $(CPP_FLAGS) $(INCLUDES) %s%s \n",
             (model_def->local_files.list[i]).dirname,
             (model_def->local_files.list[i]).filename);
            fprintf(fp,"\tmv -f %s.i  %s.f90\n",fname_base,fname_base);
            fprintf(fp,"\t$(FC) -c -f fixed -F $(F_FLAGS) %s.f90 \n",fname_base);
         }
         break;
#endif

#ifdef _WIN32
         strtran(fname,".F",".obj");
         strtran(fname,".f",".obj");
         fprintf(fp,"\n%s: %s%s\n", fname,(model_def->local_files.list[i]).dirname,
                 (model_def->local_files.list[i]).filename);
         fprintf(fp,"\t$(FPP)  /D_WIN32 $(CPP_FLAGS) $(INCLUDES) %s%s %s.for\n",
           (model_def->local_files.list[i]).dirname,
           (model_def->local_files.list[i]).filename,
           fname_base );
 
         if( strlen((model_def->local_files.list[i]).compile_flags) > 0)
           fprintf(fp,"\t$(FC) -c %s %s.for\n",
                 (model_def->local_files.list[i]).compile_flags,
                  fname_base );
          else
           fprintf(fp,"\t$(FC) -c $(F_FLAGS) %s.for\n", fname_base);
         break;
#endif

#if __sun || __sgi
         strtran(fname,".F",".o");
         strtran(fname,".f",".o");
         fprintf(fp,"\n%s: %s%s\n", fname,(model_def->local_files.list[i]).dirname,
                 (model_def->local_files.list[i]).filename);
         fprintf(fp,"\t$(FPP)  $(CPP_FLAGS) $(INCLUDES) %s%s %s.for\n",
           (model_def->local_files.list[i]).dirname,
           (model_def->local_files.list[i]).filename,
           fname_base );
 
         if( strlen((model_def->local_files.list[i]).compile_flags) > 0)
           fprintf(fp,"\t$(FC) -c %s %s.for\n",
                 (model_def->local_files.list[i]).compile_flags,
                 fname_base);
          else
           fprintf(fp,"\t$(FC) -c $(F_FLAGS) %s.for\n", fname_base);
         break;
#endif

/*  for AIX  do not run pp */
#if aix || __unix__
         strtran(fname,".F",".o");
         strtran(fname,".f",".o");
         fprintf(fp,"\n%s: %s%s\n", fname,(model_def->local_files.list[i]).dirname,
                 (model_def->local_files.list[i]).filename);
         if( strlen((model_def->local_files.list[i]).compile_flags) > 0)
           fprintf(fp,"\t$(FC) -c %s $(CPP_FLAGS) $(INCLUDES) %s%s\n",
                 (model_def->local_files.list[i]).compile_flags,
                 (model_def->local_files.list[i]).dirname,
                 (model_def->local_files.list[i]).filename);
          else
           fprintf(fp,"\t$(FC) -c $(F_FLAGS) $(CPP_FLAGS) $(INCLUDES) %s%s\n",
                 (model_def->local_files.list[i]).dirname,
                 (model_def->local_files.list[i]).filename);
         break;
#endif
         
       case c_lang:
#ifdef _WIN32
         strtran(fname,".c",".obj");
#else
         strtran(fname,".c",".o");
#endif
         fprintf(fp,"\n%s: %s%s\n", fname, (model_def->local_files.list[i]).dirname,
                     (model_def->local_files.list[i]).filename);
         if( strlen((model_def->local_files.list[i]).compile_flags) > 0) 
           fprintf(fp,"\t$(CC) -c %s $< \n",
                  (model_def->local_files.list[i]).compile_flags );
          else
           fprintf(fp,"\t$(CC) -c $(C_FLAGS) $<\n");
         break;
         
       case c_plus_plus_lang:
#ifdef _WIN32
         strtran(fname,".cc",".obj");
         strtran(fname,".c",".obj");
#else
         strtran(fname,".cc",".o");
         strtran(fname,".c",".o");
#endif
         fprintf(fp,"\n%s: %s%s\n", fname, (model_def->local_files.list[i]).dirname,
                     (model_def->local_files.list[i]).filename);
         if( strlen((model_def->local_files.list[i]).compile_flags) > 0) 
           fprintf(fp,"\t$(CPLUS) -c %s $<\n",
                  (model_def->local_files.list[i]).compile_flags);
          else
           fprintf(fp,"\t$(CPLUS) -c $(C_FLAGS) $<\n");
         break;
         
     }
   }


   fclose(fp);
   return SUCCESS;
}

/******************************************************************/
void setFortran( model_def_type * model_def )
{

/* set default fortran compiler  */
	strcpy( model_def->compilers[f_lang], "f90" );
	strcpy( model_def->fpp, "fpp" );

#ifdef _WIN32
	strcpy( model_def->compilers[f_lang], "df.exe" );
#endif

#ifdef _CRAY
	strcpy( model_def->compilers[f_lang], "f90" );
#endif


/*   check environmental variables to override default Fortran compiler  */
	if( getenv("FORTRAN") != NULL)
	strcpy( model_def->compilers[f_lang], getenv("FORTRAN"));

}



/******************************************************************/
int main ( int argc, char * argv[] )
	{
	extern FILE * yyin;
	int status;
	/* static file_list_type file_list; */
	static model_def_type model_def;
	int arg_cnt, char_cnt;
	
#ifdef PARSE_TEST
	int i; /* for test loop */
#endif

/*  call function to define default fortran compiler  */
	setFortran( &model_def );

/* Need multi-platform support */
	printf( "In build_main (build) Version 2.80 April 2002" );
	printf("\nArchitecture Build Information:\n");
#ifdef _WIN32
        strcpy(szSystemCmd, "ver");
        system(szSystemCmd);
        printf("\nBuild Date:\n");
        showtime();
#endif

#ifdef CRAY
        strcpy(szSystemCmd, "uname -a");
	system(szSystemCmd); 
        printf("Build Date:\n");
        strcpy(szSystemCmd, "date");
	system(szSystemCmd);
#endif

#if !defined(_WIN32) && !defined(CRAY)
        strcpy(szSystemCmd, "uname -a");
	system(szSystemCmd); 
        printf("Build Date:\n");
        strcpy(szSystemCmd, "date");
	system(szSystemCmd);
#endif

	
	if ( argc < 2 )
		{   
		print_usage ( argv[0] );
		get_out ( "Not enough arguments.  Filename is required.\n" );
		}

	if ( ( argc == 2 ) && ( strcmp ( argv[1], "-help" ) == 0 ) )
		{
		StartMosaicHelp();
		return ( EXIT_SUCCESS );
		}

	if ( argv[argc-1][0] == (char) '-' )
		{   
		print_usage ( argv[0] );
		get_out ( "last argument should be the filename\n" );
		}

#ifdef PARSE_TEST
	for ( i = 0; i < 10; i++ )
#endif
		{
		init_model_def ( & model_def );

		/* first parse the file, then process the command line arguments.
		 * That way, the command line arguments override the options in the file
		 */
		 
		yyin = fopen ( argv[argc-1], "r" );

		if ( yyin == NULL )
			{
			fprintf ( stderr, "Error: Could not open file %s for read. Exiting.\n",
			          argv[argc-1] );
			return ( EXIT_FAILURE );
			}

#ifdef PARSE_TEST
		printf ( "build %d\n", i );
                printf ( "Could open file %s for read.\n", argv[argc-1] );
#endif

		status = bld_parse ( & model_def );
		
		fclose ( yyin );
		}

	for ( arg_cnt = 1; arg_cnt < argc - 1; arg_cnt++ )
		{
		if ( argv[arg_cnt][0] != (char) '-' ) 
			{   
			print_usage ( argv[0] );
			get_out ( "Options must be preceded by '-'\n" );
			}
			
		if ( strlen ( argv[arg_cnt] ) < (size_t) 2 )
			{
			get_out ( "No white space allowed after '-'.  Exiting\n" );
			}
			
		if ( strcmp ( argv[arg_cnt], "-all" ) == 0 )
			{
			model_def.compile_all = B_TRUE;
			}
		else if ( strcmp ( argv[arg_cnt], "-build" ) == 0 )
			{
			printf ( "build mode option\n" );
			model_def.mode = build_mode;
			}
		else if ( strcmp ( argv[arg_cnt], "-clean" ) == 0 )
			{
			model_def.clean_up = B_TRUE;
			}
		else if ( strcmp ( argv[arg_cnt], "-help" ) == 0 )
			{
			StartMosaicHelp();
			}
		else if ( strcmp ( argv[arg_cnt], "-fast_check" ) == 0 )
			{
			model_def.fast_check = B_TRUE;
			}
		else if ( strcmp ( argv[arg_cnt], "-local" ) == 0 )
			{
			model_def.archive_location = local_archive;
			}
		else if ( strcmp ( argv[arg_cnt], "-no_compile" ) == 0 )
			{
			printf ( "no compile option\n" );
			model_def.mode = no_compile_mode;
			}
		else if ( strcmp ( argv[arg_cnt], "-no_link" ) == 0 )
			{
			printf ( "no link option\n" );
			model_def.mode = no_link_mode;
			}
		else if ( strcmp ( argv[arg_cnt], "-one_step" ) == 0 )
			{
			model_def.one_step = B_TRUE;
			}
		else if ( strcmp ( argv[arg_cnt], "-parse_only" ) == 0 )
			{
			printf ( "parse mode option\n" );
			model_def.mode = parse_mode;
			}
		else if ( strcmp ( argv[arg_cnt], "-remote" ) == 0 )
			{
			model_def.archive_location = remote_archive;
			}
		else if ( strcmp ( argv[arg_cnt], "-show_only" ) == 0 )
			{
			printf ( "show mode option\n" );
			model_def.show_only = B_TRUE;
			}
		else if ( strcmp ( argv[arg_cnt], "-verbose" ) == 0 )
			{
			model_def.verbose = B_TRUE;
			}
		else if ( strcmp ( argv[arg_cnt], "-make" ) == 0 )
			{
			model_def.make = B_TRUE;
			}
		else
			{
			fprintf ( stderr, "Error: unknown option '%s'\n", argv[arg_cnt] );
			print_usage ( argv[0] );
			return ( EXIT_FAILURE );
			}
		}

	if ( ( model_def.mode == parse_mode ) && ( model_def.verbose ) )
		{
		print_model_def ( & model_def );
		}
		
	if ( status == SUCCESS )
		{
		/* printf ( "Congratulations! Parser completed successfully.\n" ); */
		}
	else
		{
		printf ( "Errors detected during parsing\n" );
		return ( status ? EXIT_FAILURE : EXIT_SUCCESS );
		}

/*  printout default compilers */

        printf("\nDefault Fortran Compiler: %s",model_def.compilers[f_lang]);
        printf("\nDefault C Compiler: %s",model_def.compilers[c_lang]);
        printf("\nDefault C++ Compiler: %s",model_def.compilers[c_plus_plus_lang]);
        printf("\n\nFiles used for this build date:\n");


	if ( model_def.mode != parse_mode )
		{
		/* these functions used to be done by the parser */
#ifdef BLD_DEBUG
                printf ( "build_main:get_all_module_files\n");
#endif
		get_all_module_files ( & model_def );
#ifdef BLD_DEBUG
                printf ( "build_main:merge_file_lists\n");
#endif
		/*  call routine to build make file */
                if( model_def.make )
		{
		  status = bldmake( & model_def );
		  return ( status ? EXIT_FAILURE : EXIT_SUCCESS );	
		}

		merge_file_lists ( & model_def );
#ifdef BLD_DEBUG
                printf ( "build_main:retrieve_and_build\n");
#endif
		status = retrieve_and_build ( & model_def );
		}

#ifdef BLD_DEBUG
	printf ( "bldmod: returning with status of %d\n", 
	         status ? EXIT_FAILURE : EXIT_SUCCESS );	
#endif

	return ( status ? EXIT_FAILURE : EXIT_SUCCESS );	
	}


