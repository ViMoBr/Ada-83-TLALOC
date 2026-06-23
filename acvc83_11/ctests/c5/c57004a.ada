-- C57004A.ADA


-- CHECK THAT AN EXIT STATEMENT WITH A LOOP NAME TERMINATES EXECUTION
--    OF THE LOOP STATEMENT WHOSE NAME IT MENTIONS, AND OF ALL OTHER
--    LOOP STATEMENTS (IF ANY) INTERIOR TO THE FIRST LOOP AND ENCLOSING
--    THE EXIT STATEMENT.

-- CASE 1 :  UNCONDITIONAL EXITS.


-- RM 04/24/81
-- SPS 3/7/83

WITH REPORT;
PROCEDURE  C57004A  IS

     USE  REPORT ;

BEGIN

     TEST( "C57004A" , "CHECK THAT A NAMING EXIT STATEMENT TERMINATES" &
                       " EXECUTION OF THE NAMED LOOP AND OF ALL LOOPS" &
                       " SITUATED IN-BETWEEN"                         );

     DECLARE

          COUNT : INTEGER     := 0   ;

     BEGIN

          OUTERMOST :
          FOR  X  IN  INTEGER RANGE 1..2  LOOP

               FOR  Y  IN  INTEGER RANGE 1..2  LOOP

                    COMMENT( "BEFORE 1" );

                    LOOP1 :
                    FOR  I  IN  1..10  LOOP
                         COMMENT( "INSIDE 1" );
                         EXIT  LOOP1 ;
                         FAILED( "EXIT NOT OBEYED (1)" );
                         FOR  J  IN  1..10  LOOP
                              FAILED( "OUTER EXIT NOT OBEYED (1)" );
                              EXIT ;
                              FAILED( "BOTH EXITS IGNORED (1)" );
                         END LOOP;
                    END LOOP  LOOP1 ;


                    COMMENT( "BEFORE 2" );
                    COUNT := COUNT + 1 ;

                    LOOP2 :
                    FOR  A  IN  1..1  LOOP
                         FOR  B  IN  1..1  LOOP

                              FOR  I  IN  CHARACTER  LOOP
                                   COMMENT( "INSIDE 2" );
                                   EXIT  LOOP2 ;
                                   FAILED( "EXIT NOT OBEYED (2)" );
                                   FOR  J  IN  BOOLEAN  LOOP
                                        FAILED( "OUTER EXIT NOT " &
                                                "OBEYED (2)");
                                        EXIT ;
                                        FAILED( "BOTH EXITS IGNORED " &
                                                "(2)");
                                   END LOOP;
                              END LOOP;

                         END LOOP;
                    END LOOP  LOOP2 ;


                    COMMENT( "BEFORE 3" );
                    COUNT := COUNT + 1 ;

                    LOOP3 :
                    FOR  A  IN  1..1  LOOP
                         FOR  B  IN  1..1  LOOP

                              FOR  I  IN  BOOLEAN  LOOP
                                   COMMENT( "INSIDE 3" );
                                   BEGIN
                                        EXIT  LOOP3 ;
                                        FAILED( "EXIT NOT OBEYED (3)" );
                                   END ;
                                   FAILED( "EXIT NOT OBEYED (3BIS)" );
                              END LOOP;

                         END LOOP;
                    END LOOP  LOOP3 ;


                    COMMENT( "BEFORE 4" );
                    COUNT := COUNT + 1 ;

                    LOOP4 :
                    FOR  A  IN  1..1  LOOP
                         FOR  B  IN  1..1  LOOP


                              FOR  I  IN  INTEGER RANGE 1..10  LOOP
                                   COMMENT( "INSIDE 4" );
                                   CASE  A  IS
                                        WHEN  1  =>
                                             EXIT  LOOP4 ;
                                             FAILED("EXIT NOT OBEYED " &
                                                    "(4)" );
                                   END CASE;
                                   FAILED( "EXIT NOT OBEYED (4BIS)" );
                              END LOOP;

                         END LOOP;
                    END LOOP  LOOP4 ;


                    COMMENT( "AFTER 4" );
                    COUNT := COUNT + 1 ;
                    EXIT  OUTERMOST ;

               END LOOP;

               FAILED( "MISSED FINAL EXIT" );

          END LOOP  OUTERMOST ;


          IF  COUNT /= 4  THEN
               FAILED( "WRONG FLOW OF CONTROL" );
          END IF;

     END ;

     RESULT ;


END  C57004A ;
