-- C57002A.ADA


-- CHECK THAT A SIMPLE EXIT UNCONDITIONALLY TRANSFERS CONTROL OUT OF
--    THE INNERMOST ENCLOSING LOOP.


-- RM 04/24/81
-- SPS 3/7/83

WITH REPORT;
PROCEDURE  C57002A  IS

     USE  REPORT ;

BEGIN

     TEST( "C57002A" , "CHECK THAT A SIMPLE EXIT UNCONDITIONALLY"      &
                       " TRANSFERS CONTROL OUT OF THE INNERMOST"       &
                       " ENCLOSING LOOP"                              );

     DECLARE

     BEGIN

          FOR  I  IN  1..10  LOOP
               IF  EQUAL(1,1)  THEN  EXIT ;
               END IF;
               FAILED( "EXIT NOT OBEYED (1)" );
               FOR  J  IN  1..10  LOOP
                    FAILED( "OUTER EXIT NOT OBEYED (1)" );
                    IF  EQUAL(1,1)  THEN  EXIT ;
                    END IF;
                    FAILED( "BOTH EXITS IGNORED (1)" );
               END LOOP;
          END LOOP;


          FOR  A  IN  1..1  LOOP
               FOR  B  IN  1..1  LOOP

                    FOR  I  IN  CHARACTER  LOOP
                         IF  EQUAL(1,1)  THEN  EXIT ;
                         END IF;
                         FAILED( "EXIT NOT OBEYED (2)" );
                         FOR  J  IN  BOOLEAN  LOOP
                              FAILED( "OUTER EXIT NOT OBEYED (2)");
                              IF  EQUAL(1,1)  THEN  EXIT ;
                              END IF;
                              FAILED( "BOTH EXITS IGNORED (2)");
                         END LOOP;
                    END LOOP;

               END LOOP;
          END LOOP;


          FOR  A  IN  1..1  LOOP
               FOR  B  IN  1..1  LOOP

                    FOR  I  IN  BOOLEAN  LOOP
                         NULL ;
                         BEGIN
                              IF  EQUAL(1,1)  THEN  EXIT ;
                              END IF;
                              FAILED( "EXIT NOT OBEYED (3)" );
                         END ;
                         FAILED( "EXIT NOT OBEYED (3BIS)" );
                    END LOOP;

               END LOOP;
          END LOOP;


          FOR  A  IN  1..1  LOOP
               FOR  B  IN  1..1  LOOP

                    FOR  I  IN  INTEGER RANGE 1..10  LOOP
                         NULL ;
                         CASE  A  IS
                              WHEN  1  =>
                                   IF  EQUAL(1,1)  THEN  EXIT ;
                                   END IF;
                                   FAILED( "EXIT NOT OBEYED (4)" );
                         END CASE;
                         FAILED( "EXIT NOT OBEYED (4BIS)" );
                    END LOOP;

               END LOOP;
          END LOOP;

     END ;


     RESULT ;


END  C57002A ;
