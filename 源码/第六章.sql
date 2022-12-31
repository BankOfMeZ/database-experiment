--1
create procedure sp_fibonacci(in m int)
as
    declare a int default 0;
    declare b int default 1;
    declare n int default 2;
    declare t int default 0;
begin
    IF m > 0 THEN
        INSERT INTO fibonacci VALUES (0, 0);
    END IF;
    IF m > 1 THEN
        INSERT INTO fibonacci VALUES (1, 1);
    END IF;
    WHILE m>n LOOP
        INSERT INTO fibonacci VALUES (n, a + b);
        t := a + b;
        a := b;
        b := t;
        n := n + 1;
    END LOOP;
end;

--3
create procedure sp_transfer(IN applicant_id int,      
                     IN source_card_id char(30),
					 IN receiver_id int, 
                     IN dest_card_id char(30),
					 IN	amount numeric(10,2),
					 OUT return_code int)
as 
	
begin	
    update bank_card set b_balance = b_balance - amount where b_type = '储蓄卡' and b_number = source_card_id and b_c_id = applicant_id;
    update bank_card set b_balance = b_balance + amount where b_type = '储蓄卡' and b_number = dest_card_id and b_c_id = receiver_id;
    update bank_card set b_balance = b_balance - amount where b_type = '信用卡' and b_number = dest_card_id and b_c_id = receiver_id;
    if not exists(select * from bank_card where b_type = '储蓄卡' and b_number = source_card_id and b_c_id = applicant_id and b_balance >= 0) then
        return_code := 0;
        rollback;
    elseif not exists(select * from bank_card where b_number = dest_card_id and b_c_id = receiver_id) then
        return_code := 0;
        rollback;
    else
        return_code := 1;
        commit;
    end if;
end;