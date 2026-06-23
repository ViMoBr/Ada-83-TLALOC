-- B32202B.ADA


-- CHECK THAT AN INTEGRAL NUMBER NAME CANNOT BE USED IN A CONTEXT
--    REQUIRING A FLOATING-POINT VALUE.


-- RM 03/04/81
-- JRK 2/2/83


PROCEDURE  B32202B  IS
BEGIN

     DECLARE

          F1              :  FLOAT  :=  7.0 ;
          TYPE  ACCTYPE  IS  ACCESS FLOAT ;
          ACCOBJ          :  ACCTYPE ;

          TYPE  AGGR     IS
               RECORD
                    X : INTEGER ;
                    Y : FLOAT   ;
               END RECORD;

          AGGR1 : AGGR ;

          PSEUDO_FLOAT : CONSTANT  := -2E3 ;

          A3  :  CONSTANT FLOAT    := PSEUDO_FLOAT   ;         -- ERROR:

          FUNCTION  FN( A5 : FLOAT   := PSEUDO_FLOAT   )       -- ERROR:
                                        RETURN  FLOAT    IS
          BEGIN
               RETURN  PSEUDO_FLOAT   ;                        -- ERROR:
          END  FN ;

          PROCEDURE  PROC( A6 : FLOAT   := PSEUDO_FLOAT   ) IS -- ERROR:
          BEGIN
               NULL ;
          END  PROC ;

     BEGIN

          F1 := PSEUDO_FLOAT   ;                               -- ERROR:
          AGGR1 := ( 7 , PSEUDO_FLOAT   ) ;                    -- ERROR:

          IF  F1 = PSEUDO_FLOAT    THEN                        -- ERROR:
               NULL ;
          END IF;

          PROC( PSEUDO_FLOAT   );                              -- ERROR:

          ACCOBJ  :=  NEW FLOAT ' ( PSEUDO_FLOAT   );          -- ERROR:

     END ;


END B32202B ;
