-- C41308C.ADA

-- OBJECTIVE:
--     CHECK F.X, WHERE F IS THE NAME OF A FUNCTION RETURNING A RECORD
--     WITH COMPONENT X, AND X IS ALSO DECLARED WITHIN F, IN THE
--     FOLLOWING CASES:
--          CASE 1 : F.X OCCURS WITHIN F, F IS DECLARED WITHIN AN
--                   ENCLOSING PACKAGE, TASK, OR ACCEPT STATEMENT FOR AN
--                   ENTRY FAMILY THAT IS ALSO NAMED F, AND ONLY THE
--                   INNERMOST F IS VISIBLE (THE FUNCTION SHOULD NOT BE
--                   CALLED).
--          CASE 2 : THE PREFIX HAS A PARAMETER LIST SO THAT IT CAN ONLY
--                   BE PARSED AS A FUNCTION CALL, F.X OCCURS WITHIN F,
--                   F IS DECLARED WITHIN AN ENCLOSING SUBPROGRAM OR
--                   SINGLE ENTRY ACCEPT STATEMENT THAT IS ALSO NAMED F,
--                   AND BOTH F'S ARE VISIBLE (F IS INVOKED).

-- HISTORY:
--     RJW 07/08/86  CREATED ORIGINAL TEST.
--     BCB 08/18/87  CHANGED HEADER TO STANDARD HEADER FORMAT.  INSERTED
--                   THE WORD "ACCEPT" IN THE HEADER FOR CASE 2.
--                   INDENTED FAILED STATEMENT WITHIN AN IF STATEMENT IN
--                   CASE 2.

WITH REPORT; USE REPORT;

PROCEDURE C41308C IS

     TYPE REC IS RECORD
          X : INTEGER := 100;
     END RECORD;

BEGIN

     TEST ( "C41308C", "CHECK F.X, WHERE F IS THE NAME OF A " &
                       "FUNCTION RETURNING A RECORD WITH COMPONENT " &
                       "X, AND X IS ALSO DECLARED WITHIN F" );

-- CASE 1.

     DECLARE -- 1.A.

          PACKAGE F IS END F;

          PACKAGE BODY F IS

               FIRST_CALL : BOOLEAN := TRUE;

               FUNCTION F RETURN REC IS
                    X  : INTEGER := 3;
                    Y  : INTEGER;
                    F1 : REC;
               BEGIN
                    IF FIRST_CALL THEN
                         FIRST_CALL := FALSE;
                         Y := F.X;
                         IF Y /= 3 THEN
                              FAILED ( "EXPANDED NAME 'F.X' " &
                                       "NOT EVALUATED " &
                                       "CORRECTLY IN CASE 1.A" );
                         END IF;
                    END IF;

                    F1.X := IDENT_INT (10);
                    RETURN F1;
               END F;

          BEGIN
               IF F.X /= 10 THEN
                    FAILED( "FUNCTION F NOT CORRECTLY " &
                             "INVOKED IN CASE 1.A" );
               END IF;
          END F;

     BEGIN
          NULL;
     END; -- CASE 1.A.

     DECLARE -- 1.B.

          TASK F IS END F;

          TASK BODY F IS

               FIRST_CALL : BOOLEAN := TRUE;

               FUNCTION F RETURN REC IS
                    X  : INTEGER := 3;
                    Y  : INTEGER;
                    F1 : REC;
               BEGIN
                    IF FIRST_CALL THEN
                         FIRST_CALL := FALSE;
                         Y := F.X;
                         IF Y /= 3 THEN
                              FAILED ( "EXPANDED NAME 'F.X' " &
                                       "NOT EVALUATED " &
                                       "CORRECTLY IN CASE 1.B" );
                         END IF;
                    END IF;

                    F1.X := IDENT_INT (10);
                    RETURN F1;
               END F;

          BEGIN
               IF F.X /= 10 THEN
                    FAILED ( "FUNCTION F NOT CORRECTLY " &
                             "INVOKED IN CASE 1.B" );
               END IF;
          END F;

     BEGIN
          NULL;
     END; -- CASE 1.B.

     DECLARE -- 1.C.

          TASK T IS
               ENTRY F (BOOLEAN);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT F (TRUE) DO
                    DECLARE
                         FIRST_CALL : BOOLEAN := TRUE;

                         FUNCTION F RETURN REC IS
                              X  : INTEGER := 3;
                              Y  : INTEGER;
                              F1 : REC;
                         BEGIN
                              IF FIRST_CALL THEN
                                   FIRST_CALL := FALSE;
                                   Y := F.X;
                                   IF Y /= 3 THEN
                                        FAILED ( "EXPANDED NAME " &
                                                 "'F.X' NOT " &
                                                 "EVALUATED " &
                                                 "CORRECTLY IN " &
                                                 "CASE 1.C" );
                                   END IF;
                              END IF;

                              F1.X := IDENT_INT (10);
                              RETURN F1;
                         END F;
                    BEGIN
                         IF F.X /= 10 THEN
                              FAILED( "FUNCTION F NOT CORRECTLY " &
                                       "INVOKED IN CASE 1.C" );
                         END IF;
                    END;
               END F;
          END T;

     BEGIN
          T.F (TRUE);
     END; -- CASE 1.C.

-----------------------------------------------------------------------

-- CASE 2.

     DECLARE -- 2.A.

          FUNCTION F RETURN REC IS

               F1 : REC;

               FIRST_CALL : BOOLEAN := TRUE;

               FUNCTION F (Z : INTEGER) RETURN REC IS
                    X  : INTEGER := 3;
                    Y  : INTEGER;
                    F1 : REC;
               BEGIN
                    IF FIRST_CALL THEN
                         FIRST_CALL := FALSE;
                         Y := F(7).X;
                         IF Y /= 10 THEN
                              FAILED ( "INNER FUNCTION F NOT INVOKED " &
                                       "CORRECTLY IN CASE 2.A" );
                         END IF;
                    END IF;

                    F1.X := IDENT_INT (10);
                    RETURN F1;
               END F;

          BEGIN
               F1.X := F(5).X * 2;
               RETURN F1;
          END F;

     BEGIN
          IF F.X /= 20 THEN
               FAILED ( "FUNCTION F NOT CORRECTLY INVOKED IN " &
                        "CASE 2.A" );
          END IF;
     END; -- CASE 2.A.

     DECLARE -- 2.B.

          TASK T IS
               ENTRY F;
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT F DO
                    DECLARE

                         FIRST_CALL : BOOLEAN := TRUE;
                         Z : INTEGER;

                         FUNCTION F (Z : INTEGER) RETURN REC IS
                              X  : INTEGER := 3;
                              Y  : INTEGER;
                              F1 : REC;
                         BEGIN
                              IF FIRST_CALL THEN
                                   FIRST_CALL := FALSE;
                                   Y := F (7).X;
                                   IF Y /= 10 THEN
                                        FAILED ( "FUNCTION F " &
                                                 "NOT INVOKED " &
                                                 "CORRECTLY IN CASE " &
                                                 "2.B" );
                                   END IF;
                              END IF;

                              F1.X := IDENT_INT (10);
                              RETURN F1;
                         END F;
                    BEGIN
                         Z := F (1).X;
                    END;
               END F;
          END T;

     BEGIN
          T.F;
     END; -- CASE 2.B.

-----------------------------------------------------------------------

     RESULT;

END C41308C;
