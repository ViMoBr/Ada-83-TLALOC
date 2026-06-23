-- C42006A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN A STRING LITERAL OF AN
-- ARRAY TYPE CONTAINS A CHARACTER THAT DOES NOT BELONG TO THE COMPONENT
-- SUBTYPE.

-- SPS 2/22/84

WITH REPORT;
USE REPORT;
PROCEDURE C42006A IS
BEGIN

     TEST ("C42006A", "CHECK THAT THE VALUES OF STRING LITERALS MUST" &
           " BELONG TO THE COMPONENT SUBTYPE.");

     DECLARE

          TYPE CHAR_COMP IS ('A', 'B', 'C', 'D', 'E', 'F');
          SUBTYPE NON_GRAPHIC_CHAR IS CHARACTER 
               RANGE ASCII.NUL .. ASCII.BEL;

          TYPE CHAR_STRING IS ARRAY (POSITIVE RANGE <>) 
               OF CHAR_COMP RANGE 'B'..'C';
          TYPE NON_GRAPHIC_CHAR_STRING IS ARRAY (POSITIVE RANGE <>)
               OF NON_GRAPHIC_CHAR;

          C_STR : CHAR_STRING (1 .. 1);
          C_STR_5 : CHAR_STRING (1 .. 5);
          N_G_STR : NON_GRAPHIC_CHAR_STRING (1 .. 1);

     BEGIN

          BEGIN
               C_STR_5 := "BABCC";      -- 'A' NOT IN COMPONENT SUBTYPE.
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("SOME EXCEPTION RAISED - 1");
          END;

          BEGIN
               C_STR_5 := "BCBCD";      -- 'D' NOT IN COMPONENT SUBTYPE.
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("SOME EXCEPTION RAISED - 2");
          END;

          BEGIN
               N_G_STR := "Z";
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 3");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("SOME EXCEPTION RAISED - 3");
          END;

     END;

     RESULT;

END C42006A;
