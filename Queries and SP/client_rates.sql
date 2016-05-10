--create table adr_custom..client_rates (
--client_rate_id int identity(1,1),
--client_code char(10) null,
--default_rate_level_id int,
--default_rate_level varchar(80),
--previous_rate_level_id int,
--previous_rate_level varchar(80),
--variable_rate_id int,
--variable_rate varchar(80),
--effective_variable_date datetime,
--has_client_override int)

SELECT 
TCR1.matter_uno, c.client_uno, TCR1.rate_level, r.description, TCR1.eff_date
, id = row_number () over (partition by TCR1.client_uno, TCR1.eff_date order by TCR1.client_uno, TCR1.eff_date desc) 						
into #temp						
FROM TBM_CLMAT_RATEL TCR1 						
LEFT OUTER JOIN HBM_PERSNL HP3 ON (TCR1.EMPL_UNO=HP3.EMPL_UNO) 						
join TBL_LEVEL_FEE r ON TCR1.RATE_LEVEL=r.RATE_LEVEL											
--join hbm_matter hm on tcr1.matter_uno = hm.matter_uno	
join hbm_client c on TCR1.client_uno = c.client_uno		
join hbm_persnl p on c.bill_empl_uno = p.empl_uno
join hbl_office o on p.offc = o.offc_code			
WHERE TCR1.client_uno=0 						
AND TCR1.REC_TYPE='1'


create table #variable (
client_uno int,
new_name varchar(80),
new_id int,
eff_date datetime)

--insert into #variable
--select t1.*, case when t1.rate_level != t2.rate_level then 'multiple' else t1.description end as new_name		
--, case when t1.rate_level != t2.rate_level then 0 else t1.rate_level end as new_rate				
--from #temp t1 						
--join #temp t2 on t1.matter_uno=t2.matter_uno and t1.id=t2.id - 1 and t1.eff_date=t2.eff_date						
--where t1. matter_uno != 0  		

insert into #variable	
select distinct t1.client_uno, 'multiple', 0, eff_date
from #temp t1	
join (select client_uno, max(eff_date) as max_date from #temp group by client_uno) t2 on t2.client_uno = t1.client_uno and t2.max_date = t1.eff_date
where t1.id	> 1

insert into #variable	
select t1.client_uno, t1.description, t1.rate_level, eff_date
from #temp t1	
join (select client_uno, max(eff_date) as max_date from #temp group by client_uno) t2 on t2.client_uno = t1.client_uno and t2.max_date = t1.eff_date
where t1.client_uno	not in (select matter_uno from #variable)

insert into adr_custom..client_rates (
client_code,
default_rate_level_id,
default_rate_level,
previous_rate_level_id,
previous_rate_level,
variable_rate_id,
variable_rate,
effective_variable_date,
has_client_override)
select c.client_code, tm.rate_level, r.description, tm.prev_rate_level, pr.description, v.new_id, v.new_name, v.eff_date
, case when isnull(co.client_uno,0)>0 then 1 else 0 end
from hbm_client c 
join tbm_client tm on tm.client_uno=c.client_uno
join TBL_LEVEL_FEE r on r.rate_level = tm.rate_level
join TBL_LEVEL_FEE pr on pr.rate_level = tm.rate_level
left join #variable v on v.client_uno = c.client_uno
left join (select distinct client_uno from TBM_RATE_FEE where getdate() between eff_date and end_date  ) co 
	on co.client_uno = c.client_uno and co.client_uno > 0 




	--drop table #variable