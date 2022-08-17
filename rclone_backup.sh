#!/bin/bash

# Don't change this! It allows all our scripts to base include, log, etc. paths off the
# directory the backup script lives in to keep everything contained.
cd /volume1/BackupStorage
#cd /mnt/c/WPLG
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#######

# Include everything we need to run... change the order at your own risk (don't do it)
source "$SCRIPT_HOME/inc/defaults.sh" || exit 1
source "$SCRIPT_HOME/inc/logging.sh" || exit 1
source "$SCRIPT_HOME/inc/funcs.sh" || exit 1

cleanupLogs
trimMonthly
trimYearly
trimDaily
backup
createMonthly
createYearly
finish
