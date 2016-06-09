USE [ADR_TRAIN]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_matter_details]
--WITH RESULT SETS   
--(
--  (
--	client_code char(10) null,
--	matter_number int null,
--	matter_short_name varchar(40),
--	matter_name varchar(250) null,
--	matter_billing_atty_name varchar(40) null,
--	matter_billing_atty_code char(6) null,
--	matter_resp_atty_name varchar(40) null,
--	matter_resp_atty_code char(6) null,
--	billing_coordinator_name varchar(40) null,
--	billing_coordinator_code char(6) null,
--	external_ebilling_number varchar(50) null,
--	open_date datetime null,
--	close_date datetime null,
--	status_desc varchar(80) null,
--	default_rate_level_id int,
--	default_rate_level varchar(80),
--	previous_rate_level_id int,
--	previous_rate_level varchar(80),
--	variable_rate_id int,
--	variable_rate varchar(80),
--	effective_variable_date datetime,
--	has_rateset_override int,
--	has_matter_override int
--  )
--);


alter procedure [dbo].[BI_load_matter_details]
as


set nocount on;


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


select c.client_code, m.matter_number, m.matter_name, m.long_matt_name, ba.employee_name, ba.employee_code, ra.employee_name, ra.employee_code 
, bc.employee_name, bc.employee_code, tm._ebill_internal_matter_no
, case when tm._EBILL_CLIENT_ID = '' then null else tm._EBILL_CLIENT_ID end
, case when tm._EBILLING_INVOICE_DESC = '' then null else tm._EBILLING_INVOICE_DESC end
, case when tm._EBILL_PROVIDER = '' then null else tm._EBILL_PROVIDER end
, m.open_date
, CONVERT (char(8),m.open_date,112)
, m.close_date
, isnull(CONVERT (char(8),m.close_date,112), 1)
, s.status_desc
, tm.rate_level, r.description, tm.prev_rate_level, pr.description, v.new_id, v.new_name, v.eff_date
, has_rateset_override = case when isnull(rs.rate_set_uno,0)>0 then 1 else 0 end 
, has_matter_override = case when isnull(mo.matter_uno,0)>0 then 1 else 0 end
from hbm_matter m
join hbm_client c on c.client_uno = m.client_uno
join hbm_persnl ba on ba.empl_uno = m.bill_empl_uno
join hbm_persnl ra on ra.empl_uno = m.resp_empl_uno
join tbm_persnl bct on bct.empl_uno = m.bill_empl_uno
join hbm_persnl bc on bc.empl_uno = bct.assist_empl_uno
join tbm_matter tm on m.matter_uno = tm.matter_uno
join HBL_STATUS_MATT s on s.status_code = m.status_code
join TBL_LEVEL_FEE r on r.rate_level = tm.rate_level
join TBL_LEVEL_FEE pr on pr.rate_level = tm.rate_level
left join #variable v on v.matter_uno = m.matter_uno
left join (select *, id = row_number () over (partition by MATTER_UNO order by MATTER_UNO, start_date desc) 
from tbl_matt_rateset 
where getdate() between start_date and end_date) mrs on mrs.matter_uno = m.matter_uno and getdate() between mrs.start_date and mrs.end_date and mrs.id = 1 
left join (select distinct rate_set_uno from TBM_RATE_FEE) rs on rs.rate_set_uno = mrs.rateset_uno and rs.rate_set_uno > 0 
left join (select distinct matter_uno from TBM_RATE_FEE where getdate() between eff_date and end_date  ) mo 
	on mo.matter_uno = m.matter_uno and mo.matter_uno > 0 

drop table #temp
drop table #variable

GO

--declare @startDate datetime = null
--declare @EndDate datetime = null
--declare @empl int = null
--declare @client_code char(10) = null
--declare @matter_number int = 207816
--declare @empl_assistant varchar(6) = null




