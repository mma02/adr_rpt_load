USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_bill_group_detail]

alter procedure [dbo].[BI_load_bill_group_detail]
as

create table #stact_addresses (
row_ int null,
state_code varchar(8) null,
address1 varchar(60) null,
_pobox varchar(40) null,
city varchar(60) null,
post_code varchar(10) null,
country_code varchar(20) null,
name_uno int null)
insert into #stact_addresses
exec [_ven_getSTACTAddresses] 

select bg.billgrp_code, bg.billgrp_uno, c.client_code--, hm.matter_number
,bg.billgrp_desc
, CASE WHEN bga.address1='' OR bga.address1 is null then ca.address1 ELSE bga.address1 END AS address1
, CASE WHEN bga.STATE_CODE='' OR bga.STATE_CODE is null then ca.STATE_CODE ELSE bga.STATE_CODE End AS state_code
, CASE WHEN bga.COUNTRY_CODE='' OR bga.COUNTRY_CODE is null then ca.COUNTRY_CODE ELSE bga.COUNTRY_CODE END AS COUNTRY_CODE 
, CASE WHEN bga.CITY='' OR bga.CITY is null then ca.CITY ELSE bga.CITY END AS CITY
, CASE WHEN bga.POST_CODE='' OR bga.POST_CODE is null then ca.POST_CODE ELSE bga.POST_CODE END AS POST_CODE
, CASE WHEN bga._POBOX='' OR bga._POBOX is null then ca._POBOX ELSE bga._POBOX END AS _POBOX
from tbm_billgrp bg
--join tbm_matter m on m.billgrp_uno = bg.billgrp_uno
--join hbm_matter hm on hm.matter_uno = m.matter_uno
JOIN HBM_ADDRESS bga on bga.ADDRESS_UNO=bg.ADDRESS_UNO
JOIN HBM_CLIENT c on c.CLIENT_UNO=bg.CLIENT_UNO  
LEFT JOIN HBM_NAME n on n.NAME_UNO=c.NAME_UNO  
LEFT JOIN #stact_addresses ca on ca.NAME_UNO=n.NAME_UNO 


go




