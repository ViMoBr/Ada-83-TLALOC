-- B83E02C.ADA

-- CHECK THAT A FORMAL PARAMETER OF A SUBPROGRAM (PROCEDURE OR FUNCTION)
--    CANNOT BE USED AS A DEFAULT VALUE APPEARING LATER IN THE PARAMETER
--    LIST.  

--    RM   11 JULY 1980
--    RM   24 JULY 1980
--    SPS  12/10/82

PROCEDURE  B83E02C  IS

     X , Y , Z : INTEGER := 7 ;

     TYPE  TD (DISCR : INTEGER)  IS
          RECORD
               REST  : INTEGER ;
          END RECORD ;

     TYPE  TI  IS  ARRAY(INTEGER RANGE <>) OF BOOLEAN ;


     PROCEDURE  P1R (A,B : INTEGER;
                     I : INTEGER := I ;         -- ERROR: SELF-REF.
                     K : INTEGER := B ;         -- ERROR: REF. PARAM.  B
                     L : INTEGER := X ;         -- OK: VARIABLE X
                     X : INTEGER
                                       )  IS
     BEGIN
          NULL ;
     END ;

BEGIN
     NULL ;
END B83E02C;
