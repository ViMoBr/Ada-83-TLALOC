-- C86006B.ADA

-- OBJECTIVE:
--     CHECK THAT THE IDENTIFIERS "INTEGER, NATURAL, AND POSITIVE" ARE
--     DECLARED IN THE PACKAGE "STANDARD", ALONG WITH THE OPERATORS OF
--     THE TYPE INTEGER.

-- HISTORY:
--     DHH 06/14/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C86006B IS

     A, B : STANDARD.INTEGER := -2;
     C, D : STANDARD.POSITIVE := 2;
     E, F : STANDARD.NATURAL := 0;
BEGIN

     TEST("C86006B", "CHECK THAT THE IDENTIFIERS ""INTEGER, NATURAL, " &
                     "POSITIVE"" ARE DECLARED IN THE PACKAGE " &
                     """STANDARD"", ALONG WITH THE OPERATORS OF THE " &
                     "TYPE INTEGER");

     IF STANDARD."="(A,C) THEN
          FAILED("STANDARD.= FAILED");
     END IF;

     IF STANDARD."/="(C,D) THEN
          FAILED("STANDARD./= FAILED");
     END IF;

     IF STANDARD."<"(C,A) THEN
          FAILED("STANDARD.< FAILED");
     END IF;

     IF STANDARD."<="(D,B) THEN
          FAILED("STANDARD.<= FAILED");
     END IF;

     IF STANDARD.">"(A,E) THEN
          FAILED("STANDARD.> FAILED");
     END IF;

     IF STANDARD.">="(B,F) THEN
          FAILED("STANDARD.>= FAILED");
     END IF;

     IF STANDARD."+"(A,B) /= IDENT_INT(-4) THEN
          FAILED("STANDARD.+ FAILED");
     END IF;

     IF STANDARD."-"(A,C) /= IDENT_INT(-4) THEN
          FAILED("STANDARD.- FAILED");
     END IF;

     IF STANDARD."ABS"(A) /= C THEN
          FAILED("STANDARD.ABS FAILED");
     END IF;

     IF STANDARD."/"(C,A) /= IDENT_INT(-1) THEN
          FAILED("STANDARD./ FAILED");
     END IF;
-----------------------------------------------------------------------
     IF STANDARD."+"(A) /= IDENT_INT(-2) THEN
          FAILED("STANDARD.UNARY + FAILED");
     END IF;

     IF STANDARD."-"(B) /= IDENT_INT(2) THEN
          FAILED("STANDARD.UNARY - FAILED");
     END IF;
-----------------------------------------------------------------------

     IF STANDARD."REM"(IDENT_INT(14),IDENT_INT(5)) /=IDENT_INT(4) THEN
          FAILED("STANDARD.REM(++=+) FAILED");
     END IF;

     IF STANDARD."REM"(IDENT_INT(14),IDENT_INT(-5)) /=IDENT_INT(4) THEN
          FAILED("STANDARD.REM(+-=+ FAILED");
     END IF;

     IF STANDARD."REM"(IDENT_INT(-14),IDENT_INT(5)) /=IDENT_INT(-4) THEN
          FAILED("STANDARD.REM(-+=-) FAILED");
     END IF;

     IF STANDARD."REM"(IDENT_INT(-14),IDENT_INT(-5))
                                                  /=IDENT_INT(-4) THEN
          FAILED("STANDARD.REM(--=-) FAILED");
     END IF;
-----------------------------------------------------------------------

     IF STANDARD."MOD"(IDENT_INT(14),IDENT_INT(5)) /=IDENT_INT(4) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;

     IF STANDARD."MOD"(IDENT_INT(14),IDENT_INT(-5)) /=IDENT_INT(-1) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;

     IF STANDARD."MOD"(IDENT_INT(-14),IDENT_INT(5)) /=IDENT_INT(1) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;

     IF STANDARD."MOD"(IDENT_INT(-14),IDENT_INT(-5))
                                                   /=IDENT_INT(-4) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;
-----------------------------------------------------------------------

     IF STANDARD."**"(E,D) /= IDENT_INT(0) THEN
          FAILED("STANDARD.** FAILED");
     END IF;

     RESULT;

END C86006B;
