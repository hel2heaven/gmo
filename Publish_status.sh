#!/bin/sh
cd /home/scripts/GMO_PROD/Business_Process
ORACLE_SID=ORCL; export ORACLE_SID
#export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export ORACLE_HOME=/usr/lib/oracle/12.2/client64
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_USER="GMO_PROD_01"
export ORACLE_PSWD="prodgmo"
export ORACLE_HOST="prod-gain-spoke-gmo-rds-db.cmzgrc2xhij0.us-east-1.rds.amazonaws.com"
recipients="gainsupport@simcorp.com"
#recipients="chandan.k.gupta@simcorp.com"
#prod-aim-support@simcorp.com"
#chandan.k.gupta@simcorp.com,group_cloud@simcorp.com"
#prod-aim-support@simcorp.com"
query=/home/scripts/GMO_PROD/Business_Process/queries/publication_status.sql

set -x


SQL_command_Action()
{

        BatchExportEODTemp=`sqlplus -s -M "HTML ON TABLE 'BORDER="1"'" /nolog << EOF
	conn ${ORACLE_USER}/${ORACLE_PSWD}@${ORACLE_HOST}/${ORACLE_SID}
        WHENEVER SQLERROR exit SQL.SQLCODE;
        SET FEEDBACK OFF VERIFY OFF HEADING ON COLSEP","
        SET LINES 999
         @$query
EOF`

}


fullPath=$(readlink -f $0)
Path=$(dirname $fullPath)
LogPath=$Path/logs
dtCmd="date '+ %D %T'"
logFile="publication_status.`date '+%d%b%g'`"
SQL_command_Action >/home/scripts/GMO_PROD/Business_Process/html_files/publication_status_temp.html 2>&1
sed '1d;2d;$d' /home/scripts/GMO_PROD/Business_Process/html_files/publication_status_temp.html > /home/scripts/GMO_PROD/Business_Process/html_files/publication_status.html
emailHTML=/home/scripts/GMO_PROD/Business_Process/html_files/publication_status.html


send_mail_alert()
{

  subject="[GMO Prod][Critical Alert][Publication message status is Not Ok, Pls Investigate]"
  Content-Type: text/html
  header="The following messages were not published successfully as the status is Not OK. Please investigate further and send email to Datacare team about the same."
  Body=`cat $emailHTML`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients
Subject : $subject
Content-Type: text/html
${header}
${Body}
${Auto_Generate_Msg}
EOM
if [ $? -eq 0 ]
then
        echo -e "$(eval $dtCmd) mail sent successfully"
fi
}


totalcount=$(cat $emailHTML | tail -6 | head -1)
if [[ $totalcount -gt 0 ]];
then
          send_mail_alert >> $LogPath/$logFile 2>&1
fi


