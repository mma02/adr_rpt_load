create table staging..tbm_clmat_part (
part_cat_code varchar(4) null,
eff_date datetime null,
to_date datetime null,
empl_uno int null,
percentage numeric(16,4) null,
matter_number int null,
client_code char(10) null,
)

truncate table staging..tbm_clmat_part

insert into staging..tbm_clmat_part (
part_cat_code,
eff_date,
to_date,
empl_uno,
percentage,
matter_number,
client_code)
select part_cat_code,eff_date,to_date,empl_uno,percentage, m.matter_number, c.client_number
from tbm_clmat_part p
join hbm_matter m on m.matter_uno = p.matter_uno
join hbm_client c on c.client_uno = p.client_uno
where @load_date between p.eff_date and p.to_Date
