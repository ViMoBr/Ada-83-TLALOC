-- B44002B.ADA


-- CHECK THAT THE NAMES OF TASKS AND ENTRIES
--    ARE NOT PERMITTED AS PRIMARIES.


-- RM   22 SEPTEMBER 1980
-- VKG  07 JANUARY   1983

PROCEDURE  B44002B  IS

     A    : INTEGER ;

     TASK  BRINGER  IS
          ENTRY  READ ( X : OUT INTEGER );
     END ;

     TASK TYPE  READER  IS
          ENTRY  READ ( X : OUT INTEGER );
     END ;

     READER_1  :  READER ;

     TASK BODY  BRINGER  IS
     BEGIN
          ACCEPT  READ ( X : OUT INTEGER )  DO
               X :=  17 ;
          END READ ;
     END BRINGER ;

     TASK BODY  READER  IS
     BEGIN
          ACCEPT  READ ( X : OUT INTEGER )  DO
               X :=  17 ;
          END READ ;
     END READER ;

BEGIN

     A := BRINGER ;             -- ERROR: TASK AS PRIMARY
     NULL ;
     A := READER ;              -- ERROR: TASK TYPE AS PRIMARY
     NULL ;
     A := READER_1 ;            -- ERROR: TASK AS PRIMARY
     NULL ;

     A := BRINGER.READ( A );    -- ERROR: TASK ENTRY AS PRIMARY
     NULL ;
     A := READER_1.READ( A );   -- ERROR: TASK ENTRY AS PRIMARY
     NULL ;

END  B44002B ;
