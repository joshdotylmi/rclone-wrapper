# Default vars for setting up destination paths... DEST_BUCKET/computer_name/user_name
COMPUTER_NAME=$(hostname -s)
USER_NAME=$(whoami)

# Script will exit if a non-failed backup has been run less than this many hours ago.
# Convenient to scheduling frequently (like hourly) on laptops, but not actually runninng
# a backup everytime
# Default = 12
MIN_HOURS=12

# Maximum number of log files to leave around
# Default = 20
LOGS_TO_KEEP="+90"

# Use sudo if we can? Used to "nice" the rclone command and run it in case you're 
# trying to backup stuff you can't access w/o it.
# 1 == Yes
# 0 == No (0 or anything else)
#USE_SUDO=0

#ROOT_PATH="/mnt/c//"

ROOT_PATH="/volume1/BackupStorage"
#SOURCE_PATH="Sharefile:/"
SOURCE_PATH="Sharefile:/"
DESTINATION_PATH="/volume1/BackupStorage/DownloadedFiles/$(date +%F)"
STORAGE_PATH="/volume1/BackupStorage/DownloadedFiles/"
logdirstorage="/volume1/BackupStorage/logs/"

MAIL_TO_STATUS="testemail@email.net"

MAIL_TO_STATUSDEV="testemail@email.net"
MAIL_TO_FAILURE="testemail@email.net"
MAIL_TO_FAILUREDEV="testemail@email.net"
daysofbackup="+45"
#In days
monthsofbackup="+365"
#In days
yearsofbackup="+3650"
rcloneconfig="rclone.conf"
####### These probably don't need to be changed #######
# The file we drop after backups
# Default = "$SCRIPT_HOME/.lastrun"
LASTFILE="$SCRIPT_HOME/.lastrun"

# Leave this alone - used to track failures during a single backup run
# Default = 0
FAILURE=0

#############################################

# If we can sudo (or are root), "nice" rclone to prevent it from slowing other stuff down.
# Default = -5
NICE=-5

IS_ROOT=0
if [ "$EUID" -eq "0" ]; then
    IS_ROOT=1
fi
