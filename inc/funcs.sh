# This wraps up the rclone command and params to run each for each bucket config
backup() {
    log "Starting backup of $SOURCE_PATH dirs"
    #NICE_CMD=""
    #if [ $IS_ROOT == 1 ]; then
    #    NICE_CMD="nice -n $NICE"
    #elif [ $USE_SUDO == 1 ]; then
    #    NICE_CMD="sudo nice -n $NICE"
    #fi

    (set -x; \
    /usr/bin/time -va -o $LOGFILE \
        ./rclone copy $SOURCE_PATH $DESTINATION_PATH \
        --log-file=$USERFRIENDLYLOG \
		--transfers=10 \
		--retries 10 \
        --log-level ERROR \
		--config $rcloneconfig \
		--ignore-checksum \
        --filter-from $ROOT_PATH/excluded \
         >> $LOGFILE;
    )

    if [ $? != 0 ]; then
        FAILURE=1
        log "BACKUP FAILED - ${SOURCE_PATH} dirs  - ${?}"
    else
        log "FINISHED BACKUP - ${SOURCE_PATH} dirs"
        rm "$ROOT_PATH/lastrun.txt"
        echo "$DESTINATION_PATH" > "$ROOT_PATH/lastrun.txt"
    fi
	
}

# if configured, try to email you/someone if there's a problem with the backups
notifyFailure() {
    
  
        log "Attempting to notify about backup problem..."
        log $LOGFILE
        log $USERFRIENDLYLOG
            printf '%s\n' "Subject: ShareFile Backup Error" "Backup finished with errors please contact it@lmi.net $(tail -n 1000 $USERFRIENDLYLOG)" | ssmtp $MAIL_TO_FAILURE
            printf '%s\n' "Subject: Synology ShareFile Backup Error DEV LOG" "Backup finished with errors $(tail -n 1000 $LOGFILE) $(tail -n 1000 $USERFRIENDLYLOG)" | ssmtp $MAIL_TO_FAILUREDEV
			#printf '%s\n' "Subject: Synology ShareFile Backup Error" "Backup finished with errors please contact testemail@email.net"|(cat - && uuencode $LOGFILE $LOGFILE) | ssmtp $MAIL_TO_FAILURE

        if [ $? = 0 ]; then
            log "Error email sent"
        else
            log "UNABLE to send error email!"
        fi
    
    
}
notifyStatus() {
        log $LOGFILE
        log $USERFRIENDLYLOG
        log "Attempting to notify about backup status..."

            printf '%s\n' "Subject:  Synology ShareFile Backup Status" "Backup completed successfully $(tail -n 1000 $USERFRIENDLYLOG)"| ssmtp $MAIL_TO_STATUS
            printf '%s\n' "Subject:  Synology ShareFile Backup Status DEV LOG" "Backup completed successfully $(tail -n 1000 $LOGFILE) $(tail -n 1000 $USERFRIENDLYLOG)"| ssmtp $MAIL_TO_FAILUREDEV
        if [ $? = 0 ]; then
            log "Status email sent"
        else
            log "UNABLE to send Status email!"
        fi
    
    
}
trimDaily() {
log "Trim on $ROOT_PATH/DownloadedFiles with $daysofbackup days of retention started "
find $ROOT_PATH/DownloadedFiles* -type d -mtime $daysofbackup -maxdepth 1 -print0 | while read -d $'\0' file
	do
	log "deleting backup $file"
    echo $file
	rm -rf $file
	done
log "Backup trim finished"

}

finish() {
    touch $LASTFILE
    if [ $FAILURE == 1 ]; then
        sleep 60
        notifyFailure
		
    fi
	if [ $FAILURE == 0 ]; then
       sleep 60
       notifyStatus
		
    fi
	
}

createMonthly() {
    if [ -d $ROOT_PATH/MonthlyDownloadedFiles ]; then
 
  log "Monthly folder exists" 
else
  log "Monthly folder doesn't exist, creating $ROOT_PATH/MonthlyDownloadedFiles"
 mkdir -v $ROOT_PATH/MonthlyDownloadedFiles
fi
for MonthlyDownloadedFiles in "$ROOT_PATH/MonthlyDownloadedFiles/$(date +'%Y-%m')"*; do

    ## Check if the glob gets expanded to existing files.
    ## If not, f here will be exactly the pattern above
    ## and the exists test will evaluate to false.
    ## https://github.com/koalaman/shellcheck/wiki/SC2144
    if [ -e "$MonthlyDownloadedFiles" ]; then
 log "Monthly archive exists, not copying latest backup to Monthly archive"
 break
else
log "Monthly archive doesn't exist copying latest backup to Monthly archive"
    cp -frv --preserve "$(cat $ROOT_PATH/lastrun.txt)" $ROOT_PATH/MonthlyDownloadedFiles >> $LOGFILE;
    break
fi
done
}
createYearly(){
        if [ -d $ROOT_PATH/YearlyDownloadedFiles ]; then
  
 log "Yearly parent folder exists" 
else
  log "Yearly parent folder doesn't exist, creating $ROOT_PATH/YearlyDownloadedFiles"
  mkdir -v $ROOT_PATH/YearlyDownloadedFiles
fi
for YearlyDownloadedFiles in "$ROOT_PATH/YearlyDownloadedFiles/$(date +'%Y')"*; do

    ## Check if the glob gets expanded to existing files.
    ## If not, f here will be exactly the pattern above
    ## and the exists test will evaluate to false.
    ## https://github.com/koalaman/shellcheck/wiki/SC2144
    if [ -e "$YearlyDownloadedFiles" ]; then
 log "Yearly archive exists, not copying latest backup to yearly archive"
 break
else
log "Yearly archive doesn't exist copying latest backup to yearly archive"
    cp -frv --preserve "$(cat $ROOT_PATH/lastrun.txt)" $ROOT_PATH/YearlyDownloadedFiles >> $LOGFILE;
    break
fi
done
}
trimMonthly() {
log "Trim on $ROOT_PATH/MonthlyDownloadedFiles with $monthsofbackup days of retention started "
find $ROOT_PATH/MonthlyDownloadedFiles* -type d -mtime $monthsofbackup -maxdepth 1 -print0 | while read -d $'\0' file
	do
	log "deleting backup $file"
	echo $file
    rm -rf $file
	done
log "Monthly backup trim finished"

}
trimYearly() {
log "Trim on$ROOT_PATH/YearlyDownloadedFiles with $yearsofbackup days of retention started "
find $ROOT_PATH/YearlyDownloadedFiles* -type d -mtime $yearsofbackup -maxdepth 1 -print0 | while read -d $'\0' file
	do
	log "deleting backup $file"
	echo $file
    rm -rf $file
	done
log "Yearly backup trim finished"

}
