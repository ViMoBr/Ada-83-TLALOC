-- A83A06A.ADA


-- CHECK THAT A STATEMENT LABEL INSIDE A BLOCK BODY CAN BE THE
--    SAME AS A VARIABLE, CONSTANT, NAMED LITERAL, SUBPROGRAM,
--    ENUMERATION LITERAL, TYPE, OR PACKAGE DECLARED IN THE
--    ENCLOSING BODY.


-- RM 02/12/80
-- JBG 5/16/83
-- JBG 8/21/83
-- JRK 12/19/83

WITH REPORT; USE REPORT;
PROCEDURE  A83A06A  IS

     LAB_VAR            :  INTEGER;
     LAB_CONST          :  CONSTANT INTEGER := 12;
     LAB_NAMEDLITERAL   :  CONSTANT := 13;
     TYPE  ENUM  IS        ( AA , BB , LAB_ENUMERAL );
     TYPE  LAB_TYPE  IS    NEW INTEGER;

     PROCEDURE  LAB_PROCEDURE  IS
     BEGIN
          NULL;
     END LAB_PROCEDURE;

     FUNCTION  LAB_FUNCTION  RETURN INTEGER  IS
     BEGIN
          RETURN 7;
     END LAB_FUNCTION;

     PACKAGE  LAB_PACKAGE  IS
          INT : INTEGER;
     END LAB_PACKAGE;

BEGIN

     TEST ("A83A06A", "CHECK THAT STATEMENT LABELS INSIDE A BLOCK " &
                      "BODY CAN BE THE SAME AS IDENTIFIERS DECLARED "&
                      "OUTSIDE THE BODY");

     LAB_BLOCK_1 :   BEGIN  NULL;  END     LAB_BLOCK_1;

     LAB_LOOP_1  :   LOOP   EXIT;  END LOOP LAB_LOOP_1;

     BEGIN

          << LAB_VAR >>                    -- OK.
               BEGIN NULL; END;
          << LAB_ENUMERAL >>        NULL;  -- OK.

     << LAB_PROCEDURE >>                   -- OK.
          FOR  I  IN  INTEGER  LOOP
               << LAB_CONST >>      NULL;  -- OK.
               << LAB_TYPE >>       NULL;  -- OK.
               << LAB_FUNCTION >>   EXIT;  -- OK.
          END LOOP;

          << LAB_NAMEDLITERAL >>    NULL;  
          << LAB_PACKAGE >>         NULL;  
     END;

     LAB_BLOCK_2 :                          -- OK.
          BEGIN  NULL;  END LAB_BLOCK_2;

     LAB_LOOP_2  :                          -- OK.
          LOOP   EXIT;  END LOOP LAB_LOOP_2;

     RESULT;

END A83A06A;
