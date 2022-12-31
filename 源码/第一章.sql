-- 第一关
create database beijing2022;

-- 第二关
create table if not exists t_emp
(
    id int primary key,
    name varchar(32),
    deptid int,
    salary float
);

-- 第三关
create table dept
(
    deptNo int primary key,
    deptName varchar(32)
);
create table staff
(
    staffNo int primary key,
    staffName varchar(32),
    gender char(1),
    dob date,
    Salary numeric(8, 2),
    deptNo int,
    constraint FK_staff_deptNo foreign key(deptNo) references dept(deptNo)
);

--第四关
create table products
(
    pid char(10) primary key,
    name varchar(32),
    brand char(10) constraint CK_products_brand check(brand in ('A', 'B')),
    price int constraint CK_products_price check(price > 0)
);

--第五关
create table hr
(
    id char(10) primary key,
    name varchar(32) not null,
    mz char(16) default '汉族'
);

--第六关
create table s
(
    sno char(10) primary key,
    name varchar(32) not null,
    ID char(18) unique
);