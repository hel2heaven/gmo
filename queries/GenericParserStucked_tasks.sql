select count(sim.connector_name) as TaskCount, sim.connector_name
from T_TASK tt inner join T_GENERICFEEDERRORSTASK tgf on tt.id=tgf.id
inner join S_COMMUNICATIONWORKREQUEST cwr on tt.CREATEDBYWORKREQUESTID=cwr.ID
inner join S_IS_MESSAGE sim on sim.WORKREQUESTID=cwr.ID
where tt.status = 5 and tt.CREATIONDATE > (sysdate - 10/1440) group by sim.connector_name;
exit


