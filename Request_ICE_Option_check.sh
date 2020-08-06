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
recipients_fail="gainsupport@simcorp.com"
recipients="prod-aim-support@simcorp.com"
#prod-aim-support@simcorp.com"
#chandan.k.gupta@simcorp.com,group_cloud@simcorp.com"
#prod-aim-support@simcorp.com"
#var1=$(echo "$0" | rev | cut -c4- | rev)
query=/home/scripts/GMO_PROD/Business_Process/queries/Request_ICE_Option_check.sql

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
logFile="Request_ICE_Option_check.`date '+%d%b%g'`"
SQL_command_Action >/home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Option_check_temp.html 2>&1
sed '1d;2d;$d' /home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Option_check_temp.html > /home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Option_check.html
emailHTML=/home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Option_check.html


send_mail_success()
{

  subject="[GMO PROD][SUCCESS][description_ICE_Option Req file sftp'ed successfully]"
  Content-Type: text/html
  Body=`cat $emailHTML`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients
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

if [[ $(cat $emailHTML | wc -w) -gt 86 ]];
then
          send_mail_success >> $LogPath/$logFile 2>&1
else
        echo '' | mailx -s "[GMO PROD][Alert][description_ICE_Option sftp failed - Pls check]" -r gmo_prod_alert $recipients_fail
#< /home/scripts/GMO_PROD/Business_Process/Mail_Body/gmo_prod.txt
fi


