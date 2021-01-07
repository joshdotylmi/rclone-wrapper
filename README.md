## rclone bash wrapper ##
This is forked from  jessedp, it builds on their script and strips out functions i didn't need.


This started as a simple bash script to make defining various sources/destinations and running with the various arguments I wanted quicker and easier across multiple machines, especially laptops.

It's quite opinionated, but could give someone a structure to (mis)use for their own rclone wrapper or whatever.

### requirements ###
- rclone v1.42+ [here](https://rclone.org/downloads/)
    + install from there, your package manager probably doesn't have the newer version (ubuntu 18 doesn't) and some of the arguments use require this.

#### optional ####
`ssmmtp` (you probably already have it)

### features ###

- built-in semi-validation of the config files (not for filters)

- logging
    + logs the full script and rclone output to both stdout and a file per run
    + configurable number of log files to keep around (eg, defaults to last 20)
- can mail the run's complete log file if errors occur using SSMTP (must be configured in /etc/ssmtp/ssmtp.conf)
- pretty decent code separation so it's easier to naviagate/modify


### limitations ###
- built to be used with cron
- again, opinionated.
- currently only uses rclone's `copy`
- loads of other rclone arguments are not used, may require a bunch of changes if you have crazy requirements
    + then again, with the code separated as it is, wouldn't be too hard to pop new function/vars
- if anyone ever creates a pull request, it will probably be to add to this list

### installation ###
- download the zip file from above and extract it to its own directory. The scripts are competely self-contained there with regards to writing any files
- configure it (as below)

### running ###
0. do the configuration stuff below
1. exec the rclone_backup.sh - `./rclone_backup.sh` or `sh rclone_backup.sh`
2. set it up as a cron job if you'd like (it will figure out its own root path)

### configuring ###

1. [Configure](https://rclone.org/docs/) at least 1 storage system using `rclone config`
2. Edit your "bucket" (source/destination) **config**  files in the `config/` directory. See below for an example.
3. Peruse the `inc/defaults.sh` file and make any changes you feel necessary.

#### config files ####
edit defaults.sh.



