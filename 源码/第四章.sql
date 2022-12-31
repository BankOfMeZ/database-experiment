-- 1
insert
into client
values (1, '林惠雯', '960323053@qq.com', '411014196712130323', '15609032348', 'Mop5UPkl'),
(2, '吴婉瑜', '1613230826@gmail.com', '420152196802131323', '17605132307', 'QUTPhxgVNlXtMxN'),
(3, '蔡贞仪', '252323341@foxmail.com', '160347199005222323', '17763232321', 'Bwe3gyhEErJ7');

-- 2
insert
into client(c_id, c_name, c_phone, c_id_card, c_password)
values (33, '蔡依婷', '18820762130', '350972199204227621', 'MKwEuc1sc6');

-- 3
insert
into client
select *
from new_client;

-- 4
delete
from client
where c_id not in
(
    select b_c_id
    from bank_card
);

-- 5
update property
set pro_status = '冻结'
where pro_c_id in
(
    select c_id
    from client
    where c_phone = '13686431238'
);

-- 6
update property
set pro_id_card =
(
    select c_id_card
    from client
    where pro_c_id = c_id 
);