/*
-------- Question 2 --------

BrianAir database schema by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/

drop table if exists ticket cascade;
drop table if exists booking cascade;
drop table if exists passengers_res cascade;
drop table if exists reservation cascade;
drop table if exists credit_card cascade;

drop table if exists contact cascade;
drop table if exists passenger cascade;

drop table if exists flight cascade;
drop table if exists weekly_schedule cascade;

drop table if exists route cascade;
drop table if exists airport cascade;
drop table if exists city cascade;
drop table if exists country cascade;

drop table if exists day cascade;
drop table if exists year cascade;

select 'Setting up BrianAir database tables' as 'Message';

create table year (
  year int not null,
  profit_factor double(10,3) not null,
  primary key(year)
);

create table day (
  day_name varchar(10) not null,
  year int not null,
  weekday_factor double(10,3) not null,
  primary key(day_name, year),
  foreign key(year) references year(year) ON DELETE CASCADE /* confirmed: can only create day for an existing year */
);

create table country (
  name varchar(30) not null,
  primary key(name)
);

create table city (
  name varchar(30) not null,
  country varchar(30) not null,
  primary key(name, country),
  foreign key(country) references country(name) ON DELETE CASCADE
);

create table airport (
  code varchar(3) not null,
  name varchar(30) not null,
  primary key(code),
  foreign key(name) references city(name) ON DELETE CASCADE /*Airport.name = city.name*/
);

create table route (
  id int not null auto_increment,
  dep_airport varchar(3) not null,
  arr_airport varchar(3) not null,
  year int not null,
  price double(10,3) not null,
  primary key(id),
  foreign key(dep_airport) references airport(code) ON DELETE CASCADE,
  foreign key(arr_airport) references airport(code) ON DELETE CASCADE,
  foreign key(year) references year(year) ON DELETE CASCADE
);

create table weekly_schedule (
  weekly_flight_id int auto_increment, -- check if random needed!
  year int not null,
  day varchar(10) not null,
  dep_time time not null,
  route_id int not null,
  primary key(weekly_flight_id),
  foreign key(year) references day(year) ON DELETE CASCADE,
  foreign key(day) references day(day_name) ON DELETE CASCADE,
  foreign key(route_id) references route(id) ON DELETE CASCADE
);

create table flight (
  flightnr int not null auto_increment,
  week smallint not null,
  weekly_flight_id int not null,
  primary key(flightnr),
  foreign key(weekly_flight_id) references weekly_schedule(weekly_flight_id) ON DELETE CASCADE
);

create table passenger (
  passportnr int not null,
  name varchar(30) not null, -- removed cusomer moved name to passenger
  primary key(passportnr)
);

create table contact (
  passportnr int not null,
  email varchar(30) not null,
  phone bigint not null,
  primary key(passportnr),
  foreign key(passportnr) references passenger(passportnr) ON DELETE CASCADE
);

create table credit_card (
  cardnr bigint not null,
  holder_name varchar(30) not null,
  primary key(cardnr)
);

create table reservation (
  resnr int not null, -- auto_increment, /*The reservation is confirmed by issuing a unique, unguessable, reservation number that is needed to finish the booking*/
  nr_of_pass smallint not null,
  passportnr int, -- not null, not null when converting into booking
  flightnr int not null,
  primary key(resnr),
  foreign key(passportnr) references contact(passportnr) ON DELETE CASCADE,
  foreign key(flightnr) references flight(flightnr) ON DELETE CASCADE
);

create table passengers_res (
  resnr int not null,
  passportnr int not null,
  primary key(resnr,passportnr),
  foreign key(resnr) references reservation(resnr) ON DELETE CASCADE,
  foreign key(passportnr) references passenger(passportnr) ON DELETE CASCADE
);

create table booking (
  book_id int not null,
  tot_price double(10,3) not null,
  cardnr bigint not null,
  primary key(book_id),
  foreign key(book_id) references reservation(resnr) ON DELETE CASCADE,
  foreign key(cardnr) references credit_card(cardnr) ON DELETE CASCADE
);

create table ticket (
  ticketnr int not null,
  passportnr int not null,
  book_id int not null,
  primary key(ticketnr),
  foreign key(passportnr) references passenger(passportnr) ON DELETE CASCADE,
  foreign key(book_id) references booking(book_id) ON DELETE CASCADE
);

select 'Table set up finished' as 'Message'
