USE [adr_train]
GO

/****** Object:  StoredProcedure [dbo].[_ven_VN_WIP17_Aged_WIP]    Script Date: 2/25/2016 2:16:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




alter procedure [dbo].[BI_load_tbm_clmat_part]


as

set nocount on;

select t.row_uno,
t.rec_type,
m.matter_number,
c.client_code,
t.part_cat_code,
t.eff_date,
t.to_date,
p.employee_code,
p.employee_name,
t.percentage,
t.last_modified
from tbm_clmat_part t
join hbm_matter m on m.matter_uno = t.matter_uno
join hbm_client c on c.client_uno = t.client_uno
join hbm_persnl p on p.empl_uno = t.empl_uno
where t.to_date >= '1/1/2015'

go


