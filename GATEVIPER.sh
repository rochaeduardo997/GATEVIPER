#!/bin/bash
echo -e "--------------------------------------------------------------------------------" >> log.txt
echo -e "Starting at `date +%T" - "%d"."%m"."%Y`\n" >> log.txt

date=`date +%d%m%Y`

directoryToBackup=`hostname`-bkp_$date
databaseToBackup=`hostname`-bkp_$date.sql

dbUsername=""
dbPassword=""
dbName=""

rsync -Aax /var/www/html/ $directoryToBackup
mysqldump --single-transaction -u$dbUsername -p$dbPassword $dbName > $databaseToBackup

compressedFile=`hostname`-bkp_$date.tar.gz

tar -czf $compressedFile $directoryToBackup $databaseToBackup

rm -rf $directoryToBackup $databaseToBackup

cutDelimiter='cut -d " " -f 1'

hashGenerated=`sha256sum $compressedFile | cut -d " " -f 1`

#echo $hashGenerated

echo -e "File generated: $compressedFile\n" >> log.txt
echo -e "Hash generated: $hashGenerated\n" >> log.txt

serverPassword=""
serverIPAddress=""
serverUsername=""
serverPathToStore=""

sshpass -p $serverPassword scp $compressedFile suporte@$serverIPAddress:$serverPathToStore

hashGeneratedDestination=`sshpass -p $serverPassword ssh $serverUsername@$serverIPAddress "sha256sum $serverPathToStore/$compressedFile | $cutDelimiter"`

#echo $hashGeneratedDestination

if [ $hashGenerated == $hashGeneratedDestination ]
then
	echo -e "Hash O.K, sucessful\n" >> log.txt
	rm -rf $compressedFile
else
	echo -e "Hash fail, restarting at `date +%T" - "%d"."%m"."%Y`\n" >> log.txt
	echo -e "--------------------------------------------------------------------------------" >> log.txt

fi

echo -e "Finished at `date +%T" - "%d"."%m"."%Y`" >> log.txt
echo -e "--------------------------------------------------------------------------------" >> log.txt
