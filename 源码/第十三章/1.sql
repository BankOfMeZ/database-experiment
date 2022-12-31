 # 请将你实现flight_booking数据库的语句写在下方：
drop table if exists "user" cascade;
create table "user"
(
    user_id int primary key,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    dob date not null,
    sex char(1) not null,
    email varchar(50) default '',
    phone varchar(30) default '',
    username varchar(20) not null,
    "password" char(32) not null,
    admin_tag tinyint not null default 0
);
create unique index user_idx on "user" using btree(username);
create sequence user_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter "user"
alter user_id set default nextval('user_seq');

drop table if exists passenger cascade;
create table passenger
(
    passenger_id int primary key,
    id char(18) not null,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    mail varchar(50) default '',
    phone varchar(20) not null,
    sex char(1) not null,
    dob timestamp
);
create unique index passenger_idx on passenger using btree(id);
create sequence passenger_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter passenger
alter passenger_id set default nextval('passenger_seq');

drop table if exists airport cascade;
create table airport
(
    airport_id int2 primary key,
    iata char(3) not null,
    icao char(4) not null,
    "name" varchar(50) not null,
    city varchar(50) default '',
    country varchar(50) default '',
    latitude decimal(11,8) default 0,
    longitude decimal(11,8) default 0
);
create unique index airport_btree_idx_iata on airport using btree(iata);
create unique index airport_btree_idx_icao on airport using btree(icao);
create index airport_norm_idx on airport("name");
create sequence airport_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter airport
alter airport_id set default nextval('airport_seq');

drop table if exists airline cascade;
create table airline
(
    airline_id int primary key,
    "name" varchar(30) not null,
    iata char(2) not null,
    airport_id int2 references airport(airport_id) not null
);
create unique index airline_uni_idx on airline using btree(iata);
create index airline_idx_airport_id on airline using btree(airport_id);
create sequence airline_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter airline
alter airline_id set default nextval('airline_seq');

drop table if exists airplane cascade;
create table airplane
(
    airplane_id int primary key,
    type varchar(50) not null,
    capacity smallint not null,
    identifier varchar(50) not null,
    airline_id int references airline(airline_id) not null
);
create unique index airplane_uni_idx on airplane(airplane_id) using btree;
create index airplane_idx on airplane(airline_id);
create sequence airplane_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter airplane
alter airplane_id set default nextval('airplane_seq');

drop table if exists flightschedule cascade;
create table flightschedule
(
    flight_no char(8) primary key,
    departure timestamp not null,
    arrival timestamp not null,
    duration smallint not null,
    monday tinyint default 0,
    tuesday tinyint default 0,
    wednesday tinyint default 0,
    thursday tinyint default 0,
    friday tinyint default 0,
    saturday tinyint default 0,
    sunday tinyint default 0,
    airline_id int references airline(airline_id) not null,
    "from" int2 references airport(airport_id) not null,
    "to" int2 references airport(airport_id) not null
);
create index flightschedule_idx_airline_id on flightschedule using btree(airline_id);
create index flightschedule_idx_from on flightschedule using btree("from");
create index flightschedule_idx_to on flightschedule using btree("to");

drop table if exists flight cascade;
create table flight
(
    flight_id int primary key not null,
    departure timestamp not null,
    arrivals timestamp not null,
    duration smallint not null,
    airline_id int references airline(airline_id) not null,
    airplane_id int references airplane(airplane_id)not null,
    flight_no char(8) references flightschedule(flight_no) not null,
    "from" int2 references airport(airport_id) not null,
    "to" int2 references airport(airport_id) not null
);
create index flight_idx_airline_id on flight using btree(airline_id);
create index flight_idx_arrivals on flight using btree(arrivals);
create index flight_idx_departure on flight using btree(departure);
create index flight_idx_flight_no on flight using btree(flight_no);
create index flight_idx_from on flight using btree("from");
create index flight_idx_to on flight using btree("to");
create sequence flight_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter flight
alter flight_id set default nextval('flight_seq');

drop table if exists ticket cascade;
create table ticket
(
    ticket_id int primary key,
    seat char(4) default '',
    price decimal(10, 2) not null,
    flight_id int references flight(flight_id) not null,
    passenger_id int references passenger(passenger_id) not null,
    user_id int references "user"(user_id) not null
);
create index ticket_idx_flight_id on ticket using btree(flight_id);
create index ticket_idx_passenger_id on ticket using btree(passenger_id);
create index ticket_idx_user_id on ticket using btree(user_id);
create sequence ticket_seq
increment 1
minvalue 1
maxvalue 999999
start with 1;
alter ticket
alter ticket_id set default nextval('ticket_seq');
 