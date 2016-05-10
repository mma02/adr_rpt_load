create table adr_custom..matter_rates (
matter_rate_id int identity(1,1),
matter_number int,
default_rate_level_id int,
default_rate_level varchar(80),
previous_rate_level_id int,
previous_rate_level varchar(80),
variable_rate_id int,
variable_rate varchar(80),
effective_variable_date datetime,
has_rateset_override int,
has_matter_override int)

SELECT 
TCR1.matter_uno, hm.matter_number, TCR1.rate_level, r.description, TCR1.eff_date
, id = row_number () over (partition by TCR1.MATTER_UNO, TCR1.eff_date order by TCR1.MATTER_UNO, TCR1.eff_date desc) 						
into #temp						
FROM TBM_CLMAT_RATEL TCR1 						
LEFT OUTER JOIN HBM_PERSNL HP3 ON (TCR1.EMPL_UNO=HP3.EMPL_UNO) 						
join TBL_LEVEL_FEE r ON TCR1.RATE_LEVEL=r.RATE_LEVEL											
join hbm_matter hm on tcr1.matter_uno = hm.matter_uno	
join hbm_persnl p on hm.bill_empl_uno = p.empl_uno
join hbl_office o on p.offc = o.offc_code	
join hbm_client c on hm.client_uno = c.client_uno				
WHERE TCR1.client_uno=0 						
AND TCR1.REC_TYPE='1'


create table #variable (
matter_uno int,
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
select distinct t1.matter_uno, 'multiple', 0, eff_date
from #temp t1	
join (select matter_uno, max(eff_date) as max_date from #temp group by matter_uno) t2 on t2.matter_uno = t1.matter_uno and t2.max_date = t1.eff_date
where t1.id	> 1

insert into #variable	
select t1.matter_uno, t1.description, t1.rate_level, eff_date
from #temp t1	
join (select matter_uno, max(eff_date) as max_date from #temp group by matter_uno) t2 on t2.matter_uno = t1.matter_uno and t2.max_date = t1.eff_date
where t1.matter_uno	not in (select matter_uno from #variable)

insert into adr_custom..matter_rates (
matter_number,
default_rate_level_id,
default_rate_level,
previous_rate_level_id,
previous_rate_level,
variable_rate_id,
variable_rate,
effective_variable_date,
has_rateset_override,
has_matter_override)
select m.matter_number, tm.rate_level, r.description, tm.prev_rate_level, pr.description, v.new_id, v.new_name, v.eff_date
, case when isnull(rs.rate_set_uno,0)>0 then 1 else 0 end
, case when isnull(mo.matter_uno,0)>0 then 1 else 0 end
from hbm_matter m 
join tbm_matter tm on tm.matter_uno=m.matter_uno
join TBL_LEVEL_FEE r on r.rate_level = tm.rate_level
join TBL_LEVEL_FEE pr on pr.rate_level = tm.rate_level
left join #variable v on v.matter_uno = m.matter_uno
left join TBL_MATT_RATESET mrs on mrs.matter_uno = m.matter_uno and getdate() between mrs.start_date and mrs.end_date  
left join (select distinct rate_set_uno from TBM_RATE_FEE) rs on rs.rate_set_uno = mrs.rateset_uno and rs.rate_set_uno > 0 
left join (select distinct matter_uno from TBM_RATE_FEE where getdate() between eff_date and end_date  ) mo 
	on mo.matter_uno = m.matter_uno and mo.matter_uno > 0 




	--drop table #variable