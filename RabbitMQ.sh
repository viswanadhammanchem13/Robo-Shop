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
read -s RABBITMQ_PWD

Validate (){ #Function Definition
    if [ $1 -eq 0 ] #Checks If Exit code equls to Zero, Yes
    then #Enter into Loop
        echo -e "$G $2...... is Successful $N"  | tee -a $LOG_FILE #Prints this messages on Screen
    else #Checks If Exit code != Zero, No
        echo -e " $R $2 ......is failed $N" | tee -a $LOG_FILE #Prints this messages on Screen
        exit 1 #Condition Exits and Entire Script Fails.
    fi #Condition Ends
}

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
Validate $? "Copying RabbitMQ Repo"

dnf install rabbitmq-server -y
# dnf install rabbitmq-server -y 2>&1 | tee -a $LOG_FILE
Validate $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
Validate $? "Enabling and Starting the RabbitMQ Service"

rabbitmqctl add_user roboshop $RABBITMQ_PWD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
Validate $? "Adding UN and PWD,Permissions Of the RabbitMQ"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE