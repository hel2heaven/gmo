#!/bin/bash
cd /home/scripts/GMO_PROD/Business_Process
ORACLE_SID=ORCL; export ORACLE_SID
#export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export ORACLE_HOME=/usr/lib/oracle/12.2/client64
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_USER="GMO_PROD_01"
export ORACLE_PSWD="prodgmo"
export ORACLE_HOST="prod-gain-spoke-gmo-rds-db.cmzgrc2xhij0.us-east-1.rds.amazonaws.com"
#recipient_tckt="gainsupport@simcorp.com"
recipients="prod-aim-support@simcorp.com"
#recipients="chandan.k.gupta@simcorp.com"
#var1=$(echo "$0" | rev | cut -c4- | rev)
query=/home/scripts/GMO_PROD/Business_Process/queries/$1.sql
bp=$1
bold=$(tput bold)
normal=$(tput sgr0)


SQL_command_1()
{

        ScrubProcessTemp=`sqlplus -s -M "HTML ON TABLE 'BORDER="1"'" /nolog << EOF
	conn ${ORACLE_USER}/${ORACLE_PSWD}@${ORACLE_HOST}/${ORACLE_SID}
        WHENEVER SQLERROR exit SQL.SQLCODE;
        SET FEEDBACK OFF VERIFY OFF HEADING ON COLSEP","
        SET LINES 999
         @queries/scrub_1.sql

EOF`
        ScrubProcess=$(echo $ScrubProcessTemp | tail -1)
        echo $ScrubProcess
        if [[ -n ${ScrubProcess} ]]
        then
                echo -e "$(eval $dtCmd) scrub process_1 created"
        else
                echo -e "$(eval $dtCmd) no scrub process_1 created"
        fi

}



SQL_command_2()
{

        query_2Temp=`sqlplus -s -M "HTML ON TABLE 'BORDER="1"'" /nolog << EOF
        conn ${ORACLE_USER}/${ORACLE_PSWD}@${ORACLE_HOST}/${ORACLE_SID}
        WHENEVER SQLERROR exit SQL.SQLCODE;
        SET FEEDBACK OFF VERIFY OFF HEADING ON COLSEP","
        SET LINES 999
         @queries/scrub_2.sql

EOF`
        query_2=$(echo $query_2Temp |tail -1)
        echo $query_2
        if [[ -n ${query_2} ]]
        then
                echo -e "$(eval $dtCmd) scrub process_2 created"
        else
                echo -e "$(eval $dtCmd) no scrub process_2 created"
        fi
}



SQL_command_3()
{

        query_3Temp=`sqlplus -s -M "HTML ON TABLE 'BORDER="2"'" /nolog << EOF
        conn ${ORACLE_USER}/${ORACLE_PSWD}@${ORACLE_HOST}/${ORACLE_SID}
        WHENEVER SQLERROR exit SQL.SQLCODE;
        SET FEEDBACK OFF VERIFY OFF HEADING ON COLSEP","
        SET LINES 999
         @queries/scrub_3.sql
EOF`
        query_3=$(echo $query_3Temp |tail -1)
        echo $query_3
        if [[ -n ${query_3} ]]
        then
                echo -e "$(eval $dtCmd) scrub process_3 created"
        else
                echo -e "$(eval $dtCmd) no scrub process_3 created"
        fi
}





fullPath=$(readlink -f $0)
Path=$(dirname $fullPath)
LogPath=$Path/logs
emailHTML=$Path/html_files/email_scrub_process.html
dtCmd="date '+ %D %T'"
logFile="ScrubProcessCompletionStatus.`date '+%d%b%g'`"

SQL_command_1 > $Path/html_files/scrub_1.html 
SQL_command_2 > /home/scripts/GMO_PROD/Business_Process/html_files/scrub_2.html 2>&1
SQL_command_3 > /home/scripts/GMO_PROD/Business_Process/html_files/scrub_3.html 2>&1

send_mail()
{

  Subject="[GMO PROD][Critical-Scrubbing process not completed and in error state-Please check]"

  Body="Hi Team, below business/scrubbing processes are in error state in GAIN. Please  check the same and notify the customer in case it is a system error. This might impact the process completion as well"
  emailHTML_s=/home/scripts/GMO_PROD/Business_Process/html_files/scrub_$1.html
  Bodydb=`cat $emailHTML_s`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  #/usr/sbin/sendmail -f "elk_mon_alert@aimsoftware.com" -A depart.html -t<<EOM
  #mail -a html_files/scrub_$1'.html' -s "[GMO PROD][Critical-Scrubbing process not completed and in error state-Please check]" -r gmo_prod_alert $recipients <<EOM
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients
Subject : $Subject
Content-Type: text/html
${Body}
${Bodydb}
${Auto_Generate_Msg}
EOM
}


send_mail_all()
{

  Subject="[GMO PROD][Critical-Scrubbing process not completed and in error state-Please check]"
  Body="Hi Team, below business/scrubbing processes are in error state in GAIN. Please  check the same and notify the customer in case it is a system error. This might impact the process completion as well"
  bodydb1=`cat $emailHTML_$1`
  emailHTML_1=/home/scripts/GMO_PROD/Business_Process/html_files/scrub_$1.html
  emailHTML_2=/home/scripts/GMO_PROD/Business_Process/html_files/scrub_$2.html
  emailHTML_3=/home/scripts/GMO_PROD/Business_Process/html_files/scrub_$3.html
  Bodydb1=`cat $emailHTML_1`
  Bodydb2=`cat $emailHTML_2`
  Bodydb3=`cat $emailHTML_3`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  #mail -a html_files/scrub_$1'.html' -a html_files/scrub_$2'.html' -a html_files/scrub_$3'.html' -s "[GMO PROD][Critical-Scrubbing process not completed and in error state-Please check]" -r gmo_prod_alert $recipients <<EOM
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients
Subject : $Subject
Content-Type: text/html
${Body}
${Bodydb1}
${Bodydb2}
${Bodydb3}
${Auto_Generate_Msg}
EOM
}


send_mail_two()
{

  Subject="[GMO PROD][Critical-Scrubbing process not completed and in error state-Please check]"

  Body="Hi Team, below business/scrubbing processes are in error state in GAIN. Please  check the same and notify the customer in case it is a system error. This might impact the process completion as well"
  emailHTML_1=/home/scripts/GMO_PROD/Business_Process/html_files/scrub_$1.html
  emailHTML_2=/home/scripts/GMO_PROD/Business_Process/html_files/scrub_$2.html 
  Bodydb1=`cat $emailHTML_1`
  Bodydb2=`cat $emailHTML_2`
  Auto_Generate_Msg="**********This email is an auto-generated mail. Please do not reply**********"
  #/usr/sbin/sendmail -f "elk_mon_alert@aimsoftware.com" -A depart.html -t<<EOM
  #mail -a html_files/scrub_$1'.html' -a html_files/scrub_$2'.html' -s "[GMO PROD][Critical-Scrubbing process not completed and in error state-Please check]" -r gmo_prod_alert $recipients <<EOM
  /usr/sbin/sendmail -f gmo_prod_alert -t<<EOM
To: $recipients
Subject : $Subject
Content-Type: text/html
${Body}
${Bodydb1}
${Bodydb2}
${Auto_Generate_Msg}
EOM
}



if [[ $(cat html_files/scrub_1.html | wc -w) -gt 86 ]] && [[ $(cat html_files/scrub_2.html | wc -w) -gt 86 ]] && [[ $(cat html_files/scrub_3.html | wc -w) -gt 86 ]]; then
 send_mail_all 1 2 3 >> $LogPath/$logFile 2>&1
elif [[ $(cat html_files/scrub_1.html | wc -w) -gt 86 ]] && [[ $(cat html_files/scrub_2.html | wc -w) -gt 86 ]];then
 send_mail_two 1 2 >> $LogPath/$logFile 2>&1
elif [[ $(cat html_files/scrub_1.html | wc -w) -gt 86 ]] && [[ $(cat html_files/scrub_3.html | wc -w) -gt 86 ]];then
 send_mail_two 1 3 >> $LogPath/$logFile 2>&1
elif [[ $(cat html_files/scrub_2.html | wc -w) -gt 86 ]] && [[ $(cat html_files/scrub_3.html | wc -w) -gt 86 ]];then
 send_mail_two 2 3 >> $LogPath/$logFile 2>&1

elif [[ $(cat html_files/scrub_1.html | wc -w) -gt 86 ]]; then
 send_mail 1 >> $LogPath/$logFile 2>&1
elif [[ $(cat html_files/scrub_2.html | wc -w) -gt 86 ]]; then
 send_mail 2 >> $LogPath/$logFile 2>&1
elif [[ $(cat html_files/scrub_3.html | wc -w) -gt 86 ]]; then
 send_mail 3 >> $LogPath/$logFile 2>&1
fi

