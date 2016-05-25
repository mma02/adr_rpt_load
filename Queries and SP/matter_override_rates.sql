USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_client_details]

create procedure [dbo].[BI_load_matter_override_rates]
as


select m.matter_number,  p.employee_name, p.employee_code, null, null, rs.rate_set_code, rs.rate_set_desc
,  tmr1.START_DATE, CONVERT (char(8),tmr1.START_DATE,112)
, tmr1.END_DATE, CONVERT (char(8),tmr1.END_DATE,112)
, f.eff_date, CONVERT (char(8),f.eff_date,112)
, f.end_date, CONVERT (char(8),f.end_date,112)
, f.rate
--select count(*)
FROM TBM_RATE_FEE f
JOIN TBL_MATT_RATESET TMR1 ON f.RATE_SET_UNO=TMR1.RATESET_UNO AND GETDATE() BETWEEN tmr1.START_DATE AND tmr1.END_DATE
join TBL_RATE_SET rs on TMR1.rateset_uno= rs.rate_set_uno and rs.inactive='N'
JOIN dbo.HBM_MATTER m ON tmr1.MATTER_UNO=m.MATTER_UNO 
join hbm_persnl p on f.empl_uno=p.empl_uno

union

--select count(*)
select m.matter_number,  null, null,r.rank_desc, f.rank_code, rs.rate_set_code, rs.rate_set_desc
,  tmr1.START_DATE, CONVERT (char(8),tmr1.START_DATE,112)
, tmr1.END_DATE, CONVERT (char(8),tmr1.END_DATE,112)
, f.eff_date, CONVERT (char(8),f.eff_date,112)
, f.end_date, CONVERT (char(8),f.end_date,112)
, f.rate
FROM TBM_RATE_FEE f
JOIN TBL_MATT_RATESET TMR1 ON f.RATE_SET_UNO=TMR1.RATESET_UNO AND GETDATE() BETWEEN tmr1.START_DATE AND tmr1.END_DATE
join TBL_RATE_SET rs on TMR1.rateset_uno= rs.rate_set_uno and rs.inactive='N'
JOIN dbo.HBM_MATTER m ON tmr1.MATTER_UNO=m.MATTER_UNO 
join TBL_RANK r on f.rank_code = r.rank_code

union

select m.matter_number,  p.employee_name, p.employee_code, null, null, null, null,  null, null, null, null
, f.eff_date, CONVERT (char(8),f.eff_date,112)
, f.end_date, CONVERT (char(8),f.end_date,112)
, f.rate
--select count(*)
from TBM_RATE_FEE f
JOIN dbo.HBM_MATTER m ON f.MATTER_UNO=m.MATTER_UNO
join hbm_persnl p on f.empl_uno=p.empl_uno
where f.GROUP_TYPE = 1 AND GETDATE() BETWEEN  f.EFF_DATE AND f.END_DATE 

union

select m.matter_number,  null, null,r.rank_desc, f.rank_code, null, null,  null, null, null, null
, f.eff_date, CONVERT (char(8),f.eff_date,112)
, f.end_date, CONVERT (char(8),f.end_date,112)
, f.rate
--select count(*)
from TBM_RATE_FEE f
JOIN dbo.HBM_MATTER m ON f.MATTER_UNO=m.MATTER_UNO
join TBL_RANK r on f.rank_code = r.rank_code
where f.GROUP_TYPE = 1 AND GETDATE() BETWEEN  f.EFF_DATE AND f.END_DATE 


go