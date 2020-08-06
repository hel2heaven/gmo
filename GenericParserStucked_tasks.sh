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
recipients_fail="prod-aim-support@simcorp.com"
#gainsupport@simcorp.com"
#recipients="prod-aim-support@simcorp.com"
#prod-aim-support@simcorp.com"
#chandan.k.gupta@simcorp.com,group_cloud@simcorp.com"
#prod-aim-support@simcorp.com"
query=/home/scripts/GMO_PROD/Business_Process/queries/GenericParserStucked_tasks.sql

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
logFile="GenericParserStucked_tasks.`date '+%d%b%g'`"
SQL_command_Action >/home/scripts/GMO_PROD/Business_Process/html_files/GenericParserStucked_tasks_temp.html 2>&1
sed '1d;2d;$d' /home/scripts/GMO_PROD/Business_Process/html_files/GenericParserStucked_tasks_temp.html > /home/scripts/GMO_PROD/Business_Process/html_files/GenericParserStucked_tasks.html
emailHTML=/home/scripts/GMO_PROD/Business_Process/html_files/GenericParserStucked_tasks.html


send_mail_alert()
{

  subject="[GMO PROD][Alert][GenericFeedParsingError Task raised]"
  Content-Type: text/html
  header="GenericFeedParsingError task has been raised, please check for the following feed:"
  Body=`cat $emailHTML`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients_fail
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

if [[ $(cat $emailHTML | wc -w) -gt 80 ]];
then
          send_mail_alert >> $LogPath/$logFile 2>&1
#else
#        echo '' | mailx -s "[GMO PROD][Alert][America|America|EQ sftp failed - Pls check]" -r gmo_prod_alert $recipients_fail
#< /home/scripts/GMO_PROD/Business_Process/Mail_Body/gmo_prod.txt
fi


