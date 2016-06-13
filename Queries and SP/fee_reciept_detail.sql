USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_fee_reciept_detail]

alter procedure [dbo].[BI_load_fee_reciept_detail]
as


--when we creat the ssis package we will need to delete records
declare @bill_trans_to_exclude table (bill_tran_uno int)
insert into @bill_trans_to_exclude
select b.bill_tran_uno
from BLT_BILL_AMT b
join
(
select bill_tran_uno, max(tran_date) as tran_date
from BLT_BILL_AMT
where tran_type in ('BL', 'BLX')
group by bill_tran_uno) u1 on u1.bill_tran_uno = b.bill_tran_uno and u1.tran_date = b.tran_date
where b.tran_type = 'BLX'


select b.bill_tran_uno, m.matter_number, b.source_tran_uno, b.tran_date, CONVERT (char(8),b.tran_date,112)
, sum(b.fees_amt*sign*-1)
, sum(b.hard_amt*sign*-1)
, sum(b.soft_amt*sign*-1)
, b.tran_type
from BLT_BILL_AMT b
join hbm_matter m on m.matter_uno = b.matter_uno
where b.tran_type in ('CR', 'CRX', 'RA', 'RAX')
and b.tran_date >= '1/1/2015' --and '2/2/2015'
group by b.bill_tran_uno, m.matter_number, b.source_tran_uno, b.tran_date, b.tran_type

go