--1
--(1) 创建用户tom和jerry，初始密码均为'123456'；
create user tom with password 'hust_1234';
create user jerry with password 'hust_1234';
--(2) 授予用户tom查询客户的姓名，邮箱和电话的权限,且tom可转授权限；
grant select(c_name, c_mail, c_phone) on client to tom with grant option;
--(3) 授予用户jerry修改银行卡余额的权限；
grant update(b_balance) on bank_card to jerry;
--(4) 收回用户Cindy查询银行卡信息的权限。
revoke select on bank_card from Cindy;

--2
-- (1) 创建角色client_manager和fund_manager；
create role client_manager with password 'hust_1234';
create role fund_manager with password 'hust_1234';
-- (2) 授予client_manager对client表拥有select,insert,update的权限；
grant select, insert, update on client to client_manager;
-- (3) 授予client_manager对bank_card表拥有查询除银行卡余额外的select权限；
grant select(b_c_id, b_number, b_type) on bank_card to client_manager;
-- (4) 授预fund_manager对fund表的select,insert,update权限；
grant select, insert, update on fund to fund_manager;
-- (5) 将client_manager的权限授予用户tom和jerry；
grant client_manager to tom, jerry;
-- (6) 将fund_manager权限授予用户Cindy.
grant fund_manager to Cindy;