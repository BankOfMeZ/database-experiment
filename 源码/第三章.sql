-- 1
select c_name, c_phone, c_mail
    from client
    order by c_id;

-- 2
select c_id, c_name, c_id_card, c_phone
    from client
    where c_mail is null;

-- 3
select c_name, c_mail, c_phone
    from client
    where c_id in
    (
        select pro_c_id
            from property
            where pro_type = 3 and pro_c_id in
            (
                select pro_c_id
                    from property
                    where pro_type = 2
            )
    )
    order by c_id;

-- 4
select c_name, c_phone, b_number
    from client, bank_card
    where c_id = b_c_id and b_type = '储蓄卡'
    order by c_id;

-- 5
select p_id, p_amount, p_year
    from finances_product
    where p_amount >= 30000 and p_amount <= 50000
    order by p_amount asc, p_year desc;

-- 6
select pro_income, count(*) as presence
from property
group by pro_income
having presence >= all(
    select count(pro_income)
    from property
    group by pro_income
);

-- 7
select c_name, c_phone, c_mail
from client
where left(c_id_card, 4) = '4201' and c_id not in
(
    select pro_c_id
    from property
    where pro_type = 1
);

-- 8
select c_name, c_id_card, c_phone
from client
where c_id in
(
    select b_c_id
    from
    (
        select *
        from bank_card
        where b_type = '信用卡'
    )
    group by b_c_id
    having count(b_c_id) >= 2
)

-- 9
select c_name, c_phone, c_mail
from client
where c_id in
(
    select pro_c_id
    from property, fund
    where pro_type = 3 and pro_pif_id = f_id and f_type = '货币型'
)
order by c_id;

-- 10
select c_name, c_id_card, total_income
from client,
(
    select pro_c_id, sum(pro_income) as total_income
    from
    (
        select pro_c_id, pro_income
        from property
        where pro_status != '冻结'
    )
    group by pro_c_id
    order by total_income desc
    limit 3
)
where c_id = pro_c_id
order by total_income desc;

-- 11
select t.c_id, c_name, number_of_cards
from client,
(
    select c_id, count(b_number) as number_of_cards
    from
    (
        client left join bank_card
        on c_id = b_c_id
    )
    group by c_id
) as t
where t.c_id = client.c_id and client.c_name like '黄%'
order by number_of_cards desc, t.c_id;

-- 12
select c_name, c_id_card, t0.total_amount as total_amount
from client,
(
    select c_id,
        coalesce(fina_amount + insur_amount + fund_amount, 0)
        as total_amount
    from client left join
    (
        select t1.pro_c_id, t1.amount as fina_amount, t2.amount
            as insur_amount, t3.amount as fund_amount
        from
        (
            select pro_c_id,
                coalesce(sum(pro_quantity * p_amount), 0)
                as amount
            from property left join finances_product
            on pro_type = 1 and pro_pif_id = p_id
            group by pro_c_id
        ) t1,
        (
            select pro_c_id,
                coalesce(sum(pro_quantity * i_amount), 0)
                as amount
            from property left join insurance
            on pro_type = 2 and pro_pif_id = i_id
            group by pro_c_id
        ) t2,
        (
            select pro_c_id,
                coalesce(sum(pro_quantity * f_amount), 0)
                as amount
            from property left join fund
            on pro_type = 3 and pro_pif_id = f_id
            group by pro_c_id
        ) t3
        where t1.pro_c_id = t2.pro_c_id
            and t2.pro_c_id = t3.pro_c_id
    )
    on c_id = pro_c_id
) t0
where client.c_id = t0.c_id
order by total_amount desc;

-- 13
select client.c_id, c_name, (deposit_balance + invest_amount + 
    income_amount - credit_balance) as total_property
from client,
(
    select c_id, coalesce(sum(b_balance), 0) as deposit_balance
    from client left join bank_card
    on c_id = b_c_id and b_type = '储蓄卡'
    group by c_id
) deposit,
(
    select c_id, coalesce(sum(b_balance), 0) as credit_balance
    from client left join bank_card
    on c_id = b_c_id and b_type = '信用卡'
    group by c_id
) credit,
(
    select c_id,
        coalesce(finan_amount + insur_amount + fun_amount, 0)
        as invest_amount
    from client left join
    (
        select finan.pro_c_id as pro_c_id, finan.amount as
            finan_amount, insur.amount as insur_amount,
            fun.amount as fun_amount
        from
        (
            select pro_c_id,
                coalesce(sum(p_amount * pro_quantity), 0)
                as amount
            from property left join finances_product
            on pro_pif_id = p_id and pro_type = 1
            group by pro_c_id
        ) finan,
        (
            select pro_c_id,
                coalesce(sum(i_amount * pro_quantity), 0)
                as amount
            from property left join insurance
            on pro_pif_id = i_id and pro_type = 2
            group by pro_c_id
        ) insur,
        (
            select pro_c_id,
                coalesce(sum(f_amount * pro_quantity), 0)
                as amount
            from property left join fund
            on pro_pif_id = f_id and pro_type = 3
            group by pro_c_id
        ) fun
        where finan.pro_c_id = insur.pro_c_id
            and insur.pro_c_id = fun.pro_c_id
    )
    on c_id = pro_c_id
) invest,
(
    select c_id, coalesce(sum(pro_income), 0) as income_amount
    from client left join property
    on c_id = pro_c_id
    group by c_id
) income
where client.c_id = deposit.c_id and deposit.c_id = credit.c_id
    and credit.c_id = invest.c_id and invest.c_id = income.c_id;

-- 14
select i_id, i_amount
from insurance,
(
    select distinct i_amount as _4th_amount
    from insurance
    order by i_amount desc
    limit 3, 1
)
where i_amount = _4th_amount;

-- 15
-- (1) 基金总收益排名(名次不连续)
select pro_c_id, total_revenue, rank()
    over(order by total_revenue desc) as rank
from
(
    select pro_c_id, sum(pro_income) as total_revenue
    from property
    where pro_type = 3
    group by pro_c_id
);
-- (2) 基金总收益排名(名次连续)
select pro_c_id, total_revenue, dense_rank()
    over(order by total_revenue desc) as rank
from
(
    select pro_c_id, sum(pro_income) as total_revenue
    from property
    where pro_type = 3
    group by pro_c_id
);

-- 16
select c_id1, c_id2
from
(
    select pro_c_id as c_id1, listagg(pro_pif_id)
        within group(order by pro_pif_id) as f_ids
    from property
    where pro_type = 3
    group by pro_c_id
) t1,
(
    select pro_c_id as c_id2, listagg(pro_pif_id)
        within group(order by pro_pif_id) as f_ids
    from property
    where pro_type = 3
    group by pro_c_id
) t2
where t1.f_ids = t2.f_ids and c_id1 < c_id2;

-- 18
select b_c_id, sum(b_balance) as credit_card_amount
from bank_card,
(
    select b_c_id as richman
    from bank_card
    where b_type = '信用卡' and b_balance > 5000
)
where b_c_id = richman and b_type = '信用卡'
group by b_c_id
order by b_c_id;

--24
select pro_c_id1 as pro_c_id, pro_c_id2 as pro_c_id, count(*) as total_count
from
(
      select pro_c_id as pro_c_id1 ,pro_pif_id as pro_pif_id1
      from property
      where pro_type = 1
) p1,
(
      select pro_c_id as pro_c_id2, pro_pif_id as pro_pif_id2
      from property
      where pro_type = 1
) p2
where pro_c_id1 <> pro_c_id2 and pro_pif_id1 = pro_pif_id2
group by (pro_c_id1, pro_c_id2)
having total_count > 1;