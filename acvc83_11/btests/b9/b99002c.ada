-- B99002C.ADA

-- CHECK THAT COUNT IS NOT ALLOWED WITHIN A PROGRAM UNIT INTERNAL TO A
-- TASK BODY.

-- SPS 1/24/83

PROCEDURE  B99002C  IS
BEGIN

     DECLARE

          TASK TYPE  T_TYPE  IS
               ENTRY  E ;
          END  T_TYPE ;

          TASK BODY  T_TYPE  IS

               PACKAGE T_PACK IS
               END T_PACK;

               GENERIC
               PACKAGE T_GP IS
               END T_GP;

               TASK T1 IS
                    ENTRY E1;
               END T1;

               PROCEDURE T_PROC IS
               BEGIN
                    IF E'COUNT = 4 THEN      -- ERROR: INSIDE PROCEDURE.
                         NULL;
                    END IF;
               END T_PROC;

               PACKAGE BODY T_PACK IS
               BEGIN
                    IF  E'COUNT = 0  THEN    -- ERROR: INSIDE PACKAGE.
                         NULL;
                    END IF;
               END T_PACK;

               PACKAGE BODY T_GP IS
               BEGIN
                    IF E'COUNT = 1 THEN      -- ERROR: INSIDE GENERIC.
                         NULL;
                    END IF;
               END T_GP;

               TASK BODY T1 IS
               BEGIN
                    IF E'COUNT = 1 THEN      -- ERROR: INSIDE TASK.
                         NULL;
                    END IF;
               END T1;

          BEGIN
               NULL;
          END  T_TYPE ;

     BEGIN
          NULL;
     END ;

END  B99002C ;
