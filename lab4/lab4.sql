/*-------- Report --------
BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)
------------------------
For the final hand-in of the project the following should be handed in:
- EER-diagram as .pdf
- Relational Model as .pdf
- Project code as one file named lab4.sql,
  which should be executable directly without any error
  - Answers to the non code questions as SQL-comments in the lab4.sql file,
      place them at the end of the file
  - An identified secondary index as SQL-comments in the lab4.sql file
    (do not implement it), place at the end of the file
- A file named q10b.sql that is your modified version of Question10MakeBooking.sql
--------------------------------------------------------------------------------
EER-diagram

During the implementation we realized the following and thus made changes
accordingly
1. Our initial entity "Customer" was not needed and only contained unnecessary
    information -> we removed Customer and added the name attribute to the
    Passenger entity
2. We removed PNR and title from Passenger, since these attributes were redundant
3. We removed CVC from credit card, since it was redundant

These changes can be seen in png files on git in the lab4b folder
--------------------------------------------------------------------------------
Q2: Schema
The database is created with the schema in brianAir_schema.sql, which has the
following content: */
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
-- drop table if exists customer cascade;

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
  foreign key(year) references year(year) ON DELETE CASCADE
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
  foreign key(name) references city(name) ON DELETE CASCADE
  /*Airport.name = city.name*/
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
  weekly_flight_id int auto_increment,
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
  resnr int not null,
  nr_of_pass smallint not null,
  passportnr int, -- not null when converting into booking
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

select 'Table set up finished' as 'Message';

/*--------------------------------------------------------------------------------
Q3: Procedures
The database has the procedures shown in brianAir_procedures.sql, which has the
following content:*/
/*
-------- Question 3 --------

BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/
drop procedure if exists addFlight;
drop procedure if exists addRoute;
drop procedure if exists addDestination;
drop procedure if exists addDay;
drop procedure if exists addYear;

delimiter //
create procedure addYear(in year_new int, in profit double(10,3))
  begin
    insert into year(year, profit_factor)
      values(year_new, profit);
  end;
//
delimiter ;

delimiter //
create procedure addDay(in year_new int,
                        in day_new varchar(10),
                        in profit double(10,3))
  begin
    insert into day(day_name, year, weekday_factor)
      values(day_new, year_new, profit);
  end;
//
delimiter ;

delimiter //
create procedure addDestination(in airport_code_new varchar(3),
                                in city_name_new varchar(30),
                                in country_new varchar(30))
begin
  if (not exists (select * from country as c
                  where c.name = country_new))
  then
    -- new country
    insert into country(name)
      values(country_new);
  end if;
  if (not exists (select * from city as c
                  where c.name = city_name_new
                  and c.country = country_new))
  then
     -- new city
    insert into city(name,country)
      values(city_name_new,country_new);
  end if;
  if (not exists (select * from airport as a
                  where a.code = airport_code_new))
  then
    -- new airport
    insert into airport(code,name)
      values(airport_code_new,city_name_new);
  end if;
end;
//
delimiter ;

delimiter //
create procedure addRoute(in dep_airport_code varchar(3),
                          in arr_airport_code varchar(3),
                          in route_year int,
                          in route_price double(10,3))
begin
  -- catches adding duplicate route
    if (not exists (select * from route r
      where r.year = route_year
      and dep_airport = dep_airport_code
      and arr_airport = arr_airport_code))
    then
    -- foreign key constraint catches nonexisting years and airports
    -- add route
      insert into route(dep_airport,arr_airport,year,price)
        values(dep_airport_code,arr_airport_code,route_year,route_price);
    end if;
end;
//
delimiter ;

delimiter //
create procedure addFlight(in dep_airport_code varchar(3),
                            in arr_airport_code varchar(3),
                            in flight_year int,
                            in flight_day varchar(10),
                            in flight_dep_time time)
begin
  -- declare local variables
    declare flight_route_id int;
    declare weeknr int;
    declare flight_id int;

 -- catches nonexisting years, route
  if (exists (select * from day d where d.year = flight_year)
      and exists (select * from route r
                  where r.dep_airport = dep_airport_code
                  and r.arr_airport = arr_airport_code
                  and r.year = flight_year))
  then
    -- flight route id
    select id from route r
              where r.dep_airport = dep_airport_code
              and r.arr_airport = arr_airport_code
              and r.year = flight_year
              into flight_route_id;

    if (not exists (select * from weekly_schedule w
                  where w.year = flight_year
                  and w.day = flight_day
                  and w.dep_time = flight_dep_time
                  and w.route_id = flight_route_id)) -- catches already added record
    then
     -- add weekly flight
      insert into weekly_schedule(year,day,dep_time,route_id)
        values(flight_year,flight_day,flight_dep_time,flight_route_id);


    select 1 into weeknr;
    select weekly_flight_id from weekly_schedule w
                      where w.year = flight_year
                      and w.day = flight_day
                      and w.dep_time = flight_dep_time
                      and w.route_id = flight_route_id
                      into flight_id;
     -- add 52 flights
    52flights: while weeknr <= 52 do
      insert into flight(week,weekly_flight_id)
        values(weeknr,flight_id);
        set weeknr = weeknr + 1; -- had issues with new. and old.
    end while 52flights;
    end if;
  end if;
end;
//
delimiter ;

/*--------------------------------------------------------------------------------
Q4: functions
The database has the functions shown in brianAir_functions.sql, which has the
following content.

Here it is necessary to address the result in Question6.sql
According to the instruction we should get “Query Ok, 1 row affected” as output
in Question6.sql, but with our code we can for example get "4 rows affected".
The reason is that we do calculations with variables that we have declared and
each “select ...into ...” ends up being counted as a row effected.
As a result it may look like more rows in relations are changed than there
should be, but this is not the case.

This can for example be seen in the output for task 10 in Question6.sql.
*/
/*
-------- Question 4 --------

BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/

drop function if exists calculatePrice;
drop function if exists calculateFreeSeats;

delimiter //
-- calculates number of free seats
create function calculateFreeSeats(flightnumber int) returns int
  begin
    declare free_seats int;
    declare occupied_seats int;
    -- occupied seat is the no of tickets generated for a flight -> 1 row affected
    select count(*) from ticket t, flight f, reservation r, booking b
                          where flightnumber = f.flightnr
                          and f.flightnr = r.flightnr
                          and  r.resnr = b.book_id
                          and b.book_id = t.book_id
                          into occupied_seats;
    -- calculate nr of free seats -> 1 row affected
    select (40 - occupied_seats) into free_seats;
    return free_seats;
  end;
//
delimiter ;

delimiter //
-- calculates the price of the next available seat
create function calculatePrice(flightnumber int) returns double(10,3)
  begin
    declare price_next_seat double(10,3);
    declare route_price double(10,3);
    declare profit_weekday double(10,3);
    declare booked_passengers int;
    declare profit_year double(10,3);

    select price from route r, weekly_schedule w, flight f
                  where w.route_id = r.id
                  and w.weekly_flight_id = f.weekly_flight_id
                  and f.flightnr = flightnumber
                  into route_price;
    select weekday_factor from day d, weekly_schedule w, flight f
                          where d.day_name = w.day
                          and d.year = w.year
                          and w.weekly_flight_id = f.weekly_flight_id
                          and f.flightnr = flightnumber
                          into profit_weekday;
   set booked_passengers = (40 - calculateFreeSeats(flightnumber)); -- ok?
    select profit_factor from year y, day d, weekly_schedule w, flight f
                          where y.year = d.year
                          and d.day_name = w.day
                          and d.year = w.year
                          and w.weekly_flight_id = f.weekly_flight_id
                          and f.flightnr = flightnumber
                          into profit_year;
   set price_next_seat = route_price * profit_weekday * (booked_passengers+1)/40 * profit_year;
    return price_next_seat;
  end;
//
delimiter ;

/*--------------------------------------------------------------------------------
Q5: trigger
The database has the trigger shown in brianAir_triggers.sql, which has the
following content:*/
/*
-------- Question 5 --------

BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/
drop trigger if exists issueTicket;

delimiter //
-- create tickets after booking finished
create trigger issueTicket after insert on booking
  for each row
  begin
    declare ticket_number int;
    declare passportnumber int;
    declare passenger_without_ticket int;

    -- find amount of tickets to generate for the added booking
    select count(*) from passengers_res pa, booking b
    where pa.resnr = b.book_id and b.book_id = new.book_id into passenger_without_ticket;

    -- issue ticket for every passenger in booking
   while passenger_without_ticket >= 1 do
    -- generate ticket number
    select floor(rand()*(100000000-9999999+1))+9999999 into ticket_number;
    -- get a passport number of person without ticket
    select passportnr from passengers_res pa
    where pa.resnr = new.book_id and pa.passportnr not in
    (select passportnr from ticket t
      where t.book_id = new.book_id) limit 1
      into passportnumber;


      insert into ticket(ticketnr, passportnr, book_id)
        values(ticket_number, passportnumber, new.book_id);

    -- updating counter value
    set passenger_without_ticket = passenger_without_ticket - 1;
    end while;

  end;

  //
  delimiter ;

/*--------------------------------------------------------------------------------
Q5: trigger
The database has the trigger shown in brianAir_triggers.sql, which has the
following content.
The trigger must be re-"source"-ed every time the schema is source-ed*/
/*
-------- Question 5 --------

BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/
drop trigger if exists issueTicket;

delimiter //
-- create tickets after booking finished
create trigger issueTicket after insert on booking
  for each row
  begin
    declare ticket_number int;
    declare passportnumber int;
    declare passenger_without_ticket int;

    -- find amount of tickets to generate for the added booking
    select count(*) from passengers_res pa, booking b
    where pa.resnr = b.book_id and b.book_id = new.book_id into passenger_without_ticket;

    -- issue ticket for every passenger in booking
   while passenger_without_ticket >= 1 do
    -- generate ticket number
    select floor(rand()*(100000000-9999999+1))+9999999 into ticket_number;
    -- get a passport number of person without ticket
    select passportnr from passengers_res pa
    where pa.resnr = new.book_id and pa.passportnr not in
    (select passportnr from ticket t
      where t.book_id = new.book_id) limit 1
      into passportnumber;


      insert into ticket(ticketnr, passportnr, book_id)
        values(ticket_number, passportnumber, new.book_id);

    -- updating counter value
    set passenger_without_ticket = passenger_without_ticket - 1;
    end while;

  end;

  //
  delimiter ;

/*--------------------------------------------------------------------------------
Q6: front-end procedures
The database has the front-end procedures shown in brianAir_frontend.sql, which
has the following content.*/
/*
-------- Question 6 --------

BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/
drop procedure if exists addPayment;
drop procedure if exists addContact;
drop procedure if exists addPassenger;
drop procedure if exists addReservation;

delimiter //
create procedure addReservation(in dep_airport_code varchar(3),
                                in arr_airport_code varchar(3),
                                in flight_year int,
                                in weeknr int,
                                in day varchar(10),
                                in flight_dep_time time,
                                in nr_of_passengers int,
                                out output_resnr int)
begin
-- declare variables
 declare nr_free_seats int;
 declare flightnumber int;
 declare reservationnr int;

-- check if flight exists
  if(exists (select * from weekly_schedule w, flight f, route r
                  where w.year = flight_year
                  and w.day = day
                  and f.week = weeknr
                  and w.weekly_flight_id = f.weekly_flight_id
                  and w.dep_time = flight_dep_time
                  and w.route_id = r.id
                  and r.dep_airport = dep_airport_code
                  and r.arr_airport = arr_airport_code))
  then
  -- calculate flight number -> 1 row affected
    select flightnr from flight f, weekly_schedule w, route r
                          where f.week = weeknr
                          and f.weekly_flight_id = w.weekly_flight_id
                          and w.year = flight_year
                          and w.day = day
                          and w.dep_time = flight_dep_time
                          and w.route_id = r.id
                          and r.dep_airport = dep_airport_code
                          and r.arr_airport = arr_airport_code
                          into flightnumber;
    -- calculate free seats on flight -> 2 + 1 rows affected
    select calculateFreeSeats(flightnumber) into nr_free_seats;

     if(nr_free_seats >= nr_of_passengers)
     then
      -- create reservation
      select floor(rand()*(100000000-9999999+1))+9999999 into reservationnr;
      insert into reservation(resnr, nr_of_pass, flightnr)
        values(reservationnr, nr_of_passengers, flightnumber);
        select reservationnr into output_resnr;
     else
      select "There are not enough seats available on the chosen flight" as "Message";
     end if;
  else
    select "There exist no flight for the given route, date and time" as "Message";
  end if;
end;
//
delimiter ;

delimiter //
create procedure addPassenger(in reservationnr int,
                              in passportnumber int,
                              in passenger_name varchar(30))
begin
-- check reservation number valid or not
if(exists (select * from reservation r where r.resnr = reservationnr))
then
  -- preventing adding people if already payed
  if(not exists (select * from booking where book_id = reservationnr))
  then
    -- add passenger to passenger database if not registered
    if(not exists (select * from passenger p
                    where p.passportnr = passportnumber
                    and p.name = passenger_name))
    then
      insert into passenger(passportnr, name)
        values(passportnumber, passenger_name);
    end if;
    -- add passenger to passenger res if not added
    if(not exists (select * from passengers_res p
                    where p.resnr = reservationnr
                    and p.passportnr = passportnumber))
    then
      insert into passengers_res(resnr, passportnr)
        values(reservationnr, passportnumber);
    else
      select "Passenger not added to passengers_res" as "Message";
    end if;
  else
    select "The booking has already been payed and no futher passengers can be added"
    as "Message";
  end if;
else
  select "The given reservation number does not exist" as "Message";
end if;
end;
//
delimiter ;

delimiter //
create procedure addContact(in reservationnr int,
                            in passportnumber int,
                            in contact_email varchar(30),
                            in contact_phone bigint)
begin
-- check if reservation number exists
if(exists (select * from reservation r where r.resnr = reservationnr))
then
  -- check if contact is passenger
  if(exists (select * from passengers_res pr, reservation r
              where pr.passportnr = passportnumber
              and pr.resnr = r.resnr
              and r.resnr = reservationnr))
  then
    -- if contact not already exists
    if(not exists (select * from contact c
                    where passportnr = passportnumber))
    then
      -- add contact details
        insert into contact(passportnr, email, phone)
          values(passportnumber, contact_email, contact_phone);
    end if;
  -- add contact to reservation
    update reservation r
    set r.passportnr = passportnumber
    where r.resnr = reservationnr;
  else
    select "The person is not a passenger of the reservation" as "Message";
  end if;
else
  select "The given reservation number does not exist" as "Message";
end if;
end;
//
delimiter ;

delimiter //
create procedure addPayment(in reservationnr int,
                            in cardholder varchar(30),
                            in cardnumber bigint)
begin
  -- declaration
  declare available_seats int;
  declare needed_seats int;
  declare flightnumber int;
  declare price double(10,3);

  -- flightnumer for reservation
  select flightnr from reservation r
  where r.resnr = reservationnr
  into flightnumber;

  -- available seats on plane
  select calculateFreeSeats(flightnumber) into available_seats;
  -- 10c to break the isolation property
   SELECT sleep(5);

  -- passengers added to reservation
  select count(*) from passengers_res p, reservation r
  where p.resnr = r.resnr
  and r.resnr = reservationnr
  into needed_seats;
  -- check if correct reservation number
  if(exists (select * from reservation r where r.resnr = reservationnr))
  then
    -- check if reservation has a contact
    if(exists (select * from reservation r where r.resnr = reservationnr
                                            and r.passportnr is not null))
    then
      -- check if enough available seats on flight
      if(available_seats >= needed_seats)
      then
      -- add credit card if not added
        if(not exists (select * from credit_card c where c.cardnr = cardnumber))
        then
          insert into credit_card(cardnr, holder_name)
            values(cardnumber, cardholder);
        end if;
      -- price for tickets
        select (calculatePrice(flightnumber))* needed_seats into price;
        --  Create booking + add payment
        insert into booking(book_id, tot_price, cardnr)
          values(reservationnr, price, cardnumber);

        -- generate tickets!!!

      else
        select "There are not enough seats available on the flight anymore, deleting reservation"
        as "Message";
          -- delete reservation -> cascade delete reservation from passengers
          delete from reservation where resnr = reservationnr;
          -- delete passengers only in passenger and not in pass_res
          delete from passenger where passportnr not in
            (select passportnr from passengers_res);
      end if;
    else
      select "The reservation has no contact yet" as "Message";
    end if;
  else
    select "The given reservation number does not exist" as "Message";
  end if;
end;
//
delimiter ;

/*--------------------------------------------------------------------------------
Q7: view
The database has the view shown in brianAir_view.sql, which
has the following content:*/
/*
-------- Question 7 --------

BrianAir procedures by
TDDD12_A5
Ingrid Wendin (ingwe018)
Per Bark (perba583)

*/

drop view if exists allFlights;

create view allFlights as

  select a1.name as departure_city_name,
  a2.name as destination_city_name,
  w.dep_time as departure_time,
  w.day as departure_day,
  f.week as departure_week,
  w.year as departure_year,
  calculateFreeSeats((f.flightnr)) as nr_of_free_seats,
  calculatePrice((f.flightnr)) as current_price_per_seat
  from route r left join airport a1 on (r.dep_airport = a1.code)
  left join airport a2 on (r.arr_airport = a2.code)
  left join weekly_schedule w on (w.route_id = r.id)
  left join flight f on (f.weekly_flight_id = w.weekly_flight_id)
  left join flight f2 on (f2.flightnr = f.flightnr);

/*--------------------------------------------------------------------------------
Q8:
The answers to the following theoretical questions
a)How can you protect the credit card information in the database from hackers?
    The best practice for storing sensitive information such as passwords or
  credit card details is to hash the data and use salt to prevent the hacker
  from comparing hashes after a security breach.

b)Give three advantages of using stored procedures in the database (and thereby
 execute them on the server) instead of writing the same functions in the
 front-end of the system (in for example java-script on a web-page)?
  1. The issue with java-script running in a web-page is that it can be
  circumvented by proxies, for example ZAP. Thus, if the database control is
  done through a user controlled entity such as a web-page, then the database
  has an open vulnerability.

  2. Server-side procedures also limit the tools the attacker can use to access
  the data to a set number that has been decided by the creator of the database.
  This means that with carefully chosen procedures, no modifications can be made
  to the database other than the ones allowed. Selected views also limit the
  amount of sensitive data that can be accessed.

  3. Server-side procedures are also possible to grant access to, to different
  users while not grant to other. It is thus possible to have different access
  rights depending on what person is logged in on the database. This allowes for
  better control, but also enables grant misstakes.
*/
/*--------------------------------------------------------------------------------
Q9:
Open two MySQL sessions. We call one of them A and the other one B.
Write START TRANSACTION; in both terminals.
  Before "start transaction" sourcing content of Question3.sql in A makes B also
  able to see and interact with the changes.
a)In session A, add a new reservation.
b)Is this reservation visible in session B? Why? Why not?
    The reservation added to A is not visible in B after "start transaction" has
    been written in both terminals. The reason is that the change in A has not
    been commited yet, which means that there is a read lock on the data,
    preventing B from reading it.
c)What happens if you try to modify the reservation from A in B?
  Explain what happens and why this happens and how this relates to the concept
  of isolation of transactions.
   When running "addPassenger(80860947,1,"Frodo Baggins");" in B the terminal
   stops and after a while (around 1 minute) outputs the following error message:
      ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
  This error is due to there not only being a read lock on the data point, but
  also a write lock on it. When B tries to write to the reservation, it has to
  wait for A to return its lock, but because A does not commit the change, the
  query in B is aborted, since it is the youngest of the two.

  When A has commited the change, then B can run the query again with successful
  result. This change has to be commited by B, in order for A to read the added
  passenger.

  The locks exist in order to make sure that the isolation quality of the
  database is maintained. This means that even if several queries are executed
  in paralell, the database should respond as if they were all executed
  sequentially. This is in order to make sure that no data is lost between the
  execution of operations in two different transactions or that unwanted changes
  are done to the database due to problematic read-write sequences.
*/
/*--------------------------------------------------------------------------------
Q10:
a) Did overbooking occur when the scripts were executed?
  If so, why? If not, why not?
    An overbooking did not occur. The terminal B had its transaction denied and
    reservation deleted. After both finished, there were 19 seats available.

b) Can an overbooking theoretically occur?
  If an overbooking is possible, in what order must the lines of code in your
  procedures/functions be executed.
    An overbooking should be able to occur during the "right" circumstances
    since there is a gap in time between calculating the number of free seats
    and comparing it to needed seats to check if the amount of seats is enough
    to allow the booking.
    Theoretically it should be possible for A to read the amount of available
    seats, B to read the same and A to issue tickets -> cause available
    seats to decrease, followed by B issuing more tickets -> cause available
    seats to decrease to a negative value.
    In this case B has bypassed the ckeck by calculating number of free seats
    before A has had the chance to enter the if-statement and do the comparison
    followed by updating the amount of ticket. This is possible since
    MySQL has default to treat each operation as its own TA, thus making the
    otherwise prevented A-B read-write example above possible, because
    with four different TA:s the locks are returened when the operation finished
    and not after the write.

c)Try to make the theoretical case occur in reality by simulating that multiple
  sessions call the procedure at the same time
    It was possible to break the isolation by inserting a Sleep(5) between the
    calculation of available seats and the if-clause doing the control if the
    available seats were many enough to allow the booking (row 694). B had -2
    seats left, C had -19 seats left and D had -44 seats left after running the
    booking in four terminals in order A,B,C,D.

d) Modify the testscripts so that overbookings are no longer possible using
  (some of) the commands START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK TABLES,
  ROLLBACK, SAVEPOINT, and SELECT...FOR UPDATE.
    It was possible to solve the issue with the sleep(5) by starting a
    transaction before the addPayment is called and ending it afterwards.
    The addPayment is where the problem occurs, which makes it possible to
    remove the problem by forcing all operations in the addPayment to become
    one transaction.
    It would probably also be possible to solve the problem by adding write
    locks to all tables involved in the addPayment, and since MySQL forces all
    tables to be locked if one is, thus the other tables involved in the
    procedures should get read locks

/*--------------------------------------------------------------------------------
Secondary index

In an airport setting it is not hard to imagine that the system will have to be
able to look up a person's ticket number when only having the passenger number.
As it is now, the ticket relation is ordered by ticketnr, thus making the search
slow when using passportnr as the identifier.
By creating a non-ordering secondary index using non-key field passportnr and
one extra redirection level to handle the non-key issue (having multiple records
with the same passportnr), the search time to find the ticket number will be
decreased: This is because the index data file can be searched using binary
search instead of linear search.   
*/
