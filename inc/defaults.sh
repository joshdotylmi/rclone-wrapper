# Default vars for setting up destination paths... DEST_BUCKET/computer_name/user_name
COMPUTER_NAME=$(hostname -s)
USER_NAME=$(whoami)

# Script will exit if a non-failed backup has been run less than this many hours ago.
# Convenient to scheduling frequently (like hourly) on laptops, but not actually runninng
# a backup everytime
# Default = 12
MIN_HOURS=12

# Days of logs to keep around to leave around
# Default = 20
LOGS_TO_KEEP="+90"

# Use sudo if we can? Used to "nice" the rclone command and run it in case you're 
# trying to backup stuff you can't access w/o it.
# 1 == Yes
# 0 == No (0 or anything else)
USE_SUDO=0
SOURCE_PATH=""
DESTINATION_PATH="./DownloadedFiles/$(date +%F_%H-%M-%S)"
STORAGE_PATH="./DownloadedFiles/"
logdirstorage="./BackupStorage/logs/"
#This should contain a email.
MAIL_TO_STATUS=""
MAIL_TO_FAILURE=""
daysofbackup="+90"
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