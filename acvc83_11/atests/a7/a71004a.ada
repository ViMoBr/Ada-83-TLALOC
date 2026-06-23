-- A71004A.ADA

-- CHECK THAT ALL FORMS OF DECLARATION PERMITTED IN THE PRIVATE PART OF
-- A PACKAGE ARE INDEED ACCEPTED BY THE COMPILER. 
-- TASKS, GENERICS, FIXED AND FLOAT DECLARATIONS ARE NOT TESTED.

-- DAT 5/6/81
-- VKG 2/16/83

WITH REPORT; USE REPORT;

PROCEDURE A71004A IS
BEGIN

     TEST ("A71004A", "ALL FORMS OF DECLARATIONS IN PRIVATE PART");

     DD:
     DECLARE

          PACKAGE P1 IS

               TYPE P IS PRIVATE;
               TYPE L IS LIMITED PRIVATE;
               CP : CONSTANT P;
               CL : CONSTANT L;

          PRIVATE

               ONE : CONSTANT := 1;
               TWO : CONSTANT := ONE * 1.0 + 1.0;
               N1, N2, N3 : CONSTANT := TWO;
               TYPE I IS RANGE -10 .. 10;
               X4, X5 : CONSTANT I := I(IDENT_INT(3));
               X6, X7 : I := X4 + X5;
               TYPE AR IS ARRAY (I) OF L;

               X10 : ARRAY (IDENT_INT(1) .. IDENT_INT (10)) OF I;
               X11 : CONSTANT ARRAY (1..10) OF I := (1..10=>3);
               TYPE T3 IS (E12);
               TYPE T4 IS NEW T3;

               TYPE REC1 (D:BOOLEAN:=TRUE) IS RECORD NULL; END RECORD;
               SUBTYPE  REC1TRUE  IS  REC1( D => TRUE ) ;
               TYPE L IS NEW REC1TRUE ;
               X8 , X9 : AR;
               TYPE  A6  IS  ACCESS REC1 ;
               SUBTYPE  L1  IS  L ;
               SUBTYPE  A7  IS  A6(D=>TRUE);
               SUBTYPE I14 IS I RANGE 1 .. 1;
               TYPE UA1 IS ARRAY (I14 RANGE <> ) OF I14;
               TYPE UA2 IS NEW UA1;
               USE STANDARD.ASCII;

               PROCEDURE P1 ;

               FUNCTION F1 (X : UA1) RETURN UA1;

               FUNCTION "+" (X : UA1) RETURN UA1;

               PACKAGE  PK IS
               PRIVATE
               END;

               PACKAGE PK1 IS
                    PACKAGE PK2 IS END;
               PRIVATE
                    PACKAGE PK3 IS PRIVATE END;
               END PK1;

               EX : EXCEPTION;
               EX1, EX2 : EXCEPTION;
               X99 : I RENAMES X7;
               EX3 : EXCEPTION RENAMES EX1;
               PACKAGE PQ1 RENAMES DD.P1;
               PACKAGE PQ2 RENAMES PK1;
               PACKAGE PQ3 RENAMES PQ2 . PK2;
               FUNCTION "-" (X : UA1) RETURN UA1 RENAMES "+";
               PROCEDURE P98 RENAMES P1;
               TYPE P IS NEW L;
               CP : CONSTANT P := (D=> TRUE);
               CL : CONSTANT L := L(CP);

          END P1;

          PACKAGE BODY P1 IS

               PROCEDURE P1 IS BEGIN NULL; END P1;

               FUNCTION F1 (X : UA1) RETURN UA1 IS
               BEGIN RETURN X; END F1;

               FUNCTION "+" (X : UA1) RETURN UA1 IS
               BEGIN RETURN F1(X); END "+";

               PACKAGE BODY PK1 IS
                    PACKAGE BODY PK3 IS END;
               END PK1;

          BEGIN
               NULL ;
          END P1;

     BEGIN
          NULL;
     END DD;
     RESULT;

END A71004A;
