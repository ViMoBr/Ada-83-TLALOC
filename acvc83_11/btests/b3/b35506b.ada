-- B35506B.ADA

-- OBJECTIVE:
--     CHECK THAT THE ATTRIBUTES  T'SUCC ,  T'PRED ,  T'POS , AND
--     T'IMAGE CANNOT INVOLVE FIXED-POINT TYPES (EVEN IF WITH
--     INTEGRAL VALUES).

-- HISTORY:
--     RM  03/12/81  CREATED ORIGINAL TEST.
--     BCB 08/01/88  MODIFIED HEADER FORMAT AND ADDED CHECKS FOR 'IMAGE.


PROCEDURE  B35506B  IS
BEGIN


     DECLARE

          TYPE   FIX_100  IS  DELTA 1.0 RANGE 0.0 .. 100.0 ;
          F100 : FIX_100  :=  10.0 ;
          TYPE   INT_100  IS  NEW INTEGER RANGE 0 .. 100   ;
          I100 : INT_100  :=  10   ;

     BEGIN

          IF  INT_100'SUCC(F100) = INT_100'SUCC(F100)     -- ERROR:
                                        --    NON-DISCRETE ARG.(SUCC)
          THEN  NULL ;
          END IF;

          IF  INT_100'PRED(F100) = INT_100'PRED(F100)     -- ERROR:
                                        --    NON-DISCRETE ARG.(PRED)
          THEN  NULL ;
          END IF;

          I100 := INT_100'POS(F100) ;-- ERROR: NON-DISCRETE ARG.(POS)

          IF INT_100'IMAGE(F100) = INT_100'IMAGE(F100)    -- ERROR:
               THEN NULL;               --    NON-DISCRETE ARG.(IMAGE)
          END IF;

          IF  FIX_100'SUCC(I100) = FIX_100'SUCC(I100)     -- ERROR:
                                        --    NON-DISCRETE TYPE
          THEN  NULL ;
          END IF;

          IF  FIX_100'PRED(I100) = FIX_100'PRED(I100)     -- ERROR:
                                        --    NON-DISCRETE TYPE
          THEN  NULL ;
          END IF;

          IF  FIX_100'POS (I100) = FIX_100'POS (I100)     -- ERROR:
                                        --    NON-DISCRETE TYPE
          THEN  NULL ;
          END IF;

          IF FIX_100'IMAGE(I100) = FIX_100'IMAGE(I100)    -- ERROR:
               THEN NULL;               --    NON-DISCRETE TYPE
          END IF;

          IF  FIX_100'SUCC(F100) = FIX_100'SUCC(F100)     -- ERROR:
                                        --    NON-DISCRETE TYPE
          THEN  NULL ;
          END IF;

          IF  FIX_100'PRED(F100) = FIX_100'PRED(F100)     -- ERROR:
                                        --    NON-DISCRETE TYPE
          THEN  NULL ;
          END IF;

          IF  FIX_100'POS (F100) = FIX_100'POS (F100)     -- ERROR:
                                        --    NON-DISCRETE TYPE
          THEN  NULL ;
          END IF;

          IF FIX_100'IMAGE(F100) = FIX_100'IMAGE(F100)    -- ERROR:
               THEN NULL;               --    NON-DISCRETE TYPE
          END IF;

     END ;


END B35506B ;
