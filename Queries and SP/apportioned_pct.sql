USE [BI_staging]
GO

/****** Object:  StoredProcedure [dbo].[_ven_VN_WIP17_Aged_WIP]    Script Date: 2/25/2016 2:16:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--exec [BI_apportioned_pct]


alter procedure [dbo].[BI_apportioned_pct]


as

set nocount on;

select f.fees_summary_id
, app_orig_client_atty = ocp.employee_name
, app_orig_client_atty_code = ocp.employee_code
, orig_pct_client_allocation = ocp.percentage
, app_orig_matter_atty = omp.employee_name
, app_orig_matter_atty_code = omp.employee_code
, orig_pct_matter_allocation = omp.percentage
, app_resp_matter_atty = rmp.employee_name
, app_resp_matter_atty_code = rmp.employee_code
, resp_pct_matter_allocation = rmp.percentage
from adr_rpt..fees_summary f --this will have to be some sort of staging table
join matter_detail m on m.matter_number = f.matter_number 
join client_detail c on c.client_code = m.client_code
join tbm_clmat_part ocp on f.bill_date between ocp.eff_date and ocp.to_date and ocp.part_cat_code = 'O' and ocp.client_code = c.client_code
join tbm_clmat_part omp on f.bill_date between omp.eff_date and omp.to_date and omp.part_cat_code = 'O' and omp.matter_number = f.matter_number
join tbm_clmat_part rmp on f.bill_date between rmp.eff_date and rmp.to_date and rmp.part_cat_code = 'R' and rmp.matter_number = f.matter_number

go

