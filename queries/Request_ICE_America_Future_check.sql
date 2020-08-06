Select sc.created,case
when sc.STATUS = 1 then 'Ready'
when sc.STATUS = 3 then 'Running'
when sc.STATUS = 4 then 'Waiting'
when sc.STATUS = 5 then 'Finished'
when sc.STATUS = '-1' then 'Error'
when sc.STATUS = 6 then 'Error'
when sc.STATUS = 7 then 'Terminated'
when sc.STATUS = 8 then 'Cancelled'
else 'No status' end as LastWaitingfor, sc.description,si.connector_name,si.externalmessageid, si.connector_name
from s_communicationworkrequest sc inner join s_is_message si on sc.id=si.workrequestid where sc.description ='America|Americas|A37075_America'
and trunc(sc.created) = trunc(sysdate) and sc.status=5;
exit
