USE [ADR_train]
GO

/****** Object:  StoredProcedure [dbo].[_ven_getClientsWIPBalance]    Script Date: 3/24/2016 10:45:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		Monika Acosta
-- Create date: 2016-03-24
-- Description:	Get WIP Balance for a number of clients by a date.
-- =============================================
alter PROCEDURE [_ven_getSTACTAddresses]
	-- Add the parameters for the stored procedure here
AS
BEGIN




select distinct row_number() over(partition by n.name_uno order by n.name_uno) as row_, case when STATE_CODE is null then '' else STATE_CODE end as STATE_CODE
, address1, _POBOX, CITY, POST_CODE
, case when state_code != '' then 'US' when state_code = '' and country_code = '' then 'international' else country_code end as country_code
, n.name_uno
into #address_row
from adr_live..HBM_NAME n 
JOIN adr_live..HBM_ADDRESS ca on ca.NAME_UNO=n.NAME_UNO  AND  ca.ADDR_TYPE_CODE = 'STACT' and ca.inactive = 'N'
order by n.name_uno

select * 
into #stact_addresses
from #address_row 
except 
select * 
from #address_row 
where name_uno in (select name_uno from (select name_uno, max(row_) as row_ from #address_row group by name_uno having max(row_) > 1) u1)
union
select 1, 'multiple', '', '', '', '', '', name_uno
from #address_row 
where name_uno in (select name_uno from (select name_uno, max(row_) as row_ from #address_row group by name_uno having max(row_) > 1) u1)

select * from #stact_addresses

END



GO

--exec [_ven_getSTACTAddresses]


