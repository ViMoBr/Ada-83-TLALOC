-- C46014A.ADA

-- OBJECTIVE:
--     FOR PREDEFINED TYPE INTEGER, CHECK THAT NUMERIC_ERROR
--     /CONSTRAINT_ERROR IS RAISED IF THE OPERAND VALUE OF A
--     CONVERSION LIES OUTSIDE OF THE RANGE OF THE TARGET TYPE'S BASE
--     TYPE. ALSO, CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE
--     OPERAND VALUE LIES OUTSIDE OF THE RANGE OF THE TARGET TYPE'S
--     SUBTYPE BUT WITHIN THE RANGE OF THE BASE TYPE.

-- HISTORY:
--     RJW 09/08/86  CREATED ORIGINAL TEST.
--     RJW 11/13/87  ADDED CODE TO PREVENT DEAD VARIABLE OPTIMIZATION.
--     JET 12/30/87  ADDED MORE CODE TO PREVENT OPTIMIZATION.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C46014A IS

     SUBTYPE SMALL IS INTEGER RANGE -100 .. 100;
     S1 : SMALL;

     TYPE INT IS RANGE -100 .. 100;
     T1 : INT;

     TYPE NEWINTEGER IS NEW INTEGER;
     N1 : NEWINTEGER;

     SUBTYPE SUBNEW IS NEWINTEGER RANGE -100 .. 100;
     SN : SUBNEW;

     I1 : INTEGER;
     P1 : POSITIVE;
     L1 : NATURAL;

     FUNCTION IDENT (I : INTEGER) RETURN INT IS
     BEGIN
          RETURN INT'VAL (IDENT_INT (I));
     END IDENT;

     FUNCTION IDENT (I : NEWINTEGER) RETURN NEWINTEGER IS
     BEGIN
          RETURN NEWINTEGER'VAL (IDENT_INT (NEWINTEGER'POS (I)));
     END IDENT;

BEGIN
     TEST ( "C46014A", "FOR PREDEFINED TYPE INTEGER, CHECK THAT " &
                       "NUMERIC_ERROR/CONSTRAINT_ERROR IS RAISED IF " &
                       "THE OPERAND VALUE OF A CONVERSION LIES " &
                       "OUTSIDE OF THE RANGE OF THE TARGET TYPE'S " &
                       "BASE TYPE. ALSO, CHECK THAT " &
                       "CONSTRAINT_ERROR IS RAISED IF THE OPERAND " &
                       "VALUE LIES OUTSIDE OF THE RANGE OF THE " &
                       "TARGET TYPE'S SUBTYPE BUT WITHIN THE " &
                       "RANGE OF THE BASE TYPE" );

     BEGIN
          I1 := IDENT_INT(MAX_INT) + 1;
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "MAX_INT + 1" );
          IF EQUAL (I1, I1) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED FOR " &
                         "MAX_INT + 1" );
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED FOR " &
                         "MAX_INT + 1" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "MAX_INT + 1" );
     END;

     BEGIN
          I1 := IDENT_INT(MIN_INT) - 1;
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "MIN_INT - 1" );
          IF EQUAL (I1, I1) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED FOR " &
                         "MIN_INT - 1" );
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED FOR " &
                         "MIN_INT - 1" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "MIN_INT - 1" );
     END;

     BEGIN
          I1 := INTEGER (IDENT_INT (INTEGER'FIRST) - 1);
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "INTEGER (IDENT_INT (INTEGER'FIRST) - 1)" );
          IF EQUAL (I1, I1) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED FOR " &
                         "INTEGER (IDENT_INT (INTEGER'FIRST - 1)" );
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED FOR " &
                         "INTEGER (IDENT_INT (INTEGER'FIRST - 1)" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "INTEGER (IDENT_INT (INTEGER'FIRST - 1)" );
     END;

     BEGIN
          N1 := NEWINTEGER (IDENT_INT (INTEGER'LAST) + 1);
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "NEWINTEGER (IDENT_INT (INTEGER'LAST) + 1)" );
          IF EQUAL (INTEGER (N1), INTEGER (N1)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED FOR " &
                         "NEWINTEGER (IDENT_INT (INTEGER'LAST + 1)" );
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED FOR " &
                         "NEWINTEGER (IDENT_INT (INTEGER'LAST + 1)" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "NEWINTEGER (IDENT_INT (INTEGER'LAST + 1)" );
     END;

     BEGIN
          T1 := INT (INT'BASE'FIRST - IDENT (1));
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "INT (INT'BASE'FIRST - IDENT (1))" );
          IF EQUAL (INTEGER (T1), INTEGER (T1)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED FOR " &
                         "INT (INT'BASE'FIRST - IDENT (1))" );
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED FOR " &
                         "INT (INT'BASE'FIRST - IDENT (1))" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "INT (INT'BASE'FIRST - IDENT (1))" );
     END;

     BEGIN
          T1 := IDENT (-101);
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "T1 := -101" );
          IF EQUAL (INTEGER (T1), INTEGER (T1)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "T1 := -101" );
     END;

     BEGIN
          T1 := INTEGER'POS (IDENT_INT (101));
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "T1 := INTEGER'POS (IDENT_INT (101))" );
          IF EQUAL (INTEGER (T1), INTEGER (T1)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "T1 := INTEGER'POS (IDENT_INT (101));" );
     END;

     BEGIN
          T1 := INT (IDENT (INTEGER (INT'FIRST)) - 1);
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "INT (INT'FIRST - 1)" );
          IF EQUAL (INTEGER (T1), INTEGER (T1)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "INT (INT'FIRST - 1)" );
     END;

     BEGIN
          T1 := INT (IDENT_INT (101));
          FAILED ( "NO EXCEPTION RAISED FOR INT (101)" );
          IF EQUAL (INTEGER (T1), INTEGER (T1)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INT (101)" );
     END;

     BEGIN
          S1 := SMALL (IDENT_INT (101));
          FAILED ( "NO EXCEPTION RAISED FOR SMALL (101)" );
          IF EQUAL (S1, S1) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR SMALL (101)" );
     END;

     BEGIN
          SN := SUBNEW (IDENT_INT (-101));
          FAILED ( "NO EXCEPTION RAISED FOR SUBNEW (-101)" );
          IF EQUAL (INTEGER (SN), INTEGER (SN)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR SUBNEW (-101)" );
     END;

     BEGIN
          P1 := IDENT_INT (101);
          SN := SUBNEW (P1);
          FAILED ( "NO EXCEPTION RAISED FOR SUBNEW (P1)" );
          IF EQUAL (INTEGER (SN), INTEGER (SN)) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR SUBNEW (P1)" );
     END;

     BEGIN
          SN := IDENT (0);
          P1 := POSITIVE (SN);
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "POSITIVE (SN)" );
          IF EQUAL (P1, P1) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "POSITIVE (SN)" );
     END;

     BEGIN
          N1 := IDENT (-1);
          L1 := NATURAL (N1);
          FAILED ( "NO EXCEPTION RAISED FOR " &
                   "NATURAL (N1)" );
          IF EQUAL (L1, L1) THEN
               COMMENT ("SHOULDN'T GET HERE");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "NATURAL (N1)" );
     END;

     RESULT;
END C46014A;
