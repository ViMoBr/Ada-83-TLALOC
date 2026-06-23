-- BC3011B.ADA

-- CHECK THAT WHEN A GENERIC PACKAGE INSTANTIATION CONTAINS DECLARATIONS
-- OF SUBPROGRAMS WITH THE SAME SPECIFICATIONS, THE CALLS TO THE
-- SUBPROGRAMS ARE AMBIGIOUS OUTSIDE THE GENERIC BODY.

-- DAT 9/18/81
-- SPS 5/7/82

PROCEDURE BC3011B IS

     TYPE DINTEGER IS NEW INTEGER;

     GENERIC
          TYPE S IS PRIVATE;
          TYPE T IS PRIVATE;
     PACKAGE P1 IS
          PROCEDURE PR (X : S);
          PROCEDURE PR (X : T);
     END P1;

     PACKAGE BODY P1 IS
          PROCEDURE PR (X : S) IS 
          BEGIN
               NULL;
          END;

          PROCEDURE PR (X : T) IS 
          BEGIN 
               NULL; 
          END;
     END P1;

     PACKAGE I1 IS NEW P1 (INTEGER, CHARACTER); -- OK.
     PACKAGE I2 IS NEW P1 (INTEGER, DINTEGER);  -- OK.
     PACKAGE I3 IS NEW P1 (INTEGER, INTEGER);   -- OK.

BEGIN
     I1.PR(3);                                  -- OK.
     I1.PR('A');                                -- OK.
     I2.PR(3);                                  -- ERROR: 3 UNQUALIFIED
                                                -- IS AMBIGIOUS.
     I2.PR(INTEGER(3));                         -- OK.
     I2.PR(DINTEGER(3));                        -- OK.
     I3.PR(INTEGER(3));                         -- ERROR: AMBIGIOUS
                                                -- REFERENCE TO PR.
END BC3011B;
