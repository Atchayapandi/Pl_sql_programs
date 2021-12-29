create table products(product_id int DEFAULT pro_seq.NEXTVAL PRIMARY KEY,product_name varchar2(20),description varchar2(30),standard_cost number(10),list_price number(10),category_id int);
create sequence pro_seq increment by 1;
drop table products CASCADE CONSTRAINTS;
select * from products;

create table employees(employee_id int DEFAULT emp_seq.NEXTVAL PRIMARY KEY,first_name varchar2(20),last_name varchar2(20),email varchar2(20),phone varchar2(15),hire_date date,manager_id int,job_title varchar2(20));
drop table employees CASCADE CONSTRAINTS;
create sequence emp_seq increment by 1;
select * from employees;

create table customers(customer_id int DEFAULT cus_seq.NEXTVAL PRIMARY KEY,customer_name varchar2(15),address varchar2(30),website varchar2(30),credit_limit int);
drop table customers CASCADE CONSTRAINTS;
create sequence cus_seq increment by 1;
select * from customers;

create table orders(order_id int DEFAULT order_seq.nextval PRIMARY KEY,customer_id int,status varchar2(30),salesman_id int,
order_date date,FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
drop table orders cascade constraints;
create sequence order_seq increment by 1;
select * from orders;

create table order_items(order_id int,item_id int ,product_id int,quantity number(10),unit_price number(10),
FOREIGN KEY (order_id) REFERENCES orders(order_id),FOREIGN KEY (product_id) REFERENCES products(product_id));
drop table order_items CASCADE CONSTRAINTS;
select * from order_items;

create table product_categories(category_id int PRIMARY KEY,category_name varchar2(50));
create sequence ca_seq increment by 1;
select * from product_categories;
drop table product_categories;
select*from order_items;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE sales AS
   --add product
   PROCEDURE add_products(
   p_name products.product_name%type,
   p_desc  products.description%type,
   p_cost products.standard_cost%type,  
   p_price  products.list_price%type,
   p_catagory products.category_id%type,
   p_status out varchar2,
   p_error out varchar2);
   -- Removes a product
   PROCEDURE remove_product(p_id   products.product_id%type,
                            p_status out varchar2,
                            p_error out varchar2);
   --add employees
   PROCEDURE add_employees(
   e_fname employees.first_name%type,
   e_lname employees.last_name%type,
   e_mail employees.email%type,
   p_num employees.phone%type,
   e_hire employees.hire_date%type,
   m_id employees.manager_id%type,
   j_title employees.job_title%type,
   e_status out varchar2,
   e_error out varchar2);
   --remove employees
   PROCEDURE remove_employees(e_id employees.employee_id%type,
                              e_status out varchar2,
                              e_error out varchar2);
   --add customer
   PROCEDURE add_customer(
   c_name customers.customer_name%type,
   c_ad customers.address%type,
   c_website customers.website%type,
   c_limit customers.credit_limit%type,
   c_status out varchar2,
   c_error out varchar2);
  --remove customer
  PROCEDURE remove_customer(c_id customers.customer_id%type,
                            c_status out varchar2,
                            c_error out varchar2);
   
  --add orders
  PROCEDURE add_orders(c_id in number,
                      o_status in varchar2,
                      s_id in number,
                      o_date in date,
                      status out varchar2,
                      or_error out varchar2);
 --cancel orders
 PROCEDURE cancel_order(o_id in number,
                        status out varchar2,
                        or_error out varchar2);
 --add order_items
 PROCEDURE add_order_items(o_id in number,
                           i_id in number ,
                           p_id in number,
                           quan in number,
                           u_price in number,
                           status out varchar2,
                           o_error out varchar2);
 --delete order_items
 PROCEDURE remove_order_items(o_id in number,
                             status out varchar2,
                             o_error out varchar2);
 --add category
 PROCEDURE add_category(ca_id in number,
                       ca_name in varchar2,
                       ca_status out varchar2,
                       ca_error out varchar2);
 --remove category
 PROCEDURE remove_category(ca_id in number,
                           ca_status out varchar2,
                           ca_error out varchar2);
 END sales;
/

------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE PACKAGE BODY sales AS
    PROCEDURE add_products(
   p_name products.product_name%type,
   p_desc  products.description%type,
   p_cost products.standard_cost%type,  
  p_price  products.list_price%type,
   p_catagory products.category_id%type,p_status out varchar2,p_error out varchar2)
   IS
   BEGIN
      INSERT INTO products (product_name,description,standard_cost,list_price,category_id)
         VALUES( p_name, p_desc, p_cost, p_price,p_catagory);
         if sql%rowcount>0
            then p_status:='product inserted';
         end if;
         commit;
         EXCEPTION
         when others then
         p_status:='product not inserted';
         p_error:=sqlcode||sqlerrm;
   END add_products;
   
   PROCEDURE remove_product(p_id   products.product_id%type,p_status out varchar2,p_error out varchar2) IS
   BEGIN
      DELETE FROM products
      WHERE product_id = p_id;
      if sql%rowcount>0
      then p_status:='product deleted';
      end if;
      if sql%rowcount=0
      then p_status:='product id '||p_id||' does not exist';
      end if;
      commit;
         EXCEPTION
         when others then
         p_status:='no data found';
         p_error:=sqlcode||sqlerrm;
         
   END remove_product;

   PROCEDURE add_employees(
   e_fname employees.first_name%type,
   e_lname employees.last_name%type,
   e_mail employees.email%type,
   p_num employees.phone%type,
   e_hire employees.hire_date%type,
   m_id employees.manager_id%type,
   j_title employees.job_title%type,e_status out varchar2,e_error out varchar2)
   IS
   BEGIN
     INSERT INTO employees(first_name,last_name,email,phone,hire_date,manager_id,job_title)
     VALUES(e_fname,e_lname,e_mail,p_num,e_hire,m_id,j_title);
     if sql%rowcount>0
         then e_status:='employee inserted';
         end if;
         commit;
         EXCEPTION
         when others then
         e_status:='employee not inserted';
         e_error:=sqlcode||sqlerrm;
  END add_employees;
 
  PROCEDURE remove_employees(e_id employees.employee_id%type,e_status out varchar2,e_error out varchar2)IS
  BEGIN
      DELETE FROM employees WHERE employee_id=e_id;
      if sql%rowcount>0
         then e_status:='employee deleted';
         end if;
        if sql%rowcount=0
        then e_status:='employee id '||e_id||' does not exist';
        end if;
         commit;
         EXCEPTION
         when no_data_found then
         DBMS_OUTPUT.PUT_LINE('product id does not found');
         when others then
         e_status:='not deleted';
         e_error:=sqlcode||sqlerrm;
  END remove_employees;
 
 
  PROCEDURE add_customer(
   c_name customers.customer_name%type,
   c_ad customers.address%type,
   c_website customers.website%type,
   c_limit customers.credit_limit%type,c_status out varchar2,c_error out varchar2)IS
   BEGIN
   INSERT INTO customers(customer_name,address,website,credit_limit )
   VALUES(c_name,c_ad,c_website,c_limit);
   if sql%rowcount>0
         then c_status:='customer inserted';
         end if;
         commit;
         EXCEPTION
         when others then
         c_status:='customer not inserted';
         c_error:=sqlcode||sqlerrm;
   END add_customer;
   
   PROCEDURE remove_customer(c_id customers.customer_id%type,c_status out varchar2,c_error out varchar2)IS
   BEGIN
   DELETE FROM customers WHERE customer_id=c_id;
   if sql%rowcount>0
         then c_status:='customer deleted';
         end if;
          if sql%rowcount=0
        then c_status:='customer id '||c_id||'not deleted';
        end if;
         commit;
         EXCEPTION
         when others then
         c_status:='not found';
         c_error:=sqlcode||sqlerrm;
   END remove_customer;
 
 
  PROCEDURE add_orders(
  c_id in number,o_status in varchar2,s_id in number,
 o_date in date,status out varchar2,or_error out varchar2)
 IS
 BEGIN
 INSERT INTO orders(customer_id ,status ,salesman_id ,order_date)
 VALUES(c_id,o_status,s_id,o_date);
 if sql%rowcount>0
         then status:='order inserted';
         end if;
         commit;
         EXCEPTION
         when others then
         status:='order not inserted';
         or_error:=sqlcode||sqlerrm;
 END add_orders;
 
 PROCEDURE cancel_order(o_id in number,status out varchar2,or_error out varchar2) IS
 BEGIN
 UPDATE orders SET status='cancelled' where order_id=o_id;
 if sql%rowcount>0
         then status:='order cancelled';
         end if;
         if sql%rowcount=0
         then status:='order id '||o_id||' does not exist';
         end if;
        commit;
         EXCEPTION
         when others then
         status:='not cancelled';
         or_error:=sqlcode||sqlerrm;
 END cancel_order;
 
PROCEDURE add_order_items(o_id in number,
i_id in number ,p_id in number,quan in number,u_price in number,status out varchar2,o_error out varchar2)
IS
BEGIN
 INSERT INTO order_items(order_id ,item_id ,product_id ,quantity ,unit_price)
 values(o_id,i_id,p_id,quan,u_price);
 if sql%rowcount>0
         then status:='inserted';
         end if;
         commit;
         EXCEPTION
         when others then
         status:='not inserted';
         o_error:=sqlcode||sqlerrm;
 END add_order_items;
 
  PROCEDURE remove_order_items(o_id in number,status out varchar2,o_error out varchar2)IS
  BEGIN
   DELETE FROM order_items WHERE order_id=o_id;
   if sql%rowcount>0
         then status:='deleted';
         end if;
          if sql%rowcount=0
        then status:='order id '||o_id||'does not exist';
        end if;
         commit;
         EXCEPTION
         when others then
         status:='not deleted';
         o_error:=sqlcode||sqlerrm;
   END remove_order_items;
   --add category
   PROCEDURE add_category(ca_id in number,ca_name in varchar2,ca_status out varchar2,ca_error out varchar2) is
   begin
   insert into product_categories (category_id,category_name)values(ca_id,ca_name);
   if sql%rowcount>0
         then ca_status:='inserted';
         end if;
         commit;
         EXCEPTION
         when others then
         ca_status:='not inserted';
         ca_error:=sqlcode||sqlerrm;
 END add_category;
 --remove category
 PROCEDURE remove_category(ca_id in number,ca_status out varchar2,ca_error out varchar2) is
 begin
 delete from product_categories where category_id=ca_id;
 if sql%rowcount>0
         then ca_status:='deleted';
         end if;
          if sql%rowcount=0
        then ca_status:='not deleted';
        end if;
         commit;
         EXCEPTION
         when others then
         ca_status:='not deleted';
         ca_error:=sqlcode||sqlerrm;
   END remove_category;

END sales;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


set serveroutput on
--ADD PRODUCT
DECLARE
   p_status varchar2(20);
   p_error varchar2(300);
BEGIN
  sales.add_products('faceGlow gel', 'Skin Care Product', 70, 75, 101,p_status,p_error);
  DBMS_OUTPUT.PUT_LINE(p_status||' '||p_error);
  end;
  select*from products;
--DELETE PRODUCT
SET SERVEROUTPUT ON
DECLARE
     pro_id products.product_id%type:=&enter_id;
     p_status varchar2(200);
     p_error varchar2(500);
     
BEGIN
   sales.remove_product(pro_id,p_status,p_error);
   dbms_output.put_line(p_status||' '||p_error);
end remove_product;
--ADD EMPLOYEE
DECLARE
   e_status varchar2(20);
   e_error varchar2(200);
BEGIN
   sales.add_employees('arun', 'kumar', 'arun@gmail.com', '9876863748', '21-09-2016', 4,'sales',e_status,e_error);
      dbms_output.put_line(e_status||' '||e_error);
end add_employees;
select*from employees;

--DELETE employee
DECLARE
     emp_id employees.employee_id%type:=&enter_id;
     e_status varchar2(200);
     e_error varchar2(500);
BEGIN
   sales.remove_employees(emp_id,e_status,e_error);
   dbms_output.put_line(e_status||' '||e_error);
end remove_empolyees;

--ADD customer
DECLARE
   c_status varchar2(20);
   c_error varchar2(200);
BEGIN
   sales.add_customer( 'arun','kumar', '//https:www.amazon.com/', 5000,c_status,c_error);
      dbms_output.put_line(c_status||' '||c_error);
end add_customer;
--DELETE customer
DECLARE
     cus_id customers.customer_id%type:=&enter_id;
     c_status varchar2(200);
     c_error varchar2(500);
BEGIN
   sales.remove_customer(cus_id,c_status,c_error);
   dbms_output.put_line(c_status||' '||c_error);
end remove_customer;
set serveroutput on
--ADD orders
DECLARE
    status varchar2(30);
    or_error varchar2(300);
BEGIN
    sales.add_orders(1, 'orderd', 21, '03-05-2021',status,or_error);
    dbms_output.put_line(status||' '||or_error);
end add_orders;
--cancel orders
set serveroutput on
DECLARE
    o_id integer:=&Enter_o_id;
    status varchar2(200);
    or_error varchar2(500);
BEGIN
    sales.cancel_order(o_id,status,or_error);
    dbms_output.put_line(status||' '||or_error);
end cancel_order;
select*from orders;
select*from products; 
select*from order_items;
--add order_items
DECLARE
    status varchar2(200);
    o_error varchar2(300);
BEGIN
    sales.add_order_items(6, 2, 1, 1, 32,status,o_error);
     dbms_output.put_line(status||' '||o_error);
end add_order_items;
DECLARE
    o_id integer:=&Enter_o_id;
    status varchar2(200);
    o_error varchar2(300);
BEGIN
    sales.remove_order_items(o_id,status,o_error);
          dbms_output.put_line(status||' '||o_error);

end remove_order_items;
set serveroutput on
--add category
DECLARE
   ca_status varchar2(200);
   ca_error varchar2(400);
BEGIN
  sales.add_category(106,'dairy',ca_status,ca_error);
      dbms_output.put_line(ca_status||' '||ca_error);
end add_category;

--delete category

declare
 ca_id integer :=&enter_id;
 ca_status varchar2(200);
   ca_error varchar2(400);
begin
  sales.remove_category(ca_id,ca_status,ca_error);
  dbms_output.put_line(ca_status||' '||ca_error);
end remove_category;
select*from product_categories;



