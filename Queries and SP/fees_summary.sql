USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_fees_summary]

alter procedure [dbo].[BI_load_fees_summary]
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


select bg.billgrp_uno,b.bill_tran_uno, p.prebill_num,m.matter_number, bg.billgrp_code, sum(base_hrs), sum(tobill_hrs)
, min(case when tran_type in ('BL') then b.tran_date else null end)
, sum(case when tran_type in ('BL', 'BLX') then fees_amt*sign else null end)
, sum(case when tran_type in ('BL', 'BLX') then hard_amt*sign else null end)
, sum(case when tran_type in ('BL', 'BLX') then soft_amt*sign else null end)
, sum(case when tran_type in ('WO', 'WOX') then fees_amt*sign*-1 else null end)
, sum(case when tran_type in ('WO', 'WOX') then hard_amt*sign*-1 else null end)
, sum(case when tran_type in ('WO', 'WOX') then soft_amt*sign*-1 else null end)
, sum(case when tran_type in ('CR', 'CRX', 'RA', 'RAX') then fees_amt*sign*-1 else null end)
, sum(case when tran_type in ('CR', 'CRX', 'RA', 'RAX') then hard_amt*sign*-1 else null end)
, sum(case when tran_type in ('CR', 'CRX', 'RA', 'RAX') then soft_amt*sign*-1 else null end)
, isnull(md.pd_pcnt, cd.pd_pcnt), sum(base_amt), sum(std_amt)
from BLT_BILL_AMT b
left join (select bill_tran_uno, matter_uno,sum(base_hrs) base_hrs, sum(tobill_hrs) tobill_hrs, sum(base_amt) base_amt, sum(std_amt) std_amt
from tat_time_bil 
group by bill_tran_uno, matter_uno) t on t.bill_tran_uno = b.bill_tran_uno and t.bill_tran_uno = b.source_tran_uno and t.matter_uno = b.matter_uno	
join blt_bill p on p.tran_uno = b.bill_tran_uno 
join tbm_billgrp bg on p.billgrp_uno = bg.billgrp_uno
join hbm_matter m on b.matter_uno = m.matter_uno
join hbm_client c on m.client_uno = c.client_uno
left join _tbm_climat_pd md on m.matter_uno = md.matter_uno
left join _tbm_climat_pd cd on c.client_uno = cd.client_uno
where b.tran_date >= '1/1/2015' --and '2/2/2015'
and b.bill_tran_uno not in (select bill_tran_uno from @bill_trans_to_exclude)
group by b.bill_tran_uno, m.matter_number, isnull(md.pd_pcnt, cd.pd_pcnt), p.prebill_num, bg.billgrp_code, bg.billgrp_uno



go