USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_time_detail]

create procedure [dbo].[BI_load_time_detail]
as


select t.time_uno, m.matter_number, t.bill_tran_uno, t.tran_date, tran_month = month(t.tran_date)
, t.base_hrs, t.tobill_hrs, p.employee_name, p.employee_code, t.post_date, post_month = month(t.post_date), t.wip_status
,t.base_amt, t.std_amt
from tat_time t 
join hbm_matter m on m.matter_uno = t.matter_uno
join hbm_persnl p on p.empl_uno = t.tk_empl_uno 
where t.tran_date >= '1/1/2015'




go