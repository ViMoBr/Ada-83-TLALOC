-- B83C02A.ADA


-- CHECK THAT PL/1-STYLE PARTIAL NAMES FOR LOGICALLY NESTED RECORD
--    COMPONENTS ARE NOT PERMITTED.


--    RM     19 JUNE 1980
--    JRK    10 NOV  1980


PROCEDURE  B83C02A  IS

     TYPE  MY_INTEGER  IS  NEW INTEGER RANGE 101..105 ;

     F , V  :  MY_INTEGER ;

     TYPE  R1AAA  IS
          RECORD
               E , F , G : MY_INTEGER ;
          END RECORD ;

     TYPE  R1AAB  IS
          RECORD
               T : MY_INTEGER ;
          END RECORD ;

     TYPE  R1AA  IS
          RECORD
               R : R1AAA ;
               S : R1AAB ;
          END RECORD ;

     TYPE  R1A  IS
          RECORD
               P  : INTEGER ;
               OH : R1AA ;
          END RECORD ;

     TYPE  R1  IS
          RECORD
               N : INTEGER ;
               M : R1A ;
          END RECORD ;

     A : R1 := (1, (2, ((101, 102, 103), (T => 104)))) ;

BEGIN

     V := A.M.OH.S ;    -- ERROR: INCOMPLETE NAME (ALTHOUGH  S  HAS
                        --    ONLY 1 COMPONENT, AND, FURTHERMORE, THAT
                        --    COMPONENT HAS MATCHING TYPE)

     V := A.E ;         -- ERROR: INCOMPLETE NAME (FIRST & LAST PARTS)

     V := A.M.OH.R.E ;  -- CORRECT REFERENCE
     V :=   M.OH.R.E ;  -- ERROR: INCOMPLETE NAME (ONLY LAST 4 PARTS)
     V :=     OH.R.E ;  -- ERROR: INCOMPLETE NAME (ONLY LAST 3 PARTS)
     V :=        R.E ;  -- ERROR: INCOMPLETE NAME (ONLY LAST 2 PARTS)
     V :=          E ;  -- ERROR: INCOMPLETE NAME (ONLY LAST PART)

     V :=          F ;  -- CORRECT REFERENCE TO TOP-LEVEL VARIABLE

     V := A.R.E ;       -- ERROR: INCOMPLETE NAME (1,4,5)
     V := A.M.E ;       -- ERROR: INCOMPLETE NAME (1,2,5)

END B83C02A ;
