#! /bin/bash

#############################################################
# name:        MC-Backup                                    # 
# author:      Colgate                                      #
# description: Full backup script for bukkit servers        #
#############################################################  

######## Configuration variables go here ########

# Location of your server(s). [Default = /servers]
serverdir=/servers

# Directory you will keep your backup files [Default = /backups]
backupdir=/backups

# Number of days to keep backups for. [Default = 7]
retain=7


######## Don't modify below this line unless you really know what you're doing. Or if you like breaking things. ########

today=$(date +"%m-%d-%Y")

echo -e "\nBackup run started for $today\n\n\tRemoving backups older than $retain days";
find $backupdir -type f -name "*.tar.gz" -mtime $((retain - 1)) -exec echo -e "\tRemoving {}" \; -delete;

for i in $(/bin/ls $serverdir); 
do
    #Verify everything looks proper before beginning.
    [[ ! -d $backupdir ]] && { echo -e "\tBackup directory does not exist. Creating."; mkdir -p $backupdir; }
    [[ ! -d $backupdir/$i ]] && { echo -e "\tBackup location for this server does not exist. Creating."; mkdir -p $backupdir/$i; }
    [[ -e $backupdir/$i/backup_$i-$today.tar.gz ]] && echo -e "\n\tIt looks like a backup matching today's date was already created for $i. Cannot proceed." || {
        echo -e "\n\tBeginning backup process for server $i.\n\tCreating temporary directory structure.";
        mkdir -p $backupdir/backup-$i/mysql;
        echo -e "\tLocating and dumping any relevant databases."
        mysql -sse "show databases like \"$i\_%\"" | while read db; do mysqldump $db > $backupdir/backup-$i/mysql/$db.sql; done
        echo -e "\tCopying over the server files.";
        rsync -avP $serverdir/$i $backupdir/backup-$i/ &>/dev/null;
        echo -e "\tCreating archive.";
        tar -zcf $backupdir/$i/backup_$i-$today.tar.gz -C $backupdir backup-$i
        echo -e "\tCleaning up temporary directory.";
        rm -rf $backupdir/backup-$i/
        echo -e "\n\tDone backing up $i. File was created at $backupdir/$i/backup_$i-$today.tar.gz."
    }
done

echo -e "\nBackup run completed for $today."