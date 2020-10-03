select Email,BonusEligibility,WeekFilter into #PreviousWeek from (
select  *, ROW_NUMBER () 
OVER(PARTITION BY [Email] ORDER BY CONVERT(DATE,SUBSTRING(WeekFilter,0,CHARINDEX('-', WeekFilter))) DESC,ID DESC) AS ROWNUMBER 
from remotestoreoperations.bonus where WeekFilter = '04/27/2020-05/03/2020')A
WHERE ROWNUMBER = 1


select Email,BonusEligibility,WeekFilter into #currentweek from RemoteStoreOperations.bonus 
where WeekFilter = '05/04/2020-05/10/2020' AND CreatedBy = 'System Generated'


select * from #currentweek A
join #PreviousWeek B 
on A.Email = B.Email
AND A.BonusEligibility<>B.BonusEligibility

miwaheeb@microsoft.com
miwilli@microsoft.com
arjohnso@microsoft.com

select * from RemoteStoreOperations.Bonus where email = 'arjohnso@microsoft.com' ORDER BY CONVERT(DATE,SUBSTRING(WeekFilter,0,CHARINDEX('-', WeekFilter))) DESC

