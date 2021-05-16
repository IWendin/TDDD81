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
