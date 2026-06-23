-- B32202A.ADA


-- CHECK THAT A REAL NUMBER NAME CANNOT BE USED IN A CONTEXT REQUIRING
--    AN INTEGER VALUE.


-- RM 03/04/81
-- VKG 1/6/83


PROCEDURE  B32202A  IS
BEGIN

     DECLARE

          I1              :  INTEGER   :=  7 ;
          TYPE  ACCTYPE  IS  ACCESS INTEGER  ;
          ACCOBJ          :  ACCTYPE ;

          TYPE  AGG      IS
               RECORD
                    X , Y : INTEGER ;
               END RECORD;

          AGGR : AGG := (3,4);
          PSEUDO_INTEGER  :  CONSTANT  :=  5.0 ;

          A1  :  STRING(1..PSEUDO_INTEGER) ;                   -- ERROR:
          A2  :  INTEGER RANGE 1..PSEUDO_INTEGER ;             -- ERROR:
          A3  :  CONSTANT INTEGER  := PSEUDO_INTEGER ;         -- ERROR:
          TYPE AA( A4 : INTEGER := PSEUDO_INTEGER )  IS        -- ERROR:
               RECORD
                    X : INTEGER ;
                    CASE  A4  IS
                         WHEN  PSEUDO_INTEGER =>               -- ERROR:
                              Y : INTEGER ;
                         WHEN  OTHERS =>
                              Z : INTEGER ;
                    END CASE;
               END RECORD;

          FUNCTION  FN( A5 : INTEGER := PSEUDO_INTEGER )       -- ERROR:
                                        RETURN  INTEGER  IS
          BEGIN
               RETURN  PSEUDO_INTEGER ;                        -- ERROR:
          END  FN ;

          PROCEDURE  PROC( A6 : INTEGER := PSEUDO_INTEGER ) IS -- ERROR:
          BEGIN
               NULL ;
          END  PROC ;

     BEGIN

          I1 := PSEUDO_INTEGER ;                               -- ERROR:
          AGGR.X := 7;                                         -- OK.
          AGGR.Y := PSEUDO_INTEGER;                            -- ERROR:

          IF  I1 = PSEUDO_INTEGER  THEN                        -- ERROR:
               NULL ;
          END IF;

          FOR  I  IN  1..PSEUDO_INTEGER  LOOP                  -- ERROR:
               EXIT;
          END LOOP;

          CASE  I1  IS
               WHEN  PSEUDO_INTEGER =>                         -- ERROR:
                    NULL ;
               WHEN  OTHERS =>
                    NULL ;
          END CASE;

          PROC( PSEUDO_INTEGER );                              -- ERROR:

          ACCOBJ  :=  NEW INTEGER'( PSEUDO_INTEGER );          -- ERROR:

     END ;


END B32202A ;
