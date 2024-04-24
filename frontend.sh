#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter DB password:"
read  mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2...$R FAILURE $N"
    exit 1 # manually exit if error comes.
else
    echo -e "$2...$G SUCCESS $N"
     fi
}

if [ $USERID -ne 0 ]
then
   echo "please run this script with root access."
   exit 1 # manually exit if error comes.
else
     echo "you are super user."
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginix"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

#check your repo and path.&>>$LOGFILE
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf 
VALIDATE $? "Copiedexpense conf"


systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restrating nginx"
