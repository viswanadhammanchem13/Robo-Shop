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
SCRIPT_DIR=$PWD

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

dnf module disable nodejs -y
Validate $? "Disabeling NodeJS"

dnf module enable nodejs:20 -y
Validate $? "Enabling NodeJS:20"

dnf install nodejs -y
Validate $? "Installling NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
Validate $? "Creating Roboshop user"

mkdir /app
Validate $? "Creating /app Dir"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
Validate $? "Downloading the Code"

cd /app
Validate $? "Changing the Dir to /app"

unzip /tmp/catalogue.zip
Validate $? "Unzip the Code"

npm install
Validate $? "Dependencies installions"

cp $SCRIPT_DIR/Catalogue.Service /etc/systemd/system/catalogue.service
Validate $? "Coping Catalogue Service"

systemctl daemon-reload
Validate $? "System Daemon Reload"

systemctl enable catalogue
Validate $? "Enabling Catalogue Service" 
systemctl start catalogue
Validate $? "Starting Catalogue Service" 

