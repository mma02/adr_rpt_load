USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_matter_config_error_flags]

create procedure [dbo].[BI_load_matter_config_error_flags]
as

begin

--matter temp table for 2 variable fee rates
select distinct matter_uno						
into #matter						
from						
(						
SELECT TCR1.matter_uno, TCR1.rate_level, r.description, TCR1.eff_date, row_number () over (partition by TCR1.MATTER_UNO, TCR1.eff_date order by TCR1.MATTER_UNO, TCR1.eff_date desc) id						
FROM TBM_CLMAT_RATEL TCR1 						
LEFT OUTER JOIN HBM_PERSNL HP3 ON (TCR1.EMPL_UNO=HP3.EMPL_UNO) 						
join TBL_LEVEL_FEE r ON TCR1.RATE_LEVEL=r.RATE_LEVEL						
WHERE TCR1.client_uno=0 						
AND TCR1.REC_TYPE='1'						
) u1 						
where id = 2	

--temp table for 2 variable fee rates
SELECT c.client_code, c.client_name, billing_att = p.employee_name, o.offc_desc,
TCR1.matter_uno, hm.matter_number, TCR1.rate_level, r.description, TCR1.eff_date
, id = row_number () over (partition by TCR1.MATTER_UNO, TCR1.eff_date order by TCR1.MATTER_UNO, TCR1.eff_date desc) 						
into #temp						
FROM TBM_CLMAT_RATEL TCR1 						
LEFT OUTER JOIN HBM_PERSNL HP3 ON (TCR1.EMPL_UNO=HP3.EMPL_UNO) 						
join TBL_LEVEL_FEE r ON TCR1.RATE_LEVEL=r.RATE_LEVEL						
join #matter m on tcr1.matter_uno = m.matter_uno						
join hbm_matter hm on m.matter_uno = hm.matter_uno	
join hbm_persnl p on hm.bill_empl_uno = p.empl_uno
join hbl_office o on p.offc = o.offc_code	
join hbm_client c on hm.client_uno = c.client_uno				
WHERE TCR1.client_uno=0 						
AND TCR1.REC_TYPE='1'
and hm.inactive = 'N'		

--assigned rateset code and client code mismatch

select matter_code, sum(rateset_client_code_mismatch) rateset_client_code_mismatch, sum(_2varFees) _2varFees, sum(_2varFeesDiffRates) _2varFeesDiffRates
, sum(var_std_mismatch) var_std_mismatch, sum(matter_rateset_overrides) matter_rateset_overrides, sum(inactive_ratesets_to_matter) inactive_ratesets_to_matter
from
(
SELECT m.MATTER_code, 1 as rateset_client_code_mismatch, 0 as _2varFees, 0 as _2varFeesDiffRates, 0 as , 0, 0
FROM TBL_MATT_RATESET TMR1 
JOIN TBL_RATE_SET TRS2 ON (TMR1.RATESET_UNO=TRS2.RATE_SET_UNO) 
JOIN dbo.HBM_MATTER m ON m.MATTER_UNO=TMR1.MATTER_UNO
join hbm_persnl p on p.empl_uno = m.bill_empl_uno
join hbl_office o on o.offc_code = p.offc
JOIN dbo.HBM_CLIENT c ON c.CLIENT_UNO=m.CLIENT_UNO
WHERE c.CLIENT_CODE != trs2.RATE_SET_CODE AND m.MATTER_UNO != 0  and m.inactive = 'N'

union

--two variable rates
select t1.matter_number, 0, 1, 0, 0, 0, 0				
from #temp t1 						
join #temp t2 on t1.matter_uno=t2.matter_uno and t1.id=t2.id - 1 and t1.eff_date=t2.eff_date						
where t1. matter_uno != 0 and t1.rate_level != t2.rate_level						

union

--two variable rates - but different rates
select t1.matter_number, 0, 0, 1, 0, 0, 0				
from #temp t1 						
join #temp t2 on t1.matter_uno=t2.matter_uno and t1.id=t2.id - 1 and t1.eff_date=t2.eff_date						
where t1. matter_uno != 0 and t1.rate_level = t2.rate_level	

union	

--matter variable and standard price mismatch
select m.matter_number, 0, 0, 0, 1, 0, 0							
from tbm_matter c								
join hbm_matter m on c.matter_uno=m.matter_uno								
join (SELECT m.matter_uno, billing_atty = p.employee_name,max(b.BILL_DATE) as last_bill_date																
FROM blt_billm bm								
JOIN dbo.BLT_BILL b ON b.TRAN_UNO=bm.BILL_TRAN_UNO								
JOIN dbo.HBM_MATTER m ON m.MATTER_UNO = bm.MATTER_UNO
join hbm_persnl p on p.empl_uno = m.bill_empl_uno								
JOIN dbo.HBM_CLIENT c ON m.CLIENT_UNO=c.CLIENT_UNO								
JOIN HBL_STATUS_MATT s ON s.STATUS_CODE=m.STATUS_CODE								
--WHERE s.ALLOW_TIME = 'Y' AND m.CLOSE_DATE IS NULL AND m.INACTIVE = 'N' 								
--AND c.ENTITY_TYPE IN ('B', 'C') AND c.CLIENT_UNO != 0 AND c.INACTIVE = 'N'	
where m.inactive = 'N'						
group by m.matter_uno, p.employee_name	) md on m.matter_uno = md.matter_uno								
left join  (SELECT TCR1.REC_TYPE,TCR1.EFF_DATE,TCR1.RANK_CODE,HP3.EMPL_UNO, 								
HP3.EMPLOYEE_NAME,HP3.EMPLOYEE_CODE,TCR1.LEVEL_TYPE,TCR1.MATTER_UNO,            								
TCR1.CLIENT_UNO,TCR1.ROW_UNO,TCR1.RATE_LEVEL,TCR1.END_DATE, row_number () over (partition by MATTER_UNO order by MATTER_UNO, eff_date desc) id								
FROM TBM_CLMAT_RATEL 								
TCR1 LEFT OUTER JOIN HBM_PERSNL HP3 ON (TCR1.EMPL_UNO=HP3.EMPL_UNO) WHERE       								
(TCR1.client_uno=0 AND TCR1.REC_TYPE='1') ) u on c.matter_uno = u.matter_uno and u.id = 1								
where (c.rate_level != u.rate_level and u.rate_level in (4,5,86,87,88,89,90 )) 								
					
union


--active matter and rateset override 
select t1.matter_number, 0, 0, 0, 0, 1, 0
from
(
SELECT c.CLIENT_UNO,c.CLIENT_CODE,c.CLIENT_NAME,m.MATTER_CODE,m.MATTER_UNO,m.MATTER_NUMBER, m.matter_name, billing_atty = ba.employee_name
, CASE WHEN MIN(f.RATE_SET_UNO)>0 THEN 'Y' else 'N' END AS has_rateset
FROM TBM_RATE_FEE f
JOIN TBL_MATT_RATESET TMR1 ON f.RATE_SET_UNO=TMR1.RATESET_UNO AND GETDATE() BETWEEN tmr1.START_DATE AND tmr1.END_DATE
join TBL_RATE_SET rs on TMR1.rateset_uno= rs.rate_set_uno and rs.inactive='N'
JOIN dbo.HBM_MATTER m ON tmr1.MATTER_UNO=m.MATTER_UNO
join tbm_matter tm on m.matter_uno=tm.matter_uno
JOIN TBL_LEVEL_FEE r ON tm.RATE_LEVEL=r.RATE_LEVEL
JOIN dbo.HBM_CLIENT c ON c.CLIENT_UNO=m.CLIENT_UNO
join dbo.hbm_name cn on c.name_uno=cn.name_uno
JOIN dbo.HBM_PERSNL cb ON c.BILL_EMPL_UNO=cb.EMPL_UNO
JOIN dbo.HBM_PERSNL ba ON m.BILL_EMPL_UNO=ba.EMPL_UNO
JOIN dbo.HBM_PERSNL ra ON m.RESP_EMPL_UNO=ra.EMPL_UNO
WHERE f.GROUP_TYPE = 3 
and m.inactive = 'N'
GROUP BY c.CLIENT_UNO,c.CLIENT_CODE,c.CLIENT_NAME,m.MATTER_CODE,m.MATTER_UNO,m.MATTER_NUMBER, m.matter_name, ba.employee_name
) t1
full join 
(
SELECT c.CLIENT_UNO,c.CLIENT_CODE, c.CLIENT_NAME,m.MATTER_CODE,m.MATTER_UNO,m.MATTER_NUMBER, m.matter_name
, CASE WHEN MIN(f.MATTER_UNO)>0 THEN 'Y' ELSE 'N' END AS has_matter_override
FROM TBM_RATE_FEE f
JOIN dbo.HBM_MATTER m ON f.MATTER_UNO=m.MATTER_UNO
join tbm_matter tm on m.matter_uno=tm.matter_uno
JOIN TBL_LEVEL_FEE r ON tm.RATE_LEVEL=r.RATE_LEVEL
JOIN dbo.HBM_CLIENT c ON c.CLIENT_UNO=m.CLIENT_UNO
join dbo.hbm_name cn on c.name_uno=cn.name_uno
JOIN dbo.HBM_PERSNL cb ON c.BILL_EMPL_UNO=cb.EMPL_UNO
JOIN dbo.HBM_PERSNL ba ON m.BILL_EMPL_UNO=ba.EMPL_UNO
JOIN dbo.HBM_PERSNL ra ON m.RESP_EMPL_UNO=ra.EMPL_UNO
WHERE f.GROUP_TYPE = 1 AND GETDATE() BETWEEN  f.EFF_DATE AND f.END_DATE 
GROUP BY c.CLIENT_UNO,c.CLIENT_CODE,c.CLIENT_NAME,m.MATTER_CODE,m.MATTER_UNO,m.MATTER_NUMBER, m.matter_name
) t2 on t1.matter_uno = t2.matter_uno
where isnull(t1.has_rateset,0) = 'Y' 
and isnull(t2.has_matter_override,0) = 'Y'

union

--inactive ratesets attached to active matters
select m.matter_number, 0, 0, 0, 0, 0, 1
from tbl_matt_rateset mr
join tbl_rate_set r on r.rate_set_uno = mr.rateset_uno
join (select rate_set_uno, max(end_date) as max_end_date from tbm_rate_fee group by rate_set_uno) d on d.rate_set_uno = mr.rateset_uno
join hbm_matter m on m.matter_uno = mr.matter_uno
join hbm_persnl p on p.empl_uno = m.bill_empl_uno
where getdate() between mr.start_date and mr.end_date 
and r.inactive = 'Y'
and m.inactive = 'N'
) u1

end

go
