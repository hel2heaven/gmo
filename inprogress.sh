#!/bin/bash

cd /home/scripts/GMO_PROD/Business_Process
ORACLE_SID=ORCL; export ORACLE_SID
export ORACLE_HOME=/usr/lib/oracle/12.2/client64
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_USER="GMO_PROD_01"
export ORACLE_PSWD="prodgmo"
export ORACLE_HOST="prod-gain-spoke-gmo-rds-db.cmzgrc2xhij0.us-east-1.rds.amazonaws.com"
#recipient_tckt="gainsupport@simcorp.com"
#recipients="prod-aim-support@simcorp.com"
destination="chandan.k.gupta@simcorp.com"

set -x

SQL_command_1()
{

        publish_count=`sqlplus -s /nolog << EOF
	conn ${ORACLE_USER}/${ORACLE_PSWD}@${ORACLE_HOST}/${ORACLE_SID}
        WHENEVER SQLERROR exit SQL.SQLCODE;
        SET FEEDBACK OFF VERIFY OFF HEADING OFF COLSEP","
        SET LINES 999
	Select count(*) from S_IS_MESSAGE where created>=(sysdate-0.10/24) and MESSAGE_STATUS_ID='12';
	exit
EOF`

	totalcount=$(echo $publish_count | tail -1)
        echo $totalcount
        if [[ -n ${totalcount} ]]
        then
                echo -e "$(eval $dtCmd) scrub process_1 created"
        else
                echo -e "$(eval $dtCmd) no scrub process_1 created"
        fi
}



fullPath=$(readlink -f $0)
Path=$(dirname $fullPath)
LogPath=$Path/logs
emailHTML=$Path/html_files/email_scrub_process.html
dtCmd="date '+ %D %T'"
logFile="publication_status.`date '+%d%b%g'`"

SQL_command_1 > $Path/html_files/publication_status.html 2>&1


send_mail_alert()
{

  subject="[GMO PROD][Critical Alert][Publication message status is Not Ok, Pls Investigate]"
  Content-Type: text/html
  Body="Total number of schedules triggered="${totalcount}
  emailHTML_s=/home/scripts/GMO_PROD/Business_Process/html_files/publication_status.html
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $destination
Subject : $subject
Content-Type: text/html
${Body}
${Auto_Generate_Msg}
EOM

if [ $? -eq 0 ]
then
        echo -e "$(eval $dtCmd) mail sent successfully"
fi
}



#if [[ $(cat /home/scripts/GMO_PROD/Business_Process/html_files/publication_status.html | wc -w) -gt 86 ]]; then
#          send_mail >> $LogPath/$logFile 2>&1
#fi

echo $totalcount
if [[ ${totalcount} -gt 0 ]];
then
	sleep 1
        send_mail_alert  >> $LogPath/$logFile 2>&1
fi
