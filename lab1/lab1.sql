/*Lab1 The Johnson Brother's database

Ingrid Wendin ingwe018, Per Bark perba583*/

DROP TABLE IF EXISTS iwitem CASCADE;
DROP VIEW IF EXISTS avgitemprice CASCADE;
DROP VIEW IF EXISTS debit_sum CASCADE;
DROP VIEW IF EXISTS debit_sum2 CASCADE;
DROP VIEW IF EXISTS jbsale_supply CASCADE;

SOURCE company_schema.sql;
SOURCE company_data.sql;



/*-----------------------------------------------------------------------------*/
/*Q1 Lists all employees in the company (their data and not only their names).*/

select * from jbemployee;
/*
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0.00 sec)
*/
/*-----------------------------------------------------------------------------*/
/*Q2 Lists the name of all departments in alphabetical order.
Since there are several departments with the same name but different
id (making them unique), there are thus multiples of some names in the list
*/

select name from jbdept order by name;
/*
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
*/
-- If only distinct names are wanted:
-- select distinct name from jbdept order by name;

/*
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
+------------------+
*/
/*-----------------------------------------------------------------------------*/
/*Q3 Lists all parts that are not in store, i.e. quantity on hand = 0 */

select p.name from jbparts as p where p.qoh=0;
/*
+-------------------+
| name              |
+-------------------+
| card reader       |
| card punch        |
| paper tape reader |
| paper tape punch  |
+-------------------+
*/
/*-----------------------------------------------------------------------------*/
/*Q4 Lists all employees have a salary between 9000 (included) and 10000
(included)? */

select e.name from jbemployee as e where e.salary between 9000 and 10000;
/*
+----------------+
| name           |
+----------------+
| Edwards, Peter |
| Smythe, Carol  |
| Williams, Judy |
| Thomas, Tom    |
+----------------+
*/
/*-----------------------------------------------------------------------------*/
/*Q5 Lists the age of the employee when he/she started working at the company*/

select e.name, (e.startyear - e.birthyear) as 'Age when hired' from jbemployee e;

/*
+--------------------+----------------+
| name               | Age when hired |
+--------------------+----------------+
| Ross, Stanley      |             18 |
| Ross, Stuart       |              1 |
| Edwards, Peter     |             30 |
| Thompson, Bob      |             40 |
| Smythe, Carol      |             38 |
| Hayes, Evelyn      |             32 |
| Evans, Michael     |             22 |
| Raveen, Lemont     |             24 |
| James, Mary        |             49 |
| Williams, Judy     |             34 |
| Thomas, Tom        |             21 |
| Jones, Tim         |             20 |
| Bullock, J.D.      |              0 |
| Collins, Joanne    |             21 |
| Brunet, Paul C.    |             21 |
| Schmidt, Herman    |             20 |
| Iwano, Masahiro    |             26 |
| Smith, Paul        |             21 |
| Onstad, Richard    |             19 |
| Zugnoni, Arthur A. |             21 |
| Choy, Wanda        |             23 |
| Wallace, Maggie J. |             19 |
| Bailey, Chas M.    |             19 |
| Bono, Sonny        |             24 |
| Schwarz, Jason B.  |             15 |
+--------------------+----------------+
25 rows in set (0.00 sec)

Mr JD seems to have been added into the company when he was born.
*/
/*-----------------------------------------------------------------------------*/
/*Q6 Lists all employees that have a last name ending with son?*/

select e.name from jbemployee as e where e.name like '%son,%';
/*
+---------------+
| name          |
+---------------+
| Thompson, Bob |
+---------------+

Only Bob has a surname ending with 'son'.
*/
/*-----------------------------------------------------------------------------*/
/*Q7 Lists all items that have been delivered by the supplier Fisher-Price
(with sub-query) */

select i.name from jbitem as i
where i.supplier in
(select s.id
  from jbsupplier as s
  where s.name = 'Fisher-Price'
);
/*
+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
*/
/*-----------------------------------------------------------------------------*/
/*Q8 Lists all items that have been delivered by the supplier Fisher-Price
(without sub-query) */

select i.name from jbitem as i, jbsupplier as s
where s.name = 'Fisher-Price' and s.id = i.supplier;

/*
+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
*/
/*----------------------------------------------------------------------------*/
/*Q9 Displays all cities that have suppliers located in them.
Formulated using a subquery in the where-clause.*/

select c.name from jbcity as c
where c.id in (select s.city from jbsupplier as s );
/*
+----------------+
| name           |
+----------------+
| Amherst        |
| Boston         |
| New York       |
| White Plains   |
| Hickville      |
| Atlanta        |
| Madison        |
| Paxton         |
| Dallas         |
| Denver         |
| Salt Lake City |
| Los Angeles    |
| San Diego      |
| San Francisco  |
| Seattle        |
+----------------+
15 rows in set (0.00 sec)
*/

/*----------------------------------------------------------------------------*/
/*Q10 Displays the name and color of the parts
that are heavier than a card reader*/

select name, color
from jbparts
where weight > (select weight
                  from jbparts
                  where name = 'card reader'
                );
/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
*/
/*----------------------------------------------------------------------------*/
/*Q11 Displays the name and color of the parts
that are heavier than a card reader using double reference*/

select p.name, p.color from jbparts as p, jbparts as p2
where p.weight > p2.weight and p2.name = 'card reader';
/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
*/
/*----------------------------------------------------------------------------*/
/*Q12 Displays the average weight of the black parts*/

select avg(p.weight) as 'avg weight of black parts' from jbparts as p where p.color = 'black';
/*
+---------------------------+
| avg weight of black parts |
+---------------------------+
|                  347.2500 |
+---------------------------+

*/
/*----------------------------------------------------------------------------*/
/*Q13 Displays the total weight of all parts that each supplier in Massachusetts
(Mass) has delivered.*/

select s.name, sum(p.weight*s2.quan) as 'tot weight of delivered parts'
from jbsupplier as s, jbparts as p, jbcity as c, jbsupply as s2
where c.state = 'Mass' and c.id = s.city and p.id = s2.part and s.id = s2.supplier
group by s.name;
/*
+--------------+-------------------------------+
| name         | tot weight of delivered parts |
+--------------+-------------------------------+
| DEC          |                          3120 |
| Fisher-Price |                       1135000 |
+--------------+-------------------------------+
*/
/*----------------------------------------------------------------------------*/
/*Q14 Creates a new relation (a table), with the same attributes as the table
items, then fills the table with all items that cost less than the average
price for items.*/


create table iwitem (
  id int primary key,
  name varchar(20) not null,
  dept int not null,
  price int not null,
  qoh int not null,
  supplier int not null,
  foreign key (dept) references jbdept(id),
  foreign key (supplier) references jbsupplier(id),
  check (price >= 0 and qoh >= 0)
);


-- Query OK, 0 rows affected (0.09 sec)

/*control
select avg(price) from jbitem;
+------------+
| avg(price) |
+------------+
|  1138.8000 |
+------------+
*/

insert into iwitem (id, name, dept, price, qoh, supplier)
select id, name, dept, price, qoh, supplier
from jbitem
where id in (select id
              from jbitem
              where price < (select avg(price)
                              from jbitem)
            );

-- Query OK, 14 rows affected (0.04 sec)

select * from iwitem;

/*
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.00 sec)
*/
/*----------------------------------------------------------------------------*/
/*Q15 Creates a view that contains the items that cost less than the average
price for items. */


create view avgitemprice as select * from jbitem
where price < (select avg(price) from jbitem);

-- Query OK, 0 rows affected (0.03 sec)

select * from avgitemprice;

/*
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.00 sec)
*/

/*----------------------------------------------------------------------------*/
/*Q16 What is the difference between a table and a view? One is static and
the other is dynamic. Which is which and what do we mean by static respectively
dynamic?

A table is static and a view is dynamic. Static means that the values have to
be uppdated manually, while the view being dynamic means that its values will
automatically be updated with the new values, once reloaded, after the table it
is based on is updated (assuming the change happens in the attributes that are
included in the view).
*/
/*----------------------------------------------------------------------------*/
/*Q17 Creates a view that calculates the total cost of each debit, by considering
 price and quantity of each bought item. (Using implicit join notation) */


create view debit_sum as select s.debit as 'debit ID',
sum(s.quantity*i.price) as 'total cost'
from jbsale s, jbitem i
where s.item = i.id group by s.debit;

-- Query OK, 0 rows affected (0.05 sec)

select * from debit_sum;

/*
+----------+------------+
| debit ID | total cost |
+----------+------------+
|   100581 |       2050 |
|   100582 |       1000 |
|   100586 |      13446 |
|   100592 |        650 |
|   100593 |        430 |
|   100594 |       3295 |
+----------+------------+
6 rows in set (0.00 sec)
*/
 /*----------------------------------------------------------------------------*/
 /*Q18 Doing the same as in (17), using only the explicit join notation,
 i.e. using only left, right or inner joins and no join condition in a where
 clause.

 The sjbsale s left outer join jbitem i on s.item = i.id takes every tuple in
 sale (left) and pairs it with the tuple(s) in item (right) where the condition
 item=id is met (and creates NULL:s where a match is not possible to be made).
 This means that no null values will appear when we select and display s.debit,
 since every tuple in sale could be matched with a tuple in item.
 Swapping place and direction using jbitem i right outer join jbsale s on
 s.item = i.id also works.

 Inner join on s.item = i.id is also possible since only the tuples in both
 tables that share id will be combined, thus only creating valid combinations
 and values.

 select s.debit as 'debit ID', sum(s.quantity*i.price) as 'total cost'
 from jbsale s inner join jbitem i
 on s.item = i.id
 group by s.debit;


 Not possible, is the sale right outer join item on item = id which takes
 every tuple in item and matches it with every tuple in sale where item = id and
 fills debit item and quantity with NULL values when no mach is found in sale
 table. There are several matches not possible to be made, for example id = 11
 and id = 165 do not exist in the sale table and hence will have nulls for
 debit, item and quantity in the final table. This results in a debit ID NULL,
 total cost NULL when grouping to calculate the sum of cost.
*/

-- The code:

create view debit_sum2 as
select s.debit as 'debit ID', sum(s.quantity*i.price) as 'total cost'
from jbsale s inner join jbitem i on s.item = i.id
group by s.debit;

-- Query OK, 0 rows affected (0.04 sec)

select * from debit_sum2;

 /*
+----------+------------+
| debit ID | total cost |
+----------+------------+
|   100581 |       2050 |
|   100582 |       1000 |
|   100586 |      13446 |
|   100592 |        650 |
|   100593 |        430 |
|   100594 |       3295 |
+----------+------------+
6 rows in set (0.00 sec)
*/
 /*----------------------------------------------------------------------------*/
 /*Q19 Oh no! An earthquake!
 a)Removes all suppliers in Los Angeles from the table jbsupplier.
 This will not work right away (you will receive error code 23000) which you
 will have to solve by deleting some other related tuples. Delete only using
 the constant "Los Angeles"*/

 delete from jbsale
 where item in (select i.id
                from jbitem i
                where i.supplier in (select s.id
                                      from jbsupplier s left outer join jbcity c on s.city=c.id
                                      where c.name ='Los Angeles'
                                    )
                );

-- Query OK, 1 row affected (0.00 sec)

delete from jbitem
where supplier in (select s.id
                    from jbsupplier s left outer join jbcity c on s.city=c.id
                    where c.name ='Los Angeles'
                  );

-- Query OK, 2 rows affected (0.00 sec)
-- remove was ok -> no need to delete in jbdebit

delete from iwitem
where supplier in (select s.id
                    from jbsupplier s left outer join jbcity c on s.city=c.id
                    where c.name ='Los Angeles'
                  );

-- Query OK, 1 row affected (0.03 sec)

delete from jbsupplier
where id in (select s.id
              from jbsupplier s left outer join jbcity c on s.city=c.id
              where c.name ='Los Angeles'
            );
-- Query OK, 1 row affected (0.01 sec)

-- Control:
select *
from jbsupplier s left outer join jbcity c on s.city=c.id
where c.name ='Los Angeles';

-- Empty set (0.00 sec)

-- The supplier(s) is (are) now deleted


 /*b)Explain what you did and why

 Koret is the only supplier in Los Angeles and has to be removed. The jbsupplier
 table is referenced in jbsupply (id -> =supplier as foreign key) and in jbitem
 (id -> =supplier as foreign key) and in iwitem (id -> supplier as foreign key).
 When checking the tables Koret only delivers items and only 2 tuples will have
 to be deleted in jbitem and 1 tuple in iwitem.
 item in jbsale references jbitems and id in jbdebit references
jbsale and these had 1 tuple each to be removed if necessary.

We checked to see if delete cascade was on with
select * from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
where DELETE_RULE ='CASCADE'
and got empty set -> We had to remove the tuples maunually. If We're not allowed to
change the setting to on delete cascade.

select * from jbitem
where supplier in (select s.id
                   from jbsupplier s left outer join jbcity c on s.city=c.id
                   where c.name ='Los Angeles'
                 );
-- these will have to be removed
+-----+-----------+------+-------+------+----------+
| id  | name      | dept | price | qoh  | supplier |
+-----+-----------+------+-------+------+----------+
|  26 | Earrings  |   14 |  1000 |   20 |      199 |
| 115 | Gold Ring |   14 |  4995 |   10 |      199 |
+-----+-----------+------+-------+------+----------+

but
delete from jbitem where supplier in (select s.id
                                    from jbsupplier s left outer join jbcity c on s.city=c.id
                                    where c.name ='Los Angeles'
                                  );
gets error with reference to jbsale

select * from jbsale sa where sa.item in (select i.id
                                          from jbitem i
                                          where supplier in (select s.id
                                                            from jbsupplier s left outer join jbcity c on s.city=c.id
                                                            where c.name ='Los Angeles'
                                                          )
                                          );
This will have to be removed
+--------+------+----------+
| debit  | item | quantity |
+--------+------+----------+
| 100582 |   26 |        1 |
+--------+------+----------+

-- remove in jbsale was ok -> no need to delete in jbdebit

In iwitem there is only 1 tuple to be removed:
select * from iwitem
where supplier in (select s.id from jbsupplier s left outer join jbcity c on s.city=c.id
                  where c.name ='Los Angeles'
                );
+----+----------+------+-------+-----+----------+
| id | name     | dept | price | qoh | supplier |
+----+----------+------+-------+-----+----------+
| 26 | Earrings |   14 |  1000 |  20 |      199 |
+----+----------+------+-------+-----+----------+

Finally the supplier could be removed. */
 /*----------------------------------------------------------------------------*/
 /*Q20 Creates the view the employee had to be able to show him/her how to
 delete it. Then, creates a view  which list all suppliers, which has supplied
 any item, followed by the number of these items that have been sold.
 */

 -- Create view to start from where the employee starts

 CREATE VIEW jbsale_supply(supplier, item, quantity) AS
 SELECT jbsupplier.name, jbitem.name, jbsale.quantity
 FROM jbsupplier, jbitem, jbsale
 WHERE jbsupplier.id = jbitem.supplier
 AND jbsale.item = jbitem.id;

-- Query OK, 0 rows affected (0.04 sec)

-- Instruction for employee:
-- drop VIEW
drop view jbsale_supply;

-- Query OK, 0 rows affected (0.03 sec)


create view jbsale_supply(supplier, item, quantity) as
select jbsupplier.name, jbitem.name, jbsale.quantity
from jbsupplier
join jbitem
on jbsupplier.id=jbitem.supplier
left join jbsale
on jbsale.item = jbitem.id;

-- Query OK, 0 rows affected (0.04 sec)

select supplier, sum(quantity) as sum from jbsale_supply
group by supplier;


/*
+--------------+------+
| supplier     | sum  |
+--------------+------+
| Cannon       |    6 |
| Fisher-Price | NULL |
| Levi-Strauss |    1 |
| Playskool    |    2 |
| White Stag   |    4 |
| Whitman's    |    2 |
+--------------+------+
6 rows in set (0.01 sec)
*/
