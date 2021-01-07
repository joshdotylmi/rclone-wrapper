# See if it's time to do a full run or bail
shouldRun() {
if pgrep -x "rclone" > /dev/null
then
    log "Rclone is already running, exiting"
	exit
else
    log "Rclone is not already running"
fi
}

# make sure we have a network connection, otherwise our purpose for this is futile
checkNetwork() {
    log "Checking network connectivity..."
    if ping -q -c 4 -W 5 google.com >/dev/null; then
        NET_UP=true
        log "Network up."
    else
      log "The network is down, not running backup"
      exit -1
    fi  
}

# used by validateConfig - wipes out the bucket vars to make sure we're validating each one on its own
resetConfig() {
    declare -a fields=("FILTER_FILE" "SOURCE_PATH" "DESTINATION_PATH" "ARCHIVE_DESTINATION_PATH")
    
    for field in "${fields[@]}"
    do
        eval "$field"=""
    done
}

# validate - as in make sure they are filled in - the bucket vars we're going to use.
validateConfig() {
    resetConfig
    BADCFG=0
    for CFGFILE in $SCRIPT_HOME/config/*.sh; 
    do 
        source $CFGFILE

        echo "Validating required fields in: $CFGFILE"
        
        declare -a fields=("FILTER_FILE" "SOURCE_PATH" "DESTINATION_PATH" "ARCHIVE_DESTINATION_PATH")
        
        for field in "${fields[@]}"
        do
           TEST="$(echo -e "${!field}" | tr -d '[:space:]')"
           if [ -z "$TEST" ]; then
                echo -e "\tBAD: $field can not be empty!"
                BADCFG=1
           else
                echo -e "\tGood: $field (${!field})"
           fi
        done
    done

    if [ $BADCFG != 0 ]; then
        echo -e "\nThere are errors in you config files. Please correct them.\n"
        exit
    fi

}

# run the indiivual backup for each bucket config
#runBackups() {
#    for CFGFILE in $SCRIPT_HOME/config/*.sh; 
#    do 
#        source $CFGFILE
#        backup
#    done
#    finish
#}

# This wraps up the rclone command and params to run each for each bucket config
backup() {
    log "Starting backup of $SOURCE_PATH dirs"
    NICE_CMD=""
    if [ $IS_ROOT == 1 ]; then
        NICE_CMD="nice -n $NICE"
    elif [ $USE_SUDO == 1 ]; then
        NICE_CMD="sudo nice -n $NICE"
    fi

    (set -x; \
    /usr/bin/time -v -o $LOGFILE -a \
        $NICE_CMD ./rclone copy $SOURCE_PATH $DESTINATION_PATH \
        --log-file=$LOGFILE \
        --log-level INFO \
		--config $rcloneconfig \
        --stats-log-level DEBUG \
         >> $LOGFILE;
    )

    #  --backup-dir=$ARCHIVE_DESTINATION_PATH \
    #  -vvv
    #  --dry-run  -vvv

    if [ $? != 0 ]; then
        FAILURE=1
        log "BACKUP FAILED - ${SOURCE_PATH} dirs  - ${?}"
    else
        log "FINISHED BACKUP - ${SOURCE_PATH} dirs"
    fi
	finish
}

# if configured, try to email you/someone if there's a problem with the backups
notifyFailure() {
    
  
        log "Attempting to notify about backup problem..."
#        RESULT=`curl -o /dev/null -s -w "%{http_code}\n" --user "api:$MAILGUN_APIKEY" \
#            https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages \
#            -F from=$MAILGUN_FROM \
#            -F to=$MAILGUN_TO \
#            -F subject="$MAILGUN_SUBJECT" \
#            -F text="$(cat $LOGFILE)" `
			#RESULT=$(cat $LOGFILE | ssmtp $MAIL_TO_STATUS)
			printf '%s\n' "Subject: Backup Error" "$(cat $LOGFILE)" | ssmtp $MAIL_TO_FAILURE

        if [ $? = 0 ]; then
            log "Error email sent"
        else
            log "UNABLE to send error email!"
        fi
    
    
}
notifyStatus() {
    
        log "Attempting to notify about backup status..."
#        RESULT=`curl -o /dev/null -s -w "%{http_code}\n" --user "api:$MAILGUN_APIKEY" \
#            https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages \
#            -F from=$MAILGUN_FROM \
#            -F to=$MAILGUN_TO \
#            -F subject="$MAILGUN_SUBJECT" \
#            -F text="$(cat $LOGFILE)" `
			#RESULT=$(cat $LOGFILE | ssmtp $MAIL_TO_STATUS)
			printf '%s\n' "Subject: Backup Status" "$(cat $LOGFILE)" | ssmtp $MAIL_TO_STATUS

        if [ $? = 0 ]; then
            log "Status email sent"
        else
            log "UNABLE to send Status email!"
        fi
    
    
}
trim() {
log "Trim on $STORAGE_PATH with $daysofbackup days of retention started "
find $STORAGE_PATH* -type d -ctime $daysofbackup -print0 | while read -d $'\0' file
	do
	log "deleting backup $file"
	rm -rf $file
	done
log "Backup trim finished"

}

finish() {
    touch $LASTFILE
    if [ $FAILURE == 1 ]; then
        notifyFailure
		notifyStatus
    fi
	notifyStatus
}
