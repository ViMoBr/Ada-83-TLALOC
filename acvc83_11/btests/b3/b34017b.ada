-- B34017B.ADA

-- CHECK THAT IF A NUMERIC TYPE IS DECLARED IN THE VISIBLE PART OF A
-- PACKAGE, IT MAY NOT BE USED AS THE PARENT TYPE OF ANOTHER DERIVED
-- TYPE DEFINITION IN THE SAME VISIBLE PART (INCLUDING IN NESTED
-- PACKAGES).

-- DSJ 4/27/83
-- JBG 9/19/83
-- JRK 1/6/84
-- PWB 11/25/86  SPLIT FROM B34017A.  THIS TEST INCLUDES NUMERIC TYPE
--               DEFINITIONS.  THE LMP HAS NOT YET RULED AS TO WHETHER 
--               NUMERIC TYPES ARE IN FACT DERIVED TYPES.

PROCEDURE B34017B IS

     PACKAGE P IS
          TYPE T1 IS RANGE 1..10;
          TYPE T2 IS DIGITS 1;
          
          PACKAGE INNER IS

               TYPE IN1 IS NEW T1;               -- ERROR: T1 DERIVED.
               TYPE IN2 IS NEW T2;               -- ERROR: T2 DERIVED.

          PRIVATE
               TYPE PR1 IS NEW T1;               -- ERROR: T1 DERIVED.
               TYPE PR2 IS NEW T2;               -- ERROR: T2 DERIVED.
          END INNER;

          TYPE NT1 IS NEW T1;                    -- ERROR: T1 DERIVED.
          TYPE NT2 IS NEW T2;                    -- ERROR: T2 DERIVED.

     PRIVATE
          TYPE P1 IS NEW T1;                     -- OK.
          TYPE P2 IS NEW T2;                     -- OK.
     END P;


     PACKAGE PACK2 IS

          TYPE T1 IS RANGE 1 .. 255;
          SUBTYPE S1 IS T1;

          TYPE T2 IS NEW T1;                     -- ERROR: T1 DERIVED.
          TYPE T3 IS NEW S1;                     -- ERROR: T1 DERIVED.

          PACKAGE PACK3 IS

               TYPE T3 IS NEW T1;                -- ERROR: T1 DERIVED.

          PRIVATE
               TYPE T4 IS NEW S1;                -- ERROR: T1 DERIVED.
          END PACK3;

     PRIVATE
          TYPE T8 IS NEW T1;                      -- OK.
          TYPE T9 IS NEW S1;                      -- OK.
     END PACK2;

BEGIN
     NULL;
END B34017B;
