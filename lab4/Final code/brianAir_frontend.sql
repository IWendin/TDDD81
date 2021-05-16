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
/* -- can add more than the stated nr of passengers?
--declaration
declare available_space int;
declare occupied_space int;
-- passengers to be added in reservation
select nr_of_pass from reservation r
where r.resnr = reservationnr
into available_space;
-- passengers already added to reservation
select count(*) from passengers_res p, reservation r
where p.resnr = r.resnr
and r.resnr = reservationnr
into occupied_space;
*/

-- check reservation number valid or not
if(exists (select * from reservation r where r.resnr = reservationnr))
then
/*
  -- add passenger to reservation if room
  if(available_space > occupied_space)
  then
  */
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
