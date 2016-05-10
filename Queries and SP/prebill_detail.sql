USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[BI_load_prebill_detail]
as


select b.prebill_num, bg.billgrp_code,m.matter_number, b.bill_date, b._PBILL_STATUS_DATE, b._PBILL_STATUS_NOTES, bm.fees_bil, p.employee_name, p.employee_code
from blt_bill b
join tbm_billgrp bg on b.billgrp_uno = bg.billgrp_uno
join hbm_persnl p on p.empl_uno = bg.pb_billing_coord_uno
join blt_billm bm on bm.bill_tran_uno = b.tran_uno --and m.final = 'Y'
join hbm_matter m on m.matter_uno = bm.matter_uno
where b.bill_num = 0


 go