-- B32202C.ADA


-- CHECK THAT AN INTEGRAL NUMBER NAME CANNOT BE USED IN A CONTEXT
--    REQUIRING A FIXED-POINT VALUE OR IN A CONTEXT REQUIRING
--    A REAL VALUE.


-- RM 03/04/81
-- SPS 2/10/83

PROCEDURE  B32202C  IS
BEGIN

     DECLARE

          TYPE  MY_FIXED  IS  DELTA 0.5 RANGE 0.0 .. 20.0 ;

          F1               :  MY_FIXED  :=  7.0 ;
          TYPE  ACCTYPE   IS  ACCESS MY_FIXED ;
          ACCOBJ           :  ACCTYPE ;

          TYPE  AGGR     IS
               RECORD
                    X : INTEGER ;
                    Y : MY_FIXED ;
               END RECORD;

          PSEUDO_FIXED    :  CONSTANT  := 12E0 ;
          PSEUDO_REAL1    :  CONSTANT  :=  1E1 ;
          PSEUDO_REAL2    :  CONSTANT  := -2E3 ;
          PSEUDO_REAL3    :  CONSTANT  := +2E3 ;

          REC : AGGR;

          TYPE  MY_OTHER_FIXED  IS
               DELTA  PSEUDO_REAL1     -- ERROR: FIXED OR FLOAT REQUIRED
               RANGE  1.0 .. 10.0;

          TYPE  MY_NEXT_FIXED IS
               DELTA 0.1
               RANGE PSEUDO_REAL2      -- ERROR: FIXED OR FLOAT REQUIRED
                  .. 10.0;

          TYPE MY_LAST_FIXED IS
               DELTA 0.1
               RANGE 0.0
                  ..  PSEUDO_REAL3 ;   -- ERROR: FIXED OR FLOAT REQUIRED

          A3  :  CONSTANT MY_FIXED     :=  PSEUDO_FIXED  ;     -- ERROR:

          FUNCTION  FN( A5 : MY_FIXED  :=  PSEUDO_FIXED  )     -- ERROR:
                                        RETURN  MY_FIXED  IS
          BEGIN
               RETURN  PSEUDO_FIXED ;                          -- ERROR:
          END  FN ;

          PROCEDURE  PROC( A6 : MY_FIXED  := PSEUDO_FIXED ) IS -- ERROR:
          BEGIN
               NULL ;
          END PROC ;

     BEGIN

          F1 := PSEUDO_FIXED ;                                 -- ERROR:
          REC := ( 7 , PSEUDO_FIXED ) ;                       -- ERROR:

          IF  F1 = PSEUDO_FIXED  THEN                          -- ERROR:
               NULL ;
          END IF;

          PROC( PSEUDO_FIXED );                                -- ERROR:

          ACCOBJ  :=  NEW MY_FIXED'(PSEUDO_FIXED );            -- ERROR:

     END ;


END B32202C ;
