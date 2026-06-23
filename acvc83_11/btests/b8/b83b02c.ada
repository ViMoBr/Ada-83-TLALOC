-- B83B02C.ADA


-- CHECK THAT INSIDE A LOOP THE LOOP PARAMETER HIDES ANY
--    IDENTICALLY NAMED IDENTIFIERS IN ENCOMPASSING LOOPS OR BLOCKS.


--    RM    6 JUNE 1980


PROCEDURE  B83B02C  IS

     I : INTEGER ;

     TYPE  WEEKDAY  IS  ( MON , TUE , WED , THU , FRI );

BEGIN

     FOR  LOOP_PAR  IN  1 .. 10  LOOP
          FOR  LOOP_PAR IN  MON .. FRI  LOOP
               I := 8 *
                    LOOP_PAR ; -- ERROR: ATTEMPT TO ACCESS HIDDEN
                               --       IDENTIFIER   ( 1)
          END LOOP;
     END LOOP;

     DECLARE
          LOOP_PAR : INTEGER ;
     BEGIN
          FOR  LOOP_PAR IN  MON .. FRI  LOOP
               I := 8 *
                    LOOP_PAR ; -- ERROR: ATTEMPT TO ACCESS HIDDEN
                               --       IDENTIFIER   ( 2 )

          END LOOP;
     END;


END B83B02C ;
