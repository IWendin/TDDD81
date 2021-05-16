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
