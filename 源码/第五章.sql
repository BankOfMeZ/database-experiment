-- 1
create view v_insurance_detail
as
select c_name, c_id_card, i_name, i_project, pro_status, pro_quantity, i_amount, i_year, pro_income, pro_purchase_time
from client, insurance, property
where pro_type = 2 and c_id = pro_c_id and i_id = pro_pif_id;

-- 2
select distinct c_name, c_id_card, insurance_total_amount, insurance_total_revenue
from v_insurance_detail,
(
    select c_name as name_, sum(pro_quantity * i_amount) as insurance_total_amount, sum(pro_income) as insurance_total_revenue
    from v_insurance_detail
    group by c_name
)
where name_ = c_name
order by insurance_total_amount desc;