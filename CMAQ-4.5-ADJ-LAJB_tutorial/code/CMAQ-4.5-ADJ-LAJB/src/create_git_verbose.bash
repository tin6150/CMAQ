#!/bin/bash
#
# Portions of Models-3/CMAQ software were developed or based on information
# from various groups: Federal Government employees, contractors working on a
# United States Government contract, and non-Federal sources (including
# research institutions).  These research institutions have given the
# Government permission to use, prepare derivative works, and distribute copies
# of their work in Models-3/CMAQ to the public and to permit others to do so.
# EPA therefore grants similar permissions for use of the Models-3/CMAQ
# software, but users are requested to provide copies of derivative works to
# the Government without restrictions as to use by others.  Users are
# responsible for acquiring their own copies of commercial software associated
# with Models-3/CMAQ and for complying with vendor requirements.  Software
# copyrights by the MCNC Environmental Modeling Center are used with their
# permissions subject to the above restrictions.
#
# Author: Lucas A. J. Bastien
#
# This script creates the FORTRAN subroutine named GIT_VERBOSE in the file
# ./src/git_verbose.F. The subroutine writes into the IOAPI log file(s)
# information about the state of the CMAQ-v4.5-ADJ code (i.e. the code in this
# git repository) at the time this script was called. More precisely, it prints
# out:
#
# - information about the latest commit (i.e. output of git log -n 1).
# - the output of git status.
# - the output of git diff HEAD.
# - the output of git branch -v.
#
# If this script is called right before the CMAQ-v4.5-ADJ code is compiled and
# if the corresponding GIT_VERBOSE subroutine is called by the code at
# run-time, then the IOAPI log file(s) will contain an exact and full
# characterization of the code that went into the executable binary file used
# for the corresponding run. As a matter of fact, the information written to
# the IOAPI log file(s) by GIT_VERBOSE is sufficient to be able to retrieve the
# full code used when compiling the code.

# Get name of destination

current_dir=$(pwd)
if [ -z ${DIR_REPO+1} ]; then
    echo "The environment variable DIR_REPO needs to be set."
    exit -1
else
    cd $DIR_REPO
    f=$DIR_REPO/src/git_verbose.F
fi

# Useful resources

w1="WRITE(LOGDEV, '(5X,A)')"
w2="WRITE(LOGDEV, '(A)')"
function format_string () { echo $* | awk '{gsub(/\"/,"\"\"")}1'; }

# The following setting makes read keep the blank space at the beginning of
# lines

IFS=''

# License statement

echo "C     Portions of Models-3/CMAQ software were developed or based on"       > $f
echo "C     information from various groups: Federal Government employees,"     >> $f
echo "C     contractors working on a United States Government contract, and"    >> $f
echo "C     non-Federal sources (including research institutions).  These"      >> $f
echo "C     research institutions have given the Government permission to use," >> $f
echo "C     prepare derivative works, and distribute copies of their work in"   >> $f
echo "C     Models-3/CMAQ to the public and to permit others to do so.  EPA"    >> $f
echo "C     therefore grants similar permissions for use of the Models-3/CMAQ"  >> $f
echo "C     software, but users are requested to provide copies of derivative"  >> $f
echo "C     works to the Government without restrictions as to use by others."  >> $f
echo "C     Users are responsible for acquiring their own copies of commercial" >> $f
echo "C     software associated with Models-3/CMAQ and for complying with"      >> $f
echo "C     vendor requirements.  Software copyrights by the MCNC"              >> $f
echo "C     Environmental Modeling Center are used with their permissions"      >> $f
echo "C     subject to the above restrictions."                                 >> $f
echo "C"                                                                        >> $f
echo "C     Author: Lucas A. J. Bastien"                                        >> $f
echo ""                                                                         >> $f

# Start

echo "      SUBROUTINE GIT_VERBOSE()"                >> $f
echo ""                                              >> $f
echo "      IMPLICIT NONE"                           >> $f
echo ""                                              >> $f
echo "      INCLUDE SUBST_IODECL"                    >> $f
echo ""                                              >> $f
echo "      LOGICAL, SAVE :: FIRSTIME = .TRUE."      >> $f
echo "      INTEGER :: LOGDEV"                       >> $f
echo ""                                              >> $f
echo "      IF (FIRSTIME) THEN"                      >> $f
echo "         LOGDEV = INIT3()"                     >> $f
echo "         FIRSTIME = .FALSE."                   >> $f
echo "      END IF"                                  >> $f
echo ""                                              >> $f
echo "      $w1 \"\""                                >> $f
echo "      $w1 \"*******************************\"" >> $f
echo "      $w1 \"***** GIT VERBOSE (START) *****\"" >> $f
echo "      $w1 \"*******************************\"" >> $f

# Last commit

echo "      $w1 \"\""            >> $f
echo "      $w1 \"-----------\"" >> $f
echo "      $w1 \"Last commit\"" >> $f
echo "      $w1 \"-----------\"" >> $f
echo "      $w1 \"\""            >> $f
git --no-pager log -n 1 | while read -r line ; do
    echo "      $w2 \"$line\""   >> $f
done

# Difference with last commit

echo "      $w1 \"\""                                      >> $f
echo "      $w1 \"-------------------------------------\"" >> $f
echo "      $w1 \"Difference with last commit (summary)\"" >> $f
echo "      $w1 \"-------------------------------------\"" >> $f
echo "      $w1 \"\""                                      >> $f
git --no-pager status --porcelain | while read -r line ; do
    echo "      $w2 \"$(format_string $line)\""            >> $f
done

echo "      $w1 \"\""                                       >> $f
echo "      $w1 \"--------------------------------------\"" >> $f
echo "      $w1 \"Difference with last commit (detailed)\"" >> $f
echo "      $w1 \"--------------------------------------\"" >> $f
echo "      $w1 \"\""                                       >> $f
git --no-pager diff --color=never HEAD | while read -r line ; do
    echo "      $w2 \"$(format_string $line)\""             >> $f
done

# Branch

echo "      $w1 \"\""       >> $f
echo "      $w1 \"------\"" >> $f
echo "      $w1 \"Branch\"" >> $f
echo "      $w1 \"------\"" >> $f
echo "      $w1 \"\""       >> $f
git branch -v --color=never | while read -r line ; do
    echo "      $w2 \"$(format_string $line)\"" >> $f
done

# End

echo "      $w1 \"\""                                >> $f
echo "      $w1 \"*******************************\"" >> $f
echo "      $w1 \"***** GIT VERBOSE ( END ) *****\"" >> $f
echo "      $w1 \"*******************************\"" >> $f
echo "      $w1 \"\""                                >> $f
echo ""                                              >> $f
echo "      END SUBROUTINE GIT_VERBOSE"              >> $f
echo ""                                              >> $f

cd $current_dir
