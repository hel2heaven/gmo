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
recipient_tckt="gainsupport@simcorp.com"
recipients="chandan.k.gupta@simcorp.com,prod-aim-support@simcorp.com"
#var1=$(echo "$0" | rev | cut -c4- | rev)
query=/home/scripts/GMO_PROD/Business_Process/queries/Request_ICE_Europe_Future_check.sql
bp=$1
bold=$(tput bold)
normal=$(tput sgr0)

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
logFile="Request_ICE_Europe_Future_check.`date '+%d%b%g'`"
SQL_command_Action >/home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Europe_Future_check.sh_temp.html 2>&1
sed '1d;2d;$d' /home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Europe_Future_check.sh_temp.html > /home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Europe_Future_check.sh.html
emailHTML=/home/scripts/GMO_PROD/Business_Process/html_files/Request_ICE_Europe_Future_check.sh.html


send_mail_success()
{

  subject="[GMO PROD][SUCCESS][Europe|Europe|B37075_Europe Req file sftp'ed successfully]"
  Content-Type: text/html
#  Header="Please find below the Bloomberg EoD Business Process. Please check task scheduler GMO BBBO Issuer EOD. If the scheduler is completed successfully then check in the DB whether the process is kicked off or not. If the process is kicked off then wait for 5-10 minutes to show on browser and check whether any big processing is running at the moment in GAIN. If the process does not show in DB after 15 min then check the logs for any errors and with L2 if the task scheduler can be rerun again or not."
  Body=`cat $emailHTML`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients
Subject : $subject
Content-Type: text/html
${Header}
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
        echo '' | mailx -s "[GMO PROD][Alert][Europe|Europe|B37075_Europe sftp failed - Pls check]" -r gmo_prod_alert $recipient_tckt
#< /home/scripts/GMO_PROD/Business_Process/Mail_Body/gmo_prod.txt
fi


