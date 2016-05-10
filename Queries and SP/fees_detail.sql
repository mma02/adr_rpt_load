select top 1000 * from tat_time



select top 1000 * from tat_time where billed_amt > 0 and bill_tran_uno is null

create table fees_detal (
fees_detail_id int identity(1,1),
bill_tran_uno int,
base_hrs money null,
tobill_hrs money null,
bill_date datetime null,
billed_amt decimal(25,10) null,
write_off_date datetime null,
write_off_amt decimal(25,10) null,
reciept_date datetime null,
reciept_amt decimal(25,10) null,
discount_level float null,

)

select b.bill_tran_uno, sum(base_hrs), sum(tobill_hrs), min(case when tran_type in ('BL') then b.tran_date else null end)
from tat_time t
left join BLT_BILL_AMT b on t.bill_tran_uno = b.bill_tran_uno 	
--where time_uno = 18300374
group by b.bill_tran_uno

select bill_tran_uno, count(*)
from tat_time 
group by bill_tran_uno
having count(*) > 1

select top 100 * from tat_time where bill_tran_uno = 2949116

select * from BLT_BILL_AMT where bill_tran_uno = 2949116



select top 10 * from blt_bill

select top 100000 * from BLT_BILL_AMT 
where bill_tran_uno = 7910242
order by tran_date desc