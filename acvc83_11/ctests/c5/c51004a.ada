-- C51004A.ADA

-- CHECK THAT LABELS, LOOP IDENTIFIERS, AND BLOCK IDENTIFIERS ARE
-- IMPLICITLY DECLARED AT THE END OF THE DECLARATIVE PART.  PRIOR TO
-- THE END OF THE DECLARATIVE PART, THEY MAY BE USED TO REFERENCE
-- ENTITIES IN AN ENCLOSING SCOPE.  SUBTESTS ARE:
--        (A) BLOCK.
--        (B) PROCEDURE BODY.
--        (C) PACKAGE BODY.
--        (D) GENERIC FUNCTION BODY.
--        (E) GENERIC PACKAGE BODY.
--        (F) TASK BODY.

-- CPP  6/1/84

WITH REPORT;  USE REPORT;
PROCEDURE C51004A IS

BEGIN
     TEST("C51004A", "CHECK THAT LABELS, LOOP IDENTIFIERS, AND BLOCK " &
          "IDENTIFIERS MAY BE USED PRIOR TO THEIR IMPLICIT " &
          "DECLARATION");

OUTER: DECLARE

          TYPE IDN1 IS NEW INTEGER;
          IDN2 : CONSTANT INTEGER := 2;
          TYPE IDN3 IS ACCESS INTEGER;

     BEGIN     -- OUTER

     -----------------------------------------------

     A :  DECLARE

               A1 : IDN1;
               A2 : CONSTANT INTEGER := IDN2;
               A3 : IDN3;

               TEMP : INTEGER;

          BEGIN     -- A

           <<IDN1>> TEMP := 0;

             IDN2 : FOR I IN 1..1 LOOP
                         TEMP := A2;
                    END LOOP IDN2;

             IDN3 : BEGIN
                         NULL;
                    END IDN3;

          END A;

     -----------------------------------------------

     B :  DECLARE

               PROCEDURE P (TEMP : OUT INTEGER) IS

                    B1 : IDN1;
                    B2 : CONSTANT INTEGER := IDN2 + 2;
                    B3 : IDN3;

               BEGIN     -- P
               
          <<L>> <<IDN1>> TEMP := 0;

                  IDN2 : WHILE B2 < 0 LOOP
                              TEMP := 0;
                         END LOOP IDN2;

                  IDN3 : DECLARE
                         BEGIN
                              NULL;
                         END IDN3;

               END P;

          BEGIN     -- B
               NULL;
          END B;

     -----------------------------------------------

     C :  DECLARE

               PACKAGE PKG IS
               END PKG;

               PACKAGE BODY PKG IS

                    C1 : IDN1;
                    C2 : CONSTANT INTEGER := 2 * IDN2;
                    C3 : IDN3;

                    TEMP : INTEGER;

               BEGIN

                <<IDN1>> TEMP := 0;

                  IDN2 : LOOP
                              TEMP := 0;
                              EXIT;          
                         END LOOP IDN2;

                  IDN3 : BEGIN
                              NULL;
                         END IDN3;

               END PKG;

          BEGIN     -- C
               NULL;
          END C;

     ---------------------------------------------------

     D :  DECLARE

               GENERIC
                    TYPE Q IS (<>);
               FUNCTION FN RETURN INTEGER;

               FUNCTION FN RETURN INTEGER IS

                    D1 : IDN1;
                    D2 : CONSTANT INTEGER := IDN2;
                    D3 : IDN3;

                    TEMP : INTEGER;

               BEGIN     

                <<IDN1>> TEMP := 0;

                  IDN2 : FOR I IN 1..5 LOOP
                              TEMP := 0;
                         END LOOP IDN2;

                  IDN3 : BEGIN
                              NULL;
                         END IDN3;  
                    
                         RETURN TEMP;

               END FN;

          BEGIN
               NULL;
          END D;

     -----------------------------------------------

     E :  DECLARE

               GENERIC

                    TYPE ELEMENT IS (<>);
                    ITEM : ELEMENT;

               PACKAGE PKG IS
               END PKG;

               PACKAGE BODY PKG IS

                    E1 : IDN1 RANGE 1..5;
                    E2 : CONSTANT INTEGER := IDN2;
                    E3 : IDN3;

                    TEMP : ELEMENT;

               BEGIN

          <<IDN1>> <<L>> TEMP := ITEM;

                  IDN2 : WHILE TEMP /= ITEM LOOP
                              TEMP := ITEM;
                         END LOOP IDN2;

                  IDN3 : DECLARE
                         BEGIN
                              NULL;
                         END IDN3;

               END PKG;
          
          BEGIN     -- E

               DECLARE
                    PACKAGE P1 IS NEW PKG (INTEGER, 0);
               BEGIN
                    NULL;
               END;
               
          END E;

     -----------------------------------------------

     F :  DECLARE

               TASK T;

               TASK BODY T IS

                    F1 : IDN1 RANGE -4..2;
                    F2 : CONSTANT INTEGER := IDN2;
                    F3 : IDN3;

                    TEMP : INTEGER;

               BEGIN

                <<IDN1>> TEMP := 1;

                  IDN2 : LOOP
                              TEMP := TEMP + 1;
                              EXIT;
                         END LOOP IDN2;

                  IDN3 : DECLARE
                         BEGIN
                              TEMP := TEMP + 1;
                         END IDN3;

               END T;

          BEGIN     -- F
               NULL;
          END F;

     -----------------------------------------------

     END OUTER;

     RESULT;
END C51004A;
