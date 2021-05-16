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
