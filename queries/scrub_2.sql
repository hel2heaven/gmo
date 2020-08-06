Select case
when STATUS = 1 then 'Ready'
when STATUS = 3 then 'Running'
when STATUS = 4 then 'Waiting'
when STATUS = 5 then 'Finished'
when STATUS = '-1' then 'Created'
when STATUS = 6 then 'Error'
when STATUS = 7 then 'Terminated'
when STATUS = 8 then 'Cancelled'
else 'No status' end as Business_Status
,started,DESCRIPTION,ERRORREASON from S_BUSINESSWORKREQUEST where STATUS > 5
and started > (sysdate - 0.05/24)
and iscancellationrequested<>1;
exit
