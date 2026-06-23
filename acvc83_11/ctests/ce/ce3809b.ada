-- CE3809B.ADA

-- HISTORY:
--     CHECK THAT FIXED I/O GET CAN READ A VALUE FROM A STRING.
--     CHECK THAT END_ERROR IS RAISED WHEN CALLED WITH A NULL STRING
--     OR A STRING CONTAINING SPACES AND/OR HORIZONTAL TABULATION
--     CHARACTERS.  CHECK THAT LAST CONTAINS THE INDEX OF THE LAST
--     CHARACTER READ FROM THE STRING.

-- HISTORY:
--     SPS 10/07/82
--     SPS 12/14/82
--     JBG 12/21/82
--     DWC 09/15/87  ADDED CASE TO INCLUDE ONLY TABS IN STRING AND
--                   CHECKED THAT END_ERROR IS RAISED.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3809B IS
BEGIN

     TEST ("CE3809B", "CHECK THAT FIXED_IO GET " &
                      "OPERATES CORRECTLY ON STRINGS");

     DECLARE
          TYPE FX IS DELTA 0.001 RANGE -2.0 .. 1000.0;
          PACKAGE FXIO IS NEW FIXED_IO (FX);
          USE FXIO;
          X : FX;
          L : POSITIVE;
          STR : STRING (1..10) := "   10.25  ";
     BEGIN

-- LEFT-JUSTIFIED IN STRING, POSITIVE, NO EXPONENT
          BEGIN
               GET ("896.5  ", X, L);
               IF X /= 896.5 THEN
                    FAILED ("FIXED VALUE FROM STRING INCORRECT");
               END IF;
          EXCEPTION
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR RAISED - FIXED - 1");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - FIXED - 1");
          END;

          IF L /= IDENT_INT (5) THEN
               FAILED ("VALUE OF LAST INCORRECT - FIXED - 1.  " &
                       "LAST IS" & INTEGER'IMAGE(L));
          END IF;

-- STRING LITERAL WITH BLANKS
          BEGIN
               GET ("   ", X, L);
               FAILED ("END_ERROR NOT RAISED - FIXED - 2");
          EXCEPTION
               WHEN END_ERROR =>
                    IF L /= 5 THEN
                         FAILED ("AFTER END_ERROR, VALUE OF LAST " &
                                 "INCORRECT - 2.  LAST IS"  &
                                 INTEGER'IMAGE(L));
                    END IF;
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR RAISED - FIXED - 2");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 2");
          END;

-- NULL STRING LITERAL
          BEGIN
               GET ("", X, L);
               FAILED ("END_ERROR NOT RAISED - FIXED - 3");
          EXCEPTION
               WHEN END_ERROR =>
                    IF L /= 5 THEN
                         FAILED ("AFTER END_ERROR, VALUE OF LAST " &
                                 "INCORRECT - 3.  LAST IS"  &
                                 INTEGER'IMAGE(L));
                    END IF;
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR RAISED - FIXED - 3");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 3");
          END;

-- NULL SLICE
          BEGIN
               GET (STR(5..IDENT_INT(2)), X, L);
               FAILED ("END_ERROR NOT RAISED - FIXED - 4");
          EXCEPTION
               WHEN END_ERROR =>
                    IF L /= 5 THEN
                         FAILED ("AFTER END_ERROR, VALUE OF LAST " &
                                 "INCORRECT - 4.  LAST IS"  &
                                 INTEGER'IMAGE(L));
                    END IF;
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR RAISED - FIXED - 4");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 4");
          END;

-- SLICE WITH BLANKS
          BEGIN
               GET (STR(IDENT_INT(9)..10), X, L);
               FAILED ("END_ERROR NOT RAISED - FIXED - 5");
          EXCEPTION
               WHEN END_ERROR =>
                    IF L /= IDENT_INT(5) THEN
                         FAILED ("AFTER END_ERROR, VALUE OF LAST " &
                                 "INCORRECT - 5.  LAST IS"  &
                                 INTEGER'IMAGE(L));
                    END IF;
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR RAISED - FIXED - 5");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 5");
          END;

-- NON-NULL SLICE
          BEGIN
               GET (STR(2..IDENT_INT(8)), X, L);
               IF X /= 10.25 THEN
                    FAILED ("FIXED VALUE INCORRECT - 6");
               END IF;
               IF L /= 8 THEN
                    FAILED ("LAST INCORRECT FOR SLICE - 6.  " &
                            "LAST IS" & INTEGER'IMAGE(L));
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED - 6");
          END;

-- LEFT-JUSTIFIED, POSITIVE EXPONENT
          BEGIN
               GET ("1.34E+02", X, L);
               IF X /= 134.0 THEN
                    FAILED ("FIXED WITH EXP FROM STRING INCORRECT - 7");
               END IF;

               IF L /= 8 THEN
                    FAILED ("VALUE OF LAST INCORRECT - FIXED - 7.  " &
                            "LAST IS" & INTEGER'IMAGE(L));
               END IF;
          EXCEPTION
               WHEN DATA_ERROR =>
                    FAILED ("DATA_EROR RAISED - FIXED - 7");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - FIXED - 7");
          END;

-- RIGHT-JUSTIFIED, NEGATIVE EXPONENT
          BEGIN
               GET (" 25.0E-2", X, L);
               IF X /= 0.25 THEN
                    FAILED ("NEG EXPONENT INCORRECT - 8");
               END IF;
               IF L /= 8 THEN
                    FAILED ("LAST INCORRECT - 8.  " &
                            "LAST IS" & INTEGER'IMAGE(L));
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED - 8");
          END;

-- RIGHT-JUSTIFIED, NEGATIVE
          GET ("  -1.50", X, L);
          IF X /= -1.5 THEN
               FAILED ("FIXED IN RIGHT JUSTIFIED STRING INCORRECT - 9");
          END IF;
          IF L /= 7 THEN
               FAILED ("LAST INCORRECT - 9.  " &
                       "LAST IS" & INTEGER'IMAGE(L));
          END IF;

-- HORIZONTAL TAB WITH BLANK
          BEGIN
               GET (" " & ASCII.HT & "2.3E+2", X, L);
               IF X /= 230.0 THEN
                    FAILED ("FIXED WITH TAB IN STRING INCORRECT - 10");
               END IF;
               IF L /= 8 THEN
                    FAILED ("LAST INCORRECT FOR TAB - 10.  " &
                            "LAST IS" & INTEGER'IMAGE(L));
               END IF;
          EXCEPTION
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR FOR STRING WITH TAB - 10");
               WHEN OTHERS =>
                    FAILED ("EXCEPTION FOR STRING WITH TAB - 10");
          END;

-- HORIZONTAL TABS ONLY

          BEGIN
               GET (ASCII.HT & ASCII.HT, X, L);
               FAILED ("END_ERROR NOT RAISED - FIXED - 11");
          EXCEPTION
               WHEN END_ERROR =>
                    IF L /= IDENT_INT(8) THEN
                         FAILED ("AFTER END_ERROR, VALUE OF LAST " &
                                 "INCORRECT - 11.  LAST IS"  &
                                 INTEGER'IMAGE(L));
                    END IF;
               WHEN DATA_ERROR =>
                    FAILED ("DATA_ERROR RAISED - FIXED - 11");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED - 11");
          END;
     END;

     RESULT;

END CE3809B;
