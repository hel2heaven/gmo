select description, status, min(started) as Start_Time, max(finished) as End_Time,
case
when STATUS = 1 then 'Ready'
when STATUS = 3 then 'Running'
when STATUS = 4 then 'Waiting'
when STATUS = 5 then 'Finished'
when STATUS = '-1' then 'Error'
when STATUS = 6 then 'Error'
when STATUS = 7 then 'Terminated'
when STATUS = 8 then 'Cancelled'
else 'No status' end as LastWaitingfor from S_BUSINESSWORKREQUEST where description like '%GMO_ASIA_PP_GMO_ASIA_EQUITY_LONG%' and trunc(created)=trunc(sysdate)
group by description, status, lastwaitingfor, trunc(started),trunc(finished);
exit


