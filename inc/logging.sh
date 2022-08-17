# Setup logging
LOGDIR="$SCRIPT_HOME/logs"
LOGFILE="$LOGDIR/backup_$(date +'%Y%m%d_%H%M%S').log"
USERFRIENDLYLOG="$LOGDIR/USERFRIENDLYLOG_$(date +'%Y%m%d_%H%M%S').log"
mkdir -p $LOGDIR
touch $LOGFILE



# Logs to both the screen and to rclone's log file (in the same format as rclone)
log() {
    date=$(date +'%Y/%m/%d %H:%M:%S')
    if [ "$CRON" != "1" ]; then
        echo -e "$date $1"
    fi
    echo -e "$date **SH**: $1" >> $LOGFILE
    #echo -e "$date **SH**: $1" >> $USERFRIENDLYLOG

}

cleanupLogs() {

log "Cleaning up old log files, $LOGS_TO_KEEP days worth of logs are kept within $logdirstorage"
	
find $LOGDIR* -ctime $LOGS_TO_KEEP -maxdepth 1 -print0 | while read -d $'\0' logfilesdeleted
	do
	log "Deleting log $logfilesdeleted within $LOGDIR"
	rm -rf $logfilesdeleted
	done
	 
}
