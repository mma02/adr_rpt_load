USE [BI_staging]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_aged_ar] '5/30/2016'

alter procedure [dbo].[BI_load_aged_ar] @runDate datetime
as


select fees_summary_id
, aged_fees_billed_30 = case when datediff(dd,@runDate, bill_date) <= 30 then fees_billed_amt else 0 end 
, aged_fees_billed_60 = case when datediff(dd,@runDate, bill_date) between 31 and 60 then fees_billed_amt else 0 end 
, aged_fees_billed_180 = case when datediff(dd,@runDate, bill_date) between 61 and 180 then fees_billed_amt else 0 end 
, aged_fees_billed_360 = case when datediff(dd,@runDate, bill_date) between 181 and 360 then fees_billed_amt else 0 end 
, aged_fees_billed_720 = case when datediff(dd,@runDate, bill_date) between 361 and 720 then fees_billed_amt else 0 end 
from adr_rpt..fees_summary 
where reciept_fees_amt is null

go


--select top 10 * from fees_summary where reciept_fees_amt is not null