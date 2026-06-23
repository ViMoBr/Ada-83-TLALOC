-- C86006E.TST

-- OBJECTIVE:
--     CHECK THAT THE IDENTIFIER FOR ANY ADDITIONAL PREDEFINED INTEGER
--     SUBTYPE IS DECLARED IN THE PACKAGE "STANDARD", ALONG WITH THE
--     OPERATORS OF THE PREDEFINED TYPE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO THOSE IMPLEMENTATIONS WHICH
--     SUPPORT PREDEFINED INTEGER TYPES OTHER THAN INTEGER,
--     LONG_INTEGER, AND SHORT_INTEGER.

--     IF AN ADDITIONAL SUBTYPE IS NOT SUPPORTED THEN THE DECLARATION
--     OF THE VARIABLE "SUPPORT" MUST BE REJECTED.

-- MACRO SUBSTITUTION:
--     $NAME IS THE NAME OF A PREDEFINED INTEGER TYPE OTHER THAN
--     INTEGER, LONG_INTEGER, AND SHORT_INTEGER.

--     THIS TEST MUST BE EXECUTED ONCE FOR EACH INTEGER TYPE OTHER THAN
--     INTEGER, LONG_INTEGER, AND SHORT_INTEGER.

-- HISTORY:
--     DHH 06/14/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C86006E IS

     SUPPORT : $NAME := -4;                     -- N/A => ERROR.

     A, B : STANDARD.$NAME := -2;
     C, D : STANDARD.$NAME := 2;
     E, F : STANDARD.$NAME := 0;
     G : STANDARD.$NAME := 14;
     H : STANDARD.$NAME := 5;

     FUNCTION IDENT_N_INT(X : $NAME) RETURN $NAME IS
     BEGIN
          RETURN $NAME(IDENT_INT(INTEGER(X)));
     END IDENT_N_INT;

BEGIN

     TEST("C86006E", "CHECK THAT THE IDENTIFIER FOR ANY ADDITIONAL " &
                     "PREDEFINED INTEGER TYPE IS DECLARED IN THE " &
                     "PACKAGE ""STANDARD"", ALONG WITH THE OPERATORS " &
                     "OF THE PREDEFINED TYPE");

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

     IF STANDARD."+"(A,B) /= IDENT_N_INT(SUPPORT) THEN
          FAILED("STANDARD.+ FAILED");
     END IF;

     IF STANDARD."-"(A,C) /= IDENT_N_INT(SUPPORT) THEN
          FAILED("STANDARD.- FAILED");
     END IF;

     IF STANDARD."ABS"(A) /= C THEN
          FAILED("STANDARD.ABS FAILED");
     END IF;

     IF STANDARD."/"(C,A) /= IDENT_N_INT(-1) THEN
          FAILED("STANDARD./ FAILED");
     END IF;
-----------------------------------------------------------------------

     IF STANDARD."REM"(IDENT_N_INT(G),IDENT_N_INT(H))
                                                  /=IDENT_N_INT(4) THEN
          FAILED("STANDARD.REM(++=+) FAILED");
     END IF;

     IF STANDARD."REM"(IDENT_N_INT(G),IDENT_N_INT(-H))
                                                  /=IDENT_N_INT(4) THEN
          FAILED("STANDARD.REM(+-=+ FAILED");
     END IF;

     IF STANDARD."REM"(IDENT_N_INT(-G),IDENT_N_INT(H))

                                            /=IDENT_N_INT(SUPPORT) THEN
          FAILED("STANDARD.REM(-+=-) FAILED");
     END IF;

     IF STANDARD."REM"(IDENT_N_INT(-G),IDENT_N_INT(-H))
                                            /=IDENT_N_INT(SUPPORT) THEN
          FAILED("STANDARD.REM(--=-) FAILED");
     END IF;
-----------------------------------------------------------------------

     IF STANDARD."MOD"(IDENT_N_INT(G),IDENT_N_INT(H))
                                                  /=IDENT_N_INT(4) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;

     IF STANDARD."MOD"(IDENT_N_INT(G),IDENT_N_INT(-H))
                                                 /=IDENT_N_INT(-1) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;

     IF STANDARD."MOD"(IDENT_N_INT(-G),IDENT_N_INT(H))
                                                  /=IDENT_N_INT(1) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;

     IF STANDARD."MOD"(IDENT_N_INT(-G),IDENT_N_INT(-H))
                                            /=IDENT_N_INT(SUPPORT) THEN
          FAILED("STANDARD.MOD FAILED");
     END IF;
-----------------------------------------------------------------------

     IF STANDARD."**"(E,2) /= IDENT_N_INT(0) THEN
          FAILED("STANDARD.** FAILED");
     END IF;

     RESULT;

END C86006E;
