Select count(*) from S_IS_MESSAGE where created>=(sysdate-0.10/24) and MESSAGE_STATUS_ID='12';
exit
