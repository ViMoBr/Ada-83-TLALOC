-- CC3011D.ADA

-- CHECK THAT WHEN A GENERIC PACKAGE INSTANTIATION CONTAINS DECLARATIONS
-- OF SUBPROGRAMS WITH THE SAME SPECIFICATIONS, THE CALLS TO THE
-- SUBPROGRAMS ARE NOT AMBIGIOUS WITHIN THE GENERIC BODY.

-- SPS 5/7/82
-- SPS 2/7/83

WITH REPORT; USE REPORT;

PROCEDURE CC3011D IS
BEGIN
     TEST ("CC3011D", "SUBPROGRAMS WITH SAME SPECIFICATIONS NOT"
          & " AMBIGIOUS WITHIN GENERIC BODY");

     DECLARE
          TYPE FLAG IS (PRT,PRS);
          XX : FLAG;

          GENERIC
               TYPE S IS PRIVATE;
               TYPE T IS PRIVATE;
               V1 : S;
               V2 : T;
          PACKAGE P1 IS
               PROCEDURE PR(X : S);
               PROCEDURE PR(X : T);
          END P1;

          PACKAGE BODY P1 IS
               PROCEDURE PR (X : S) IS
               BEGIN
                    XX := PRS;
               END;

               PROCEDURE PR (X : T ) IS
               BEGIN
                    XX := PRT;
               END;

          BEGIN
               XX := PRT;
               PR (V1);
               IF XX /= PRS THEN
                    FAILED ("WRONG BINDING FOR PR WITH TYPE S");
               END IF;
               XX := PRS;
               PR (V2);
               IF XX /= PRT THEN
                    FAILED ("WRONG BINDING FOR PR WITH TYPE T");
               END IF;
          END P1;

          PACKAGE PAK IS NEW P1 (INTEGER, INTEGER, 1, 2);

     BEGIN
          NULL;
     END;

     RESULT;
END CC3011D;
