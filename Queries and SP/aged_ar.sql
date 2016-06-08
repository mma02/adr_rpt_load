USE [BI_staging]
GO

/****** Object:  StoredProcedure [dbo].[BI_load_aged_ar]    Script Date: 6/8/2016 10:03:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--exec [BI_load_aged_ar] '5/30/2016'

ALTER procedure [dbo].[BI_load_aged_ar] @runDate datetime
as


select fees_summary_id
, aged_fees_billed_30 = case when datediff(dd,@runDate, bill_date) <= 30 then fees_billed_amt - isnull(reciept_fees_amt, 0)  else 0 end 
, aged_fees_billed_60 = case when datediff(dd,@runDate, bill_date) between 31 and 60 then fees_billed_amt - isnull(reciept_fees_amt, 0) else 0 end 
, aged_fees_billed_180 = case when datediff(dd,@runDate, bill_date) between 61 and 180 then fees_billed_amt - isnull(reciept_fees_amt, 0) else 0 end 
, aged_fees_billed_360 = case when datediff(dd,@runDate, bill_date) between 181 and 360 then fees_billed_amt - isnull(reciept_fees_amt, 0) else 0 end 
, aged_fees_billed_720 = case when datediff(dd,@runDate, bill_date) between 361 and 720 then fees_billed_amt - isnull(reciept_fees_amt, 0) else 0 end 
from fees_summary f
left join (select bill_tran_uno, sum(reciept_fees_amt) reciept_fees_amt from reciept_detail group by bill_tran_uno) r on f.bill_tran_uno = r.bill_tran_uno



GO


