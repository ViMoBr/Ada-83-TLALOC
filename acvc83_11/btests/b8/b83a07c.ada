-- B83A07C.ADA

-- OBJECTIVE:
--     CHECK THAT A STATEMENT LABEL IN A PACKAGE BODY
--     CANNOT BE THE SAME AS A BLOCK OR LOOP IDENTIFIER,
--     VARIABLE, CONSTANT, NAMED NUMBER, SUBPROGRAM, TYPE,
--     PACKAGE, EXCEPTION, OR GENERIC UNIT DECLARED IN
--     THE PACKAGE.

-- HISTORY:
--     SDA 09/08/88  CREATED ORIGINAL TEST.

PROCEDURE B83A07C IS

     PACKAGE TST IS
          PROCEDURE PRO;

          PACKAGE PKG IS
               PROCEDURE PROC_2;
          END PKG;
          GENERIC
               TYPE ELEMENT IS PRIVATE;
          PACKAGE PKG_GEN IS
               PROCEDURE PROC (ITEM : IN OUT ELEMENT);
          END PKG_GEN;
     END TST;

     PACKAGE BODY TST IS

          A : INTEGER := 0;
          B : CONSTANT := 5;
          C : CONSTANT INTEGER := 5;
          TYPE D IS (ON,OFF);
          EX : EXCEPTION;

          PROCEDURE PRO IS
          BEGIN
               NULL;
          END PRO;


          PACKAGE BODY PKG_GEN IS

               PROCEDURE PROC (ITEM : IN OUT ELEMENT) IS

               BEGIN
                    NULL;
               END PROC;

          END PKG_GEN;


          PACKAGE BODY PKG IS

               PROCEDURE PROC_2 IS

               BEGIN
                    NULL;
               END PROC_2;

          END PKG;


     BEGIN
          <<EX>>       -- ERROR: EXCEPTION CAN NOT BE USED AS A LABEL.
               NULL;
     L:   LOOP
               EXIT L;
          END LOOP L;
          <<L>>        -- ERROR: LOOP IDENTIFIER CAN NOT BE USED AS A
                       -- LABEL.
               NULL;
          <<A>>        -- ERROR: VARIABLE CAN NOT BE USED AS A LABEL.
               NULL;
          <<B>>        -- ERROR: NAMED NUMBER CAN NOT BE USED AS A
                       -- LABEL.
               NULL;
          <<C>>        -- ERROR: CONSTANT CAN NOT BE USED AS A LABEL.
               NULL;
          <<D>>        -- ERROR: TYPE CAN NOT BE USED AS A LABEL.
               NULL;
          <<PKG_GEN>>  -- ERROR: GENERIC PACKAGE CAN NOT BE USED AS
                       -- A LABEL.
               NULL;
          <<PKG>>      -- ERROR: PACKAGE CAN NOT BE USED AS A LABEL.
               NULL;
          <<PRO>>      -- ERROR: SUBPROGRAM CAN NOT BE USED AS A LABEL.
               NULL;
     END TST;

BEGIN
     NULL;
END B83A07C;
