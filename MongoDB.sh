#!/bin/bash
TIME=$(date)
USERID=$(id -u) #Stores User UID
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_Folder="/var/log/Roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_Folder/$SCRIPT_NAME.log"
mkdir -p $LOGS_Folder

echo -e  "$R Script Executed at:$TIME $N" | tee -a $LOG_FILE # Tee command Display the content on Screen

if [ $USERID -ne 0 ] #Checks Whether UID is = 0 or not
then #!= 0 Enter into Loop
    echo -e "$R Error:Please proceed the Installation with sudo $N" | tee -a $LOG_FILE #Prints this messages on Screen
    exit 1 #!= 0 Don't Proceed with next command and Exit
else #If =0 Enter into else loop
    echo -e "$Y Please proceed the Installation $N" | tee -a $LOG_FILE #Prints this messages on Screen
fi #Condition Ends

Validate (){ #Function Definition
    if [ $1 -eq 0 ] #Checks If Exit code equls to Zero, Yes
    then #Enter into Loop
        echo -e "$G $2...... is suceefull $N"  | tee -a $LOG_FILE #Prints this messages on Screen
    else #Checks If Exit code != Zero, No
        echo -e " $R $2 ......is failed $N" | tee -a $LOG_FILE #Prints this messages on Screen
        exit 1 #Condition Exits and Entire Script Fails.
    fi #Condition Ends
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>LOG_FILE
Validate $? "Coping of MongoDB Repo"

dnf install mongodb-org -y &>>LOG_FILE
Validate $? "MongoDB Installation"

systemctl enable mongod | tee -a $LOG_FILE
Validate $? "MongoDB Service Enabled" 

systemctl start mongod | tee -a $LOG_FILE
Validate $? "MongoDB Service Started" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
Validate $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod
Validate $? "MongoDB Service ReStarted" 