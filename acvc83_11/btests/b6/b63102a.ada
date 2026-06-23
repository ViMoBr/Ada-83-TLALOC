-- B63102A.ADA

-- CHECK THAT IF DIFFERENT FORMS OF A NAME ARE USED IN THE DEFAULT
-- EXPRESSION OF A DISCRIMINANT PART OR A FORMAL PART, THE SELECTOR MAY
-- NOT BE AN OPERATOR SYMBOL OR A CHARACTER LITERAL.

-- SPS 2/22/84

PROCEDURE B63102A IS

     PACKAGE PACK IS 
          TYPE T IS RANGE 1 .. 100;
          TYPE EN IS ('A', 'B', 'C', 'D');
          FUNCTION "+" (X, Y : T) RETURN T;

          TYPE PVT (D : T := "+" (3,5)) IS PRIVATE;
          TYPE PVEN (D : EN := 'A') IS PRIVATE;

          PROCEDURE PT (X : T := "+" (10, 15));
          PROCEDURE PEN (X : EN := 'C');

     PRIVATE

          TYPE PVT (D : T := PACK."+" (3,5)) IS   -- ERROR: SELECTOR IS
                                                  -- AN OPERATOR
               RECORD
                    NULL;
               END RECORD;

          TYPE PVEN (D : EN := PACK.'A') IS       -- ERROR: SELECTOR IS
                                                  -- A LITERAL
               RECORD
                    NULL;
               END RECORD;

     END PACK;

     PACKAGE BODY PACK IS 

          FUNCTION "+" (X, Y : T) RETURN T IS
          BEGIN
               RETURN 10;
          END "+";

          PROCEDURE PT (X : T := PACK."+" (10, 15)) IS -- ERROR:
                                                       -- SELECTOR IS AN
                                                       -- OPERATOR
          BEGIN
               NULL;
          END PT;

          PROCEDURE PEN (X : EN := PACK.'C') IS        -- ERROR:
                                                       -- SELECTOR IS A
                                                       -- LITERAL 
          BEGIN
               NULL;
          END PEN;

     END PACK;

BEGIN
     NULL;
END B63102A;
