--drop table client_detail
create table client_detail (
client_code char(10), --PRIMARY KEY,
client_short_name varchar(40) null,
client_name varchar(120) null,
client_billing_atty_name varchar(40) null,
client_billing_atty_code char(6) null,
client_orig_atty_name varchar(40) null,
client_orig_atty_code char(6) null,
stact_address varchar(60) null,
stact_state varchar(8) null,
stact_country varchar(5) null,
stact_city varchar(60) null,
stact_postal_code varchar(10) null,
stact_po_box varchar(40) null,
default_rate_level_id int,
default_rate_level varchar(80),
previous_rate_level_id int,
previous_rate_level varchar(80),
variable_rate_id int,
variable_rate varchar(80),
effective_variable_date datetime,
has_client_override int
--,
--client_group_code varchar(6) null,
--client_group_desc varchar(50) null,
--relation_atty_code1 char(6) null,
--relation_atty_name1 varchar(40) null,
--relation_atty_code2 char(6) null,
--relation_atty_name2 varchar(40) null,
--relation_atty_code3 char(6) null,
--relation_atty_name3 varchar(40) null
)


IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_ClientDetail_client_code') 
    DROP INDEX IX_ClientDetail_client_code ON client_detail; 
GO
CREATE NONCLUSTERED INDEX IX_ClientDetail_client_code 
    on client_detail (client_code)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table matter_detail
create table matter_detail (
client_code char(10), --FOREIGN KEY REFERENCES client_detail(client_code),
matter_number int PRIMARY KEY,
matter_short_name varchar(40),
matter_name varchar(250) null,
matter_billing_atty_name varchar(40) null,
matter_billing_atty_code char(6) null,
matter_resp_atty_name varchar(40) null,
matter_resp_atty_code char(6) null,
billing_coordinator_name varchar(40) null,
billing_coordinator_code char(6) null,
external_ebilling_number varchar(50) null,
open_date datetime null,
open_date_key int null,
close_date datetime null,
close_date_key int null,
status_desc varchar(80) null,
default_rate_level_id int,
default_rate_level varchar(80),
previous_rate_level_id int,
previous_rate_level varchar(80),
variable_rate_id int,
variable_rate varchar(80),
effective_variable_date datetime,
has_rateset_override int,
has_matter_override int)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_MatterDetail_matter_number') 
    DROP INDEX IX_MatterDetail_matter_number ON matter_detail; 
GO
CREATE NONCLUSTERED INDEX IX_MatterDetail_matter_number 
    on matter_detail (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_MatterDetail_client_code') 
    DROP INDEX IX_MatterDetail_client_code ON matter_detail; 
GO
CREATE NONCLUSTERED INDEX IX_MatterDetail_client_code 
    on matter_detail (client_code)
GO

--drop table matter_override_rates
create table matter_override_rates (
matter_override_rates_id int identity(1,1) PRIMARY KEY,
matter_number int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
timekeeper_name varchar(40) null,
timekeeper_code char(6) null,
rank_id int null,
rank varchar(80) null,
rate_set_code char(10) null,
rate_set_description varchar(80) null,
rateset_attachment_start_date datetime null,
rateset_attachment_start_date_key int null,
rateset_attachment_end_date datetime null,
rateset_attachment_end_date_key int null,
override_start_date datetime null,
override_start_date_key int null,
override_end_date datetime null,
override_end_date_key int null,
override_rate decimal(25,10) null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_MatterOverrideRates_matter_number') 
    DROP INDEX IX_MatterOverrideRates_matter_number ON matter_override_rates; 
GO
CREATE NONCLUSTERED INDEX IX_MatterOverrideRates_matter_number 
    on matter_override_rates (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table bill_group_detail
create table bill_group_detail (
bill_group_code char(10), --PRIMARY KEY,
bill_grp_uno int,
client_code char(10), --FOREIGN KEY REFERENCES client_detail(client_code),
--matter_number int null,
bill_group_desc varchar(80) null,
address varchar(60) null,
state varchar(8) null,
country_code varchar(5) null,
city varchar(60) null,
postal_code varchar(10) null,
po_box varchar(40) null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_BillGroupDetail_client_code') 
    DROP INDEX IX_BillGroupDetail_client_code ON bill_group_detail; 
GO
CREATE NONCLUSTERED INDEX IX_BillGroupDetail_client_code 
    on bill_group_detail (client_code)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_BillGroupDetail_bill_grp_code') 
    DROP INDEX IX_BillGroupDetail_bill_grp_code ON bill_group_detail; 
GO
CREATE NONCLUSTERED INDEX IX_BillGroupDetail_bill_grp_code 
    on bill_group_detail (bill_group_code)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_BillGroupDetail_bill_grp_uno') 
    DROP INDEX IX_BillGroupDetail_bill_grp_uno ON bill_grp_uno; 
GO
CREATE NONCLUSTERED INDEX IX_BillGroupDetail_bill_grp_uno 
    on bill_group_detail (bill_grp_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--IF EXISTS (SELECT name FROM sys.indexes
--            WHERE name = N'IX_BillGroupDetail_matter_number') 
--    DROP INDEX IX_BillGroupDetail_matter_number ON matter_number; 
--GO
--CREATE NONCLUSTERED INDEX IX_BillGroupDetail_matter_number 
--    on bill_group_detail (matter_number)
--	--ON Purchasing.ProductVendor (BusinessEntityID); 
--GO

--drop table prebill_detail
create table prebill_detail (
prebill_num int, --PRIMARY KEY,
billgrp_code char(10), --FOREIGN KEY REFERENCES bill_group_detail(bill_group_code),
matter_num int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
bill_date datetime,
_PBILL_STATUS_DATE datetime null,
_PBILL_STATUS_NOTES varchar(260) null,
fees_bill decimal(25, 10) null,
pb_billing_coordinator_code char(6) null,
pb_billing_coordinator_name varchar(40) null
)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_PrebillDetail_bill_grp_code') 
    DROP INDEX IX_PrebillDetail_bill_grp_code ON prebill_detail; 
GO
CREATE NONCLUSTERED INDEX IX_PrebillDetail_bill_grp_code 
    on prebill_detail (billgrp_code)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_PrebillDetail_prebill_num') 
    DROP INDEX IX_PrebillDetail_prebill_num ON prebill_detail; 
GO
CREATE NONCLUSTERED INDEX IX_PrebillDetail_prebill_num 
    on prebill_detail (prebill_num)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_PrebillDetail_matter_num') 
    DROP INDEX IX_PrebillDetail_matter_num ON prebill_detail; 
GO
CREATE NONCLUSTERED INDEX IX_PrebillDetail_matter_num 
    on prebill_detail (matter_num)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_PrebillDetail_bill_date') 
    DROP INDEX IX_PrebillDetail_bill_date ON prebill_detail; 
GO
CREATE CLUSTERED INDEX IX_PrebillDetail_bill_date 
    on prebill_detail (bill_date)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO


--drop table tran_detail
create table tran_detail (
tran_uno int primary key,
tran_type_desc varchar(80))

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_TranDetail_tran_uno') 
    DROP INDEX IX_TranDetail_tran_uno ON tran_detail; 
GO
CREATE NONCLUSTERED INDEX IX_TranDetail_tran_uno 
    on tran_detail (tran_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table fees_summary
create table fees_summary (
fees_summary_id int identity(1,1) PRIMARY KEY,
bill_grp_uno int,
bill_tran_uno int,
prebill_num int, --FOREIGN KEY REFERENCES prebill_detail(prebill_num),
matter_number int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
billgrp_code char(10), --FOREIGN KEY REFERENCES bill_group_detail(bill_group_code), 
bill_date datetime null,
bill_date_key int null,
fees_billed_amt decimal(25,10) null,
hard_billed_amt decimal(25,10) null,
soft_billed_amt decimal(25,10) null,
discount_level float null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_bill_tran_uno') 
    DROP INDEX IX_FeesSummary_bill_tran_uno ON fees_summary; 
GO
CREATE NONCLUSTERED INDEX IX_FeesSummary_bill_tran_uno 
    on fees_summary (bill_tran_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_matter_number') 
    DROP INDEX IX_FeesSummary_matter_number ON fees_summary; 
GO
CREATE NONCLUSTERED INDEX IX_FeesSummary_matter_number 
    on fees_summary (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_prebill_num') 
    DROP INDEX IX_FeesSummary_prebill_num ON fees_summary; 
GO
CREATE NONCLUSTERED INDEX IX_FeesSummary_prebill_num 
    on fees_summary (prebill_num)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_billgrp_code') 
    DROP INDEX IX_FeesSummary_billgrp_code ON fees_summary; 
GO
CREATE NONCLUSTERED INDEX IX_FeesSummary_billgrp_code 
    on fees_summary (billgrp_code)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_fees_summary_id') 
    DROP INDEX IX_FeesSummary_fees_summary_id ON fees_summary; 
GO
CREATE NONCLUSTERED INDEX IX_FeesSummary_fees_summary_id 
    on fees_summary (fees_summary_id)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_bill_grp_uno') 
    DROP INDEX IX_FeesSummary_bill_grp_uno ON bill_grp_uno; 
GO
CREATE NONCLUSTERED INDEX IX_FeesSummary_bill_grp_uno 
    on fees_summary (bill_grp_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_FeesSummary_bill_date') 
    DROP INDEX IX_FeesSummary_bill_date ON fees_summary; 
GO
CREATE CLUSTERED INDEX IX_FeesSummary_bill_date 
    on fees_summary (bill_date)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table apportioned_pct 
create table apportioned_pct (
apportioned_pct_id int identity(1,1) PRIMARY KEY,
fees_summary_id int, --FOREIGN KEY REFERENCES fees_summary(fees_summary_id),
app_orig_client_atty varchar(40) null,
app_orig_client_atty_code char(6) null,
orig_pct_client_allocation numeric(16,4) null,
app_orig_matter_atty varchar(40) null,
app_orig_matter_atty_code char(6) null,
orig_pct_matter_allocation numeric(16,4) null,
app_resp_matter_atty varchar(40) null,
app_resp_matter_atty_code char(6) null,
resp_pct_matter_allocation numeric(16,4) null
)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_ApportionedPct_fees_summary_id') 
    DROP INDEX IX_ApportionedPct_fees_summary_id ON apportioned_pct; 
GO
CREATE NONCLUSTERED INDEX IX_ApportionedPct_fees_summary_id 
    on apportioned_pct (fees_summary_id)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--only in staging
--create table tbm_clmat_part (
--row_uno int null,
--rec_type varchar(1) null,
--matter_number int null,
--client_code char(10) null,
--part_cat_code varchar(4) null,
--eff_date datetime null,
--to_date datetime null,
--employee_code char(6) null,
--employee_name varchar(40) null,
--percentage numeric(16, 4) null,
--last_modified datetime null
--)

--drop table fee_write_off_detail
create table fee_write_off_detail (
fee_write_off_id int identity(1,1) PRIMARY KEY,
bill_tran_uno int,
matter_number int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
write_off_tran_uno int,
write_off_date datetime null,
write_off_date_key int,
write_off_fees_amt decimal(25,10) null,
write_off_hard_amt decimal(25,10) null,
write_off_soft_amt decimal(25,10) null,
write_off_type char(3))

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_WriteOffDetail_bill_tran_uno') 
    DROP INDEX IX_WriteOffDetail_bill_tran_uno ON fee_write_off_detail; 
GO
CREATE NONCLUSTERED INDEX IX_WriteOffDetail_bill_tran_uno 
    on fee_write_off_detail (bill_tran_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_WriteOffDetail_write_off_date') 
    DROP INDEX IX_WriteOffDetail_write_off_date ON fee_write_off_detail; 
GO
CREATE CLUSTERED INDEX IX_WriteOffDetail_write_off_date 
    on fee_write_off_detail (write_off_date)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_WriteOffDetail_matter_number') 
    DROP INDEX IX_WriteOffDetail_matter_number ON fee_write_off_detail; 
GO
CREATE NONCLUSTERED INDEX IX_WriteOffDetail_matter_number 
    on fee_write_off_detail (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table reciept_detail
create table reciept_detail (
reciept_id int identity(1,1) PRIMARY KEY,
bill_tran_uno int,
matter_number int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
reciept_tran_uno int,
reciept_date datetime null,
reciept_fees_amt decimal(25,10) null,
reciept_hard_amt decimal(25,10) null,
reciept_soft_amt decimal(25,10) null,
reciept_type char(3))

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_RecieptDetail_reciept_date') 
    DROP INDEX IX_RecieptDetail_reciept_date ON reciept_detail; 
GO
CREATE CLUSTERED INDEX IX_RecieptDetail_reciept_date 
    on reciept_detail (reciept_date)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_RecieptDetail_bill_tran_uno') 
    DROP INDEX IX_RecieptDetail_bill_tran_uno ON reciept_detail; 
GO
CREATE NONCLUSTERED INDEX IX_RecieptDetail_bill_tran_uno 
    on reciept_detail (bill_tran_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_RecieptDetail_matter_number') 
    DROP INDEX IX_RecieptDetail_matter_number ON reciept_detail; 
GO
CREATE NONCLUSTERED INDEX IX_RecieptDetail_matter_number 
    on reciept_detail (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table time_detail
create table time_detail (
time_detail_id int identity(1,1) PRIMARY KEY,
time_uno int, --primary key,
matter_number int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
bil_tran_number int null,
worked_date datetime null,
worked_month datetime null,
base_hours money null,
tobill_hrs money null,
timeKeeper_name varchar(40) null,
timeKeeper_code char(6) null,
posted_date datetime null,
posted_month datetime null,
WIP_status char(1) null,
base_amt decimal(25, 10) null,
std_amt decimal(25, 10) null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_TimeDetail_matter_number') 
    DROP INDEX IX_TimeDetail_matter_number ON time_detail; 
GO
CREATE NONCLUSTERED INDEX IX_TimeDetail_matter_number 
    on time_detail (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_TimeDetail_time_detail_id') 
    DROP INDEX IX_TimeDetail_time_detail_id ON time_detail; 
GO
CREATE NONCLUSTERED INDEX IX_TimeDetail_time_detail_id 
    on time_detail (time_detail_id)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_TimeDetail_bil_tran_number') 
    DROP INDEX IX_TimeDetail_bil_tran_number ON time_detail; 
GO
CREATE NONCLUSTERED INDEX IX_TimeDetail_bil_tran_number 
    on time_detail (bil_tran_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_TimeDetail_worked_date') 
    DROP INDEX IX_TimeDetail_worked_date ON time_detail; 
GO
CREATE CLUSTERED INDEX IX_TimeDetail_worked_date 
    on time_detail (worked_date)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table aged_wip
create table aged_wip (
time_detail_id int, --FOREIGN KEY REFERENCES time_detail(time_detail_id),
aged31 int null,
aged61 int null,
aged181 int null, 
aged361 int null,  
aged721 int null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_AgedWIP_time_detail_id') 
    DROP INDEX IX_AgedWIP_time_detail_id ON aged_wip; 
GO
CREATE NONCLUSTERED INDEX IX_AgedWIP_time_detail_id 
    on aged_wip (time_detail_id)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table aged_ar
create table aged_ar (
fees_summary_id int, --FOREIGN KEY REFERENCES fees_summary(fees_summary_id),
aged_fees_billed_30 decimal(25,10) null,
aged_fees_billed_60 decimal(25,10) null,
aged_fees_billed_180 decimal(25,10) null, 
aged_fees_billed_360 decimal(25,10) null,  
aged_fees_billed_720 decimal(25,10) null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_AgedAR_fees_summary_id') 
    DROP INDEX IX_AgedAR_fees_summary_id ON aged_ar; 
GO
CREATE NONCLUSTERED INDEX IX_AgedAR_fees_summary_id 
    on aged_ar (fees_summary_id)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

--drop table disbursment_detail
create table disbursment_detail (
matter_number int, --FOREIGN KEY REFERENCES matter_detail(matter_number),
bill_tran_uno int null,
tran_date datetime null,
period datetime null,
billed_amt decimal(25, 10) null,
hardsoft char(1) null,
cost_code char(6) null,
cost_desc varchar(80) null)

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_DisbursmentDetail_matter_number') 
    DROP INDEX IX_DisbursmentDetail_matter_number ON disbursment_detail; 
GO
CREATE NONCLUSTERED INDEX IX_DisbursmentDetail_matter_number 
    on disbursment_detail (matter_number)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_DisbursmentDetail_bill_tran_uno') 
    DROP INDEX IX_DisbursmentDetail_bill_tran_uno ON disbursment_detail; 
GO
CREATE NONCLUSTERED INDEX IX_DisbursmentDetail_bill_tran_uno 
    on disbursment_detail (bill_tran_uno)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_DisbursmentDetail_tran_date') 
    DROP INDEX IX_DisbursmentDetail_tran_date ON disbursment_detail; 
GO
CREATE CLUSTERED INDEX IX_DisbursmentDetail_tran_date 
    on disbursment_detail (tran_date)
	--ON Purchasing.ProductVendor (BusinessEntityID); 
GO

drop table matter_config_errors
create table matter_config_errors (
matter_number int,
rateset_client_code_mismatch int,
_2varFees int,
_2varFeesDiffRates int,
var_std_mismatch int,
matter_rateset_overrides int,
inactive_ratesets_to_matter int)

--IF EXISTS (SELECT name FROM sys.indexes
--            WHERE name = N'IX_matter_config_errors_Matter_number') 
--    DROP INDEX IX_matter_config_errors_Matter_number ON matter_number; 
--GO
--CREATE CLUSTERED INDEX IX_matter_config_errors_Matter_number 
--    on disbursment_detail (tran_date)
--	--ON Purchasing.ProductVendor (BusinessEntityID); 
--GO

