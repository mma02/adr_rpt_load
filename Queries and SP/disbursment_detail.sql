USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_disbursments_billed_detail]

create procedure [dbo].[BI_load_disbursments_billed_detail]
as


select m.matter_number, d.bill_tran_uno, d.tran_date, d.period, d.billed_amt, d.hardsoft, d.cost_code, dl.cost_desc
from cdt_disb d
join hbm_matter m on m.matter_uno = d.matter_uno
join cdl_cost dl on dl.cost_code = d.cost_code
where d.tran_date >= '1/1/2015'

go