-- C39006B.ADA

-- CHECK THAT PROGRAM_ERROR IS RAISED IF AN ATTEMPT IS MADE TO CALL A
-- SUBPROGRAM WHOSE BODY HAS NOT YET BEEN ELABORATED.  CHECK THE
-- FOLLOWING:
--     B) THE SUBPROGRAM IS CALLED IN A PACKAGE BODY.
--     C) THE SUBPROGRAM IS AN ACTUAL GENERIC PARAMETER CALLED DURING
--        ELABORATION OF THE GENERIC INSTANTIATION.
--     D) THE SUBPROGRAM IS CALLED DURING ELABORATION OF AN OPTIONAL
--        PACKAGE BODY.

-- TBN  8/19/86

WITH REPORT; USE REPORT;
PROCEDURE C39006B IS

BEGIN
     TEST ("C39006B", "CHECK THAT PROGRAM_ERROR IS RAISED IF AN " &
                      "ATTEMPT IS MADE TO CALL A SUBPROGRAM WHOSE " &
                      "BODY HAS NOT YET BEEN ELABORATED");
     BEGIN
          DECLARE
               PACKAGE PACK IS
                    FUNCTION FUN RETURN INTEGER;
                    PROCEDURE PROC (A : IN OUT INTEGER);
               END PACK;

               PACKAGE BODY PACK IS

                    VAR1 : INTEGER := 0;

                    PROCEDURE PROC (A : IN OUT INTEGER) IS
                    BEGIN
                         IF A = IDENT_INT(1) THEN
                              A := A + FUN;
                              FAILED ("PROGRAM_ERROR NOT RAISED - 1");
                         ELSE
                              A := IDENT_INT(1);
                         END IF;
                    EXCEPTION
                         WHEN PROGRAM_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "1");
                    END PROC;

                    PACKAGE INSIDE IS
                    END INSIDE;

                    PACKAGE BODY INSIDE IS
                    BEGIN
                         PROC (VAR1);
                         PROC (VAR1);
                    END INSIDE;

                    FUNCTION FUN RETURN INTEGER IS
                    BEGIN
                         RETURN (IDENT_INT(1));
                    END FUN;

               BEGIN
                    NULL;
               END PACK;

          BEGIN
               NULL;
          END;
     END;

     BEGIN
          DECLARE
               FUNCTION INIT_2 RETURN INTEGER;

               GENERIC
                    WITH FUNCTION FF RETURN INTEGER;
               PACKAGE P IS
                    Y : INTEGER;
               END P;

               GLOBAL_INT : INTEGER := IDENT_INT(1);

               PACKAGE BODY P IS
               BEGIN
                    IF GLOBAL_INT = 1 THEN
                         Y := FF;
                    END IF;
               END P;

               PACKAGE N IS
                    PACKAGE NEW_P IS NEW P(INIT_2);
               END N;

               FUNCTION INIT_2 RETURN INTEGER IS
               BEGIN
                    RETURN (IDENT_INT (1));
               END INIT_2;

          BEGIN
               FAILED ("PROGRAM_ERROR NOT RAISED - 2");
          END;

     EXCEPTION
          WHEN PROGRAM_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 2");
     END;

     DECLARE

          PROCEDURE ADD1 (A : IN OUT INTEGER);

          PACKAGE P IS
               VAR : INTEGER := IDENT_INT(1);
          END P;

          PACKAGE BODY P IS
          BEGIN
               IF VAR = 1 THEN
                    ADD1 (VAR);
                    FAILED ("PROGRAM_ERROR NOT RAISED - 3");
               END IF;
          EXCEPTION
               WHEN PROGRAM_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - 3");
          END P;

          PROCEDURE ADD1 (A : IN OUT INTEGER) IS
          BEGIN
               A := A + IDENT_INT(1);
          END ADD1;

     BEGIN
          NULL;
     END;

     RESULT;
END C39006B;
