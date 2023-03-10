CREATE OR REPLACE FUNCTION TRI_INSERT_FUNC() RETURNS TRIGGER AS
$$
DECLARE
   --此处用declare语句声明你所需要的变量
   message varchar(128);
BEGIN
   --此处插入触发器业务
   if new.pro_type <> 1 and new.pro_type <> 2 and new.pro_type <> 3 then
   	message := concat('type ',new.pro_type,' is illegal!');
   	raise exception '%',message;
   end if;

   if new.pro_type = 1 and not exists(select * from finances_product where finances_product.p_id = new.pro_pif_id) then
   	message := concat('finances product #',new.pro_pif_id,' not found!');
   	raise exception '%',message;
   end if;

   if new.pro_type = 2 and not exists(select * from insurance where insurance.i_id = new.pro_pif_id) then
   	message := concat('insurance #',new.pro_pif_id,' not found!');
   	raise exception '%',message;
   end if;

   if new.pro_type = 3 and not exists(select * from fund where fund.f_id = new.pro_pif_id) then
   	message := concat('fund #',new.pro_pif_id,' not found!');
   	raise exception '%',message;
   end if;
   --触发器业务结束
   return new;--返回插入的新元组
END;
$$ LANGUAGE PLPGSQL;


-- 创建before_property_inserted触发器，使用函数TRI_INSERT_FUNC实现触发器逻辑：
CREATE  TRIGGER before_property_inserted BEFORE INSERT ON property
FOR EACH ROW 
EXECUTE PROCEDURE TRI_INSERT_FUNC();