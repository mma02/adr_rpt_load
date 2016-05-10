USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_client_details]

create procedure [dbo].[BI_load_client_details]
as

create table #stact_addresses (
row_ int null,
state_code varchar(8) null,
address1 varchar(60) null,
_pobox varchar(40) null,
city varchar(60) null,
post_code varchar(10) null,
country_code varchar(5) null,
name_uno int null)
insert into #stact_addresses
exec [_ven_getSTACTAddresses] 


SELECT 
TCR1.matter_uno, c.client_uno, TCR1.rate_level, r.description, TCR1.eff_date
, id = row_number () over (partition by TCR1.client_uno, TCR1.eff_date order by TCR1.client_uno, TCR1.eff_date desc) 						
into #var_row						
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

insert into #variable	
select distinct t1.client_uno, 'multiple', 0, eff_date
from #var_row t1	
join (select client_uno, max(eff_date) as max_date from #var_row group by client_uno) t2 on t2.client_uno = t1.client_uno and t2.max_date = t1.eff_date
where t1.id	> 1

insert into #variable	
select t1.client_uno, t1.description, t1.rate_level, eff_date
from #var_row t1	
join (select client_uno, max(eff_date) as max_date from #var_row group by client_uno) t2 on t2.client_uno = t1.client_uno and t2.max_date = t1.eff_date
where t1.client_uno	not in (select matter_uno from #variable)

select c.client_code,c.client_name, n.name, ba.employee_name, ba.employee_code, oa.employee_name, oa.employee_code 
, a.address1, a.state_code, a.country_code, a.city, a.post_code, a._pobox
, tm.rate_level, r.description, tm.prev_rate_level, pr.description, v.new_id, v.new_name, v.eff_date
, case when isnull(co.client_uno,0)>0 then 1 else 0 end
--, gc.group_code, gc.description
--, r1.employee_code, r1.employee_name, r2.employee_code, r2.employee_name, r3.employee_code, r3.employee_name
from hbm_client c
left join hbm_name n on n.name_uno = c.name_uno
LEFT JOIN #stact_addresses a on a.NAME_UNO=n.NAME_UNO 
join hbm_persnl ba on ba.empl_uno = c.bill_empl_uno
join hbm_persnl oa on oa.empl_uno = c.assign_empl_uno
join tbm_client tm on tm.client_uno=c.client_uno
join TBL_LEVEL_FEE r on r.rate_level = tm.rate_level
join TBL_LEVEL_FEE pr on pr.rate_level = tm.rate_level
left join #variable v on v.client_uno = c.client_uno
left join (select distinct client_uno from TBM_RATE_FEE where getdate() between eff_date and end_date  ) co 
	on co.client_uno = c.client_uno and co.client_uno > 0
--left join _hba_group_code gca on gca.client_uno = c.client_uno
--left join _group_code gc on gc.group_uno = gca.group_uno
--left join hbm_persnl r1 on r1.empl_uno = gc.relation_empl_uno1
--left join hbm_persnl r2 on r2.empl_uno = gc.relation_empl_uno2
--left join hbm_persnl r3 on r3.empl_uno = gc.relation_empl_uno3


go