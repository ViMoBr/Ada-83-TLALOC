-- B83011B.ADA

-- OBJECTIVE:
--     CHECK THAT WITHIN THE DECLARATION OF A SUBPROGRAM, OR GENERIC
--     SUBPROGRAM, THE DECLARED ENTITY IS NOT VISIBLE, EITHER DIRECTLY
--     OR BY SELECTION.
--     INCLUDE CHECKS OF SUBPROGRAM AND ENTRY RENAMING DECLARATIONS.

-- HISTORY:
--     VCL  04/14/88  CREATED ORIGINAL TEST.

PROCEDURE B83011B IS
     PACKAGE INNER IS
          TYPE SP1 IS RANGE 0 .. 10;
          SP2 : CONSTANT := 5;
          TYPE SP3 IS RANGE 0 .. 10;
          TYPE SP5 IS RANGE 0 .. 10;
          SP6 : CONSTANT := 5;
          TYPE SP7 IS RANGE 0 .. 10;

          PROCEDURE RD1;
          TASK TX1 IS
               ENTRY RD3;
          END TX1;
     END INNER;
     USE INNER;

     PROCEDURE SP1 (P1 : SP1);                            -- ERROR: SP1.
     PROCEDURE SP2 (P1 : INTEGER := SP2);                 -- ERROR: SP2.
     FUNCTION SP3 (P1 : STRING) RETURN SP3;               -- ERROR: SP3.
     FUNCTION SP4 (P1 : FLOAT := B83011B.SP4(5.0))        -- ERROR: SP4.
                   RETURN FLOAT;

     GENERIC
     PROCEDURE SP5 (P1 : SP5);                            -- ERROR: SP5.
     GENERIC
     PROCEDURE SP6 (P1 : INTEGER := SP6);                 -- ERROR: SP6.
     GENERIC
     FUNCTION SP7 (P1 : STRING) RETURN SP7;               -- ERROR: SP7.
     GENERIC
     FUNCTION SP8 (P1 : FLOAT := B83011B.SP8(5.0))        -- ERROR: SP8.
                   RETURN FLOAT;

     PROCEDURE RD1 RENAMES RD1;                           -- ERROR: RD1.
     PROCEDURE RD2 RENAMES B83011B.RD2;                   -- ERROR: RD2.
     PROCEDURE RD3 RENAMES RD3;                           -- ERROR: RD3.

     -- REQUIRED BODIES FOR THE ABOVE DECLARATIONS.

     PACKAGE BODY INNER IS
          PROCEDURE RD1 IS
          BEGIN
               NULL;
          END RD1;

          TASK BODY TX1 IS
          BEGIN
               NULL;
          END TX1;
     END INNER;

     PROCEDURE SP1 (P1 : SP1) IS                -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END SP1;
     PROCEDURE SP2 (P1 : INTEGER := SP2) IS     -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END SP2;
     FUNCTION SP3 (P1 : STRING) RETURN SP3 IS   -- OPTIONAL ERR MESSAGE.
     BEGIN
          RETURN 3;
     END SP3;
     FUNCTION SP4 (P1 : FLOAT := B83011B.SP4(5.0))       -- OPTIONAL ERR
                   RETURN FLOAT IS                       -- MESSAGE.
     BEGIN
         RETURN P1 * 1.0;
     END SP4;

     PROCEDURE SP5 (P1 : SP5) IS                -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END SP5;
     PROCEDURE SP6 (P1 : INTEGER := SP6) IS     -- OPTIONAL ERR MESSAGE.
     BEGIN
          NULL;
     END SP6;
     FUNCTION SP7 (P1 : STRING) RETURN SP7 IS   -- OPTIONAL ERR MESSAGE.
     BEGIN
          RETURN 3;
     END SP7;
     FUNCTION SP8 (P1 : FLOAT := B83011B.SP8(5.0))       -- OPTIONAL ERR
                   RETURN FLOAT IS                       -- MESSAGE.
     BEGIN
         RETURN P1 * 1.0;
     END SP8;
BEGIN
     NULL;
END B83011B;
