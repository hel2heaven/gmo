Select SBWR.STATUS as businessStatus,SSWR.STARTED,SBWR.DESCRIPTION,
case
when sswr.STATUS = 1 then 'Ready'
when sswr.STATUS = 3 then 'Running'
when sswr.STATUS = 4 then 'Waiting'
when sswr.STATUS = 5 then 'Finished'
when sswr.STATUS = '-1' then 'Created'
when sswr.STATUS = 6 then 'Error'
when sswr.STATUS = 7 then 'Terminated'
when sswr.STATUS = 8 then 'Cancelled'
else 'No status' end as Scrubbing_Status
, SSWR.DESCRIPTION, SSWR.ERRORREASON
FROM S_BUSINESSWORKREQUEST SBWR
INNER JOIN S_SCRUBBINGPROCESSLINK SSPL
ON SBWR.ID = SSPL.FKBUSINESSPROCESSWORKREQUESTID
INNER JOIN S_SCRUBBINGWORKREQUEST SSWR
ON SSWR.ID = SSPL.SCRUBBINGPROCESSWORKREQUEST001
where SSWR.STATUS > 5
and trunc(sswr.started) >trunc(sysdate - 0.05/24)
and sswr.iscancellationrequested<>1;
exit
