#!/bin/bash
START_TIME=$(date +%s)
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

echo -e  "$R Script Executed at:$START_TIME $N" | tee -a $LOG_FILE # Tee command Display the content on Screen

if [ $USERID -ne 0 ] #Checks Whether UID is = 0 or not
then #!= 0 Enter into Loop
    echo -e "$R Error:Please proceed the Installation with sudo $N" | tee -a $LOG_FILE #Prints this messages on Screen
    exit 1 #!= 0 Don't Proceed with next command and Exit
else #If =0 Enter into else loop
    echo -e "$Y Please proceed the Installation $N" | tee -a $LOG_FILE #Prints this messages on Screen
fi #Condition Ends

echo "Please Enter Root Password to Setup:"
read -s MYSQL_ROOT_PWD

Validate (){ #Function Definition
    if [ $1 -eq 0 ] #Checks If Exit code equls to Zero, Yes
    then #Enter into Loop
        echo -e "$G $2...... is Successful $N"  | tee -a $LOG_FILE #Prints this messages on Screen
    else #Checks If Exit code != Zero, No
        echo -e " $R $2 ......is failed $N" | tee -a $LOG_FILE #Prints this messages on Screen
        exit 1 #Condition Exits and Entire Script Fails.
    fi #Condition Ends
}

dnf install maven -y &>>$LOG_FILE
Validate $? "Installing Maven and Java"

id roboshop
if [ $? -eq 0 ]
then
    echo "Roboshop user is already created...Skipping"
else 
    echo "Roboshop user is not created...Creating"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    Validate $? "Creating Roboshop user"
fi

mkdir  -p /app
Validate $? "Creating /app Dir"

curl -l -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
Validate $? "Downloading the Code"

rm -rf /app/*
cd /app &>>$LOG_FILE
unzip /tmp/shipping.zip &>>$LOG_FILE
Validate $? "Unzip the Code"

mvn clean package &>>$LOG_FILE
Validate $? "Cleaning and Installing Maveen"

mv target/shipping-1.0.jar shipping.jar
Validate $? "Moving Shipping Jar File"

cp $SCRIPT_DIR/Shipping.Service /etc/systemd/system/shipping.service &>>$LOG_FILE
Validate $? "Coping Shipping Service"

systemctl daemon-reload &>>$LOG_FILE
Validate $? "System Daemon Reload"

systemctl enable shipping  &>>$LOG_FILE
Validate $? "Enabling Shipping  Service"

systemctl start shipping  &>>$LOG_FILE
Validate $? "Starting Shipping  Service"

dnf install mysql -y &>>$LOG_FILE
Validate $? "Installing MYSQL Client"

mysql -h mysql.manchem.site -u root -p$MYSQL_ROOT_PWD -e 'use cities' &>>$LOG_FILE
if [ $? -eq 0 ]
then
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
else
    echo -e "Data is Not loaded into MySQL ... $Y Loading $N"
    mysql -h mysql.manchem.site -uroot -p$MYSQL_ROOT_PWD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.manchem.site -uroot -p$MYSQL_ROOT_PWD < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.manchem.site -uroot -p$MYSQL_ROOT_PWD < /app/db/master-data.sql &>>$LOG_FILE
fi
Validate $? "Loading data into MySQL"

systemctl restart shipping &>>$LOG_FILE
Validate $? "Restarting Shipping  Service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE