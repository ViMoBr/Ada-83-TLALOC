-- C64201B.ADA

-- CHECK THAT INITALIZATION OF IN PARAMETERS OF A TASK
-- TYPE IS PERMITTED.
-- (SEE ALSO 7.4.4/T2 FOR TESTS OF LIMITED PRIVATE TYPES.)

-- CVP 5/14/81
-- ABW 7/1/82
-- BHS 7/9/84

WITH REPORT;
PROCEDURE C64201B IS

     USE REPORT;

BEGIN

     TEST( "C64201B" , "CHECK THAT INITIALIZATION OF IN PARAMETERS " &
                       "OF A TASK TYPE IS PERMITTED" );

     DECLARE

          GLOBAL : INTEGER := 10;

          TASK TYPE T_TYPE IS
               ENTRY E (X : IN OUT INTEGER);
          END;

          TSK1, TSK2 : T_TYPE;

          TASK BODY T_TYPE IS
          BEGIN
               ACCEPT E (X : IN OUT INTEGER) DO
                    X := X - 1;
               END E;
               ACCEPT E (X : IN OUT INTEGER) DO
                    X := X + 1;
               END E;
          END T_TYPE;


          PROCEDURE PROC1 (T : T_TYPE := TSK1) IS
          BEGIN
               T.E (X => GLOBAL);
          END PROC1;

          PROCEDURE PROC2 (T : T_TYPE := TSK1) IS
          BEGIN
               T.E (X => GLOBAL);
               IF (GLOBAL /= IDENT_INT(8)) THEN
                    FAILED( "TASK NOT PASSED IN PROC1, " &
                            "DEFAULT TSK1 EMPLOYED" );
               END IF;
          END PROC2;

          PROCEDURE TERM (T : T_TYPE; NUM : CHARACTER) IS
          BEGIN
               IF NOT T'TERMINATED THEN
                    ABORT T;
                    COMMENT ("ABORTING TASK " & NUM);
               END IF;
          END TERM;

     BEGIN

          PROC1(TSK2);
          IF GLOBAL /= 9 THEN
               FAILED ("INCORRECT GLOBAL VALUE AFTER PROC1");
          ELSE
               PROC2;
          END IF;

          TERM(TSK1, '1');
          TERM(TSK2, '2');
     END;

     RESULT;

END C64201B;
