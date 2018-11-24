#!/bin/bash

# Cardinal Install Script
# falcon78921

# This script is designed to configure Cardinal information, such as system variables, system dependencies, etc. 
# If anything needs improvement, please open a pull request on my GitHub! Thanks!

######################################################################
# IMPORTANT: Wipe out the OLD configuration before using this script!#
######################################################################

# First, we need to know some things. How about we start with database (MySQL) information?
echo "Welcome to the Cardinal Initial Configuration Guide!"
echo "For more information, please visit http://cardinal.mcclunetechnologies.net"
echo "MySQL Information"
echo -e ""
read -p "Hello, welcome to Cardinal! What is the hostname/IP address of the database for Cardinal? " varDatabaseIP
echo -e ""
read -p "Ok, I got it. How about an username for the database? " varDbUsername
echo -e ""
read -p "Great! How about a password for the database? " varDbPassword
echo -e ""
read -p "Okay, now we need a name for the database. What is the database name? " varDbName
echo -e ""
read -p "Okay, now we need to add a Cardinal Admin. What is the desired username for Cardinal? " varCardinalUser
echo -e ""
read -p "Okay, now what is the Cardinal Admin's password? " varCardinalPass
echo -e ""
read -p "Finally, where do you want to store your MySQL database information? REMEMBER: This location shouldn't be the web root, this should be a directory outside of the web root. Please make sure you give www-data or your web server rights to read the file. " varDbCredDir
echo -e ""
echo "Cardinal Settings & Configuration"
read -p "Okay, now we need a directory where Cisco IOS images reside. Where is this directory at? " varTftpDir
echo -e ""
read -p "Okay, now we need a directory where the Cardinal scripts will reside. Preferably, this should be OUTSIDE of the web root. What is the directory? " varDirScripts
echo -e ""
read -p "Okay, now we need a duration (in minutes) when Cardinal will pull info from access points (e.g. clients associated, bandwidth, etc.) What is the desired duration in minutes?" varSchedulePoll
echo -e ""
read -p "Okay, now we need the base location of your Cardinal installation. What is the absolute path of your Cardinal installation? " varCardinalBase
echo "Thank you for installing Cardinal!"

# Let's create a php_cardinal.php configuration file based on user input (for Cardinal SQL connections)
rm $varDbCredDir/cardinalmysql.ini
touch $varDbCredDir/cardinalmysql.ini
echo "[cardinal_mysql_config]" >> $varDbCredDir/cardinalmysql.ini
echo 'servername'=""$varDatabaseIP"" >> $varDbCredDir/cardinalmysql.ini
echo 'username'=""$varDbUsername"" >> $varDbCredDir/cardinalmysql.ini
echo 'password'=""$varDbPassword"" >> $varDbCredDir/cardinalmysql.ini
echo 'dbname'=""$varDbName"" >> $varDbCredDir/cardinalmysql.ini

# Let's also give the non-web directory Apache read rights
chown -R www-data:www-data $varDbCredDir
chown -R www-data:www-data $varConfigDir
chown -R www-data:www-data $varDirScripts
chown -R www-data:www-data $varTftpDir

# Now, let's create the MySQL database for Cardinal. We also want to import the SQL structure too!
mysql -u$varDbUsername -p$varDbPassword -e "CREATE DATABASE "$varDbName""
mysql -u$varDbUsername --password=$varDbPassword $varDbName < $varCardinalBase/sql/cardinal.sql

# Add Cardinal configuration to MySQL
mysql -u$varDbUsername -p$varDbPassword $varDbName -e "INSERT INTO settings (settings_id,cardinal_home,cardinal_scripts,cardinal_tftp,poll_schedule) VALUES ('1','$varConfigDir','$varDirScripts','$varTftpDir','$varSchedulePoll')"

# Now, let's create a Cardinal admin
hashedPass=$(python -c 'import crypt; print crypt.crypt("'$varCardinalPass'", "$6$random_salt")')
mysql -u$varDbUsername -p$varDbPassword $varDbName -e "INSERT INTO users (username,password) VALUES ('$varCardinalUser','$hashedPass')"
