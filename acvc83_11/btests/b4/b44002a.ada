-- B44002A.ADA


-- CHECK THAT STATEMENT LABELS, THE ATTRIBUTES  'BASE , 'RANGE , AND
--    NAMES OF TYPES, SUBTYPES, SUBPROGRAMS, PACKAGES,
--    BLOCKS, AND LOOPS  ARE NOT PERMITTED AS PRIMARIES.


-- RM   22 SEPTEMBER 1980
-- SPS  11/22/82

PROCEDURE  B44002A  IS

     A    : INTEGER ;
     TYPE  VECT  IS  ARRAY( 1..10 ) OF CHARACTER ;
     SUBTYPE  LIST  IS  VECT ;

     PROCEDURE  PROC( X , Y : BOOLEAN )  IS
     BEGIN
          NULL ;
     END PROC ;

     FUNCTION  F1( X : BOOLEAN )  RETURN  INTEGER  IS
     BEGIN
          RETURN  17 ;
     END F1 ;

     FUNCTION  F2( X : BOOLEAN := TRUE )  RETURN  INTEGER  IS
     BEGIN
          RETURN  17 ;
     END F2 ;

     FUNCTION  F3  RETURN  INTEGER  IS
     BEGIN
          RETURN  17 ;
     END F3 ;

     PACKAGE  PACK  IS
          FUNCTION  OWN_F  RETURN  INTEGER ;
     END PACK ;

     PACKAGE BODY  PACK  IS
          FUNCTION  OWN_F  RETURN  INTEGER  IS
          BEGIN
               RETURN  17 ;
          END OWN_F ;
     END PACK ;

BEGIN

     << LABEL1 >>
     A := LABEL1 ;         -- ERROR: LABEL  AS PRIMARY
     NULL ;
     A := LABEL2 ;         -- ERROR: LABEL  AS PRIMARY
     NULL ;
     << LABEL2 >> NULL ;

     BLOCK1 :  BEGIN     NULL;     END BLOCK1 ;
     A := BLOCK1 ;         -- ERROR: BLOCK IDENTIFIER  AS PRIMARY
     NULL ;
     A := BLOCK2 ;         -- ERROR: BLOCK IDENTIFIER  AS PRIMARY
     NULL ;
     BLOCK2 :  BEGIN     NULL;     END BLOCK2 ;

     LOOOP1 :  WHILE FALSE LOOP     NULL;     END LOOP LOOOP1;
     A := LOOOP1 ;         -- ERROR: LOOP IDENTIFIER  AS PRIMARY
     NULL ;
     A := LOOOP2 ;         -- ERROR: LOOP IDENTIFIER  AS PRIMARY
     NULL ;
     LOOOP2 :  WHILE FALSE LOOP     NULL;     END LOOP LOOOP2;

     NULL ;
     A := VECT'BASE ;      -- ERROR: 'BASE  AS PRIMARY
     NULL ;
     A := VECT'FIRST + VECT'RANGE ;      -- ERROR: 'RANGE  AS PRIMARY
     NULL ;
     A := VECT ;           -- ERROR: TYPE NAME  AS PRIMARY
     NULL ;
     A := LIST ;           -- ERROR: SUBTYPE NAME  AS PRIMARY
     NULL ;
     A := 2 + PROC ;       -- ERROR: PROCEDURE NAME  AS PRIMARY
     NULL ;
     A := 3 + F1 ;         -- ERROR: FUNCTION NAME  AS PRIMARY
     NULL ;
     A := 3 + F2 ;         -- OK.
     NULL ;
     A := 3 + F3 ;         -- OK.
     NULL ;
     A := 3 + PACK.OWN_F ; -- OK.
     NULL ;
     A := 3 + PACK ;       -- ERROR: PACKAGE NAME  AS PRIMARY
     NULL ;

END  B44002A ;
