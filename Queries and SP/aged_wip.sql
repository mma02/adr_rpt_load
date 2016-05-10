USE [BI_staging]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_aged_wip] '1/1/2015'

alter procedure [dbo].[BI_load_aged_wip] @runDate datetime
as


select time_uno
, aged31 = case when datediff(dd,@runDate, worked_date) <= 31 then 1 else 0 end 
, aged61 = case when datediff(dd,@runDate, worked_date) between 32 and 61 then 1 else 0 end 
, aged181 = case when datediff(dd,@runDate, worked_date) between 62 and 181 then 1 else 0 end 
, aged361 = case when datediff(dd,@runDate, worked_date) between 182 and 361 then 1 else 0 end 
, aged721 = case when datediff(dd,@runDate, worked_date) between 362 and 721 then 1 else 0 end 
from adr_rpt..time_detail 
where isnull(bil_tran_number, 0 ) < 1 and posted_date is not null

go


--select top 10 * from time_detail