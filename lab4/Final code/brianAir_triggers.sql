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
/*
-- control
    select floor(rand()*(100000000-9999999+1))+9999999 into ticket_number;
    insert into ticket(ticketnr, passportnr, book_id)
      values(ticket_number, passenger_without_ticket, new.book_id);
*/
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
