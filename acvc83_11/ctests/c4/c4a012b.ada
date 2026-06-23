-- C4A012B.ADA

-- OBJECTIVE:
--     CHECK THAT NUMERIC_ERROR (OR CONSTRAINT_ERROR) IS RAISED FOR
--     A UNIVERSAL_REAL EXPRESSION IF DIVISION BY ZERO IS ATTEMPTED.

--     CHECK THAT CONSTRAINT_ERROR OR NUMERIC_ERROR IS RAISED FOR
--     0.0 ** (-1) (OR ANY OTHER NEGATIVE EXPONENT VALUE).

-- HISTORY:
--     RJW 09/04/86  CREATED ORIGINAL TEST.
--     CJJ 09/04/87  ADDED PASS MESSAGE FOR RAISING NUMERIC_ERROR;
--                   MODIFIED CODE TO PREVENT COMPILER OPTIMIZING
--                   OUT THE TEST.
--     JET 12/31/87  ADDED MORE CODE TO PREVENT OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE C4A012B IS

     F : FLOAT;

     I3 : INTEGER := -3;

     SUBTYPE SINT IS INTEGER RANGE -10 .. 10;
     SI5 : CONSTANT SINT := -5;

     FUNCTION IDENT (X:FLOAT) RETURN FLOAT IS
     BEGIN
          IF EQUAL (3,3) THEN
               RETURN X;
          ELSE
               RETURN 1.0;
          END IF;
     END IDENT;

BEGIN

     TEST ( "C4A012B", "CHECK THAT CONSTRAINT_ERROR OR NUMERIC_ERROR " &
                       "IS RAISED FOR " &
                       "0.0 ** (-1) (OR ANY OTHER NEGATIVE EXPONENT " &
                       "VALUE)" );

     BEGIN
          F := IDENT (0.0) ** (-1);
          FAILED ( "THE EXPRESSION '0.0 ** (-1)' DID NOT RAISE " &
                   "AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 1");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 1");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** (-1)' RAISED THE " &
                        "WRONG EXCEPTION" );
     END;

     BEGIN
          F := 0.0 ** (IDENT_INT (-1));
          FAILED ( "THE EXPRESSION '0.0 ** (IDENT_INT (-1))' DID " &
                    "NOT RAISE AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 2");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 2");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** (IDENT_INT (-1))' " &
                        "RAISED THE WRONG EXCEPTION" );
     END;

     BEGIN
          F := 0.0 ** (INTEGER'POS (IDENT_INT (-1)));
          FAILED ( "THE EXPRESSION '0.0 ** " &
                   "(INTEGER'POS (IDENT_INT (-1)))' DID " &
                   "NOT RAISE AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 3");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 3");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** " &
                        "(INTEGER'POS (IDENT_INT (-1)))' RAISED " &
                        "THE WRONG EXCEPTION" );
     END;

     BEGIN
          F := IDENT(0.0) ** I3;
          FAILED ( "THE EXPRESSION '0.0 ** I3' DID NOT RAISE " &
                    "AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 4");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 4");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** I3' RAISED THE " &
                        "WRONG EXCEPTION" );
     END;

     BEGIN
          F := 0.0 ** (IDENT_INT (I3));
          FAILED ( "THE EXPRESSION '0.0 ** (IDENT_INT (I3))' DID " &
                   "NOT RAISE AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 5");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 5");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** (IDENT_INT (I3))' " &
                         "RAISED THE WRONG EXCEPTION" );
     END;

     BEGIN
          F := IDENT (0.0) ** SI5;
          FAILED ( "THE EXPRESSION '0.0 ** SI5' DID NOT RAISE " &
                    "AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 6");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 6");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** SI5' RAISED THE " &
                        "WRONG EXCEPTION" );
     END;

     BEGIN
          F := 0.0 ** (IDENT_INT (SI5));
          FAILED ( "THE EXPRESSION '0.0 ** (IDENT_INT (SI5))' DID " &
                   "NOT RAISE AN EXCEPTION" );
          IF EQUAL ( INTEGER(F), INTEGER(F) ) THEN
               COMMENT ("SHOULDN'T BE HERE!");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - 7");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - 7");
          WHEN OTHERS =>
               FAILED ( "THE EXPRESSION '0.0 ** (IDENT_INT (SI5))' " &
                         "RAISED THE WRONG EXCEPTION" );
     END;

     RESULT;

END C4A012B;
