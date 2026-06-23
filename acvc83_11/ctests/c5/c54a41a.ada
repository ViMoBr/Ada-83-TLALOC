-- C54A41A.ADA


-- CHECK THAT THE FLOW OF CONTROL IN A  CASE_STATEMENT
--    IS APPROPRIATE.


-- CASE 1: A SMALL ENUMERATION TYPE, ALTERNATIVES SPECIFYING ACTIONS
--    AS OPPOSED TO MERE 'GOTO'S.  THIS CASE IS TREATED IN  C54A42F ,
--    WHERE THE ENUMERATION TYPE  DAY  IS DEFINED AND EACH OF THE 7
--    CASES IS TESTED IN A SEPARATE  CASE_STATEMENT.

-- CASE 2: (TESTED HERE) A SMALL INTEGER RANGE, AND ALTERNATIVES
--    WHICH ARE (ALL) MERE  'GOTO'S.  THE DIFFERENT CASES ARE TESTED
--    IN A LOOP.


-- RM 04/01/81


WITH REPORT;
PROCEDURE  C54A41A  IS

     USE  REPORT ;

BEGIN

     TEST( "C54A41A" , "TEST THAT THE FLOW OF CONTROL IN A" &
                       " CASE_STATEMENT IS APPROPRIATE"  );

     BEGIN

          FOR  I  IN  INTEGER RANGE -3..3  LOOP

               CASE  IDENT_INT(I)  IS    -- VALUES: -3 -2 -1  0  1  2  3
                                         -- LABELS: L1 L2 L3 L4 L5 L6 L7
                    WHEN   3  =>  GOTO L7 ;
                    WHEN   1  =>  GOTO L5 ;
                    WHEN  -3  =>  GOTO L1 ;
                    WHEN  -2  =>  GOTO L2 ;
                    WHEN  -1  =>  GOTO L3 ;
                    WHEN   0  =>  GOTO L4 ;
                    WHEN   2  =>  GOTO L6 ;
                    WHEN  OTHERS =>
                         FAILED( "WRONG BRANCH (8) TAKEN" );
                         GOTO  NEXT_ITERATION ;
               END CASE ;

               FAILED( "NO BRANCH TAKEN" );
               GOTO  NEXT_ITERATION ;

               << L1 >>
               IF  I /= -3  THEN  FAILED( "WRONG BRANCH (1) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               << L2 >>
               IF  I /= -2  THEN  FAILED( "WRONG BRANCH (2) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               << L3 >>
               IF  I /= -1  THEN  FAILED( "WRONG BRANCH (3) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               << L4 >>
               IF  I /= 0   THEN  FAILED( "WRONG BRANCH (4) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               << L5 >>
               IF  I /= 1   THEN  FAILED( "WRONG BRANCH (5) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               << L6 >>
               IF  I /= 2   THEN  FAILED( "WRONG BRANCH (6) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               << L7 >>
               IF  I /= 3   THEN  FAILED( "WRONG BRANCH (7) TAKEN" );
               END IF;
               GOTO  NEXT_ITERATION ;

               FAILED( "WRONG FLOW OF CONTROL" );

               << NEXT_ITERATION >>
               NULL ;

          END LOOP;

     END ;


     RESULT ;


END  C54A41A ;
