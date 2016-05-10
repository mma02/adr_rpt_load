USE [ADR_train]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [BI_load_tran_detail]

create procedure [dbo].[BI_load_tran_detail]
as

select t.tran_uno, tt.tran_type_desc
from act_tran t 
join acl_tran_type tt on t.trans_type = tt.tran_type

go