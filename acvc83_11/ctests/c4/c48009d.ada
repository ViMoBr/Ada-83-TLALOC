-- C48009D.ADA

-- FOR ALLOCATORS OF THE FORM "NEW T'(X)", CHECK THAT CONSTRAINT_ERROR
-- IS RAISED IF T IS AN UNCONSTRAINED ARRAY TYPE WITH INDEX SUBTYPE(S)
-- S,
--   1) X HAS TOO MANY VALUES FOR S;
--   2) A NAMED NON-NULL BOUND OF X LIES OUTSIDE S'S RANGE;
--   3) THE BOUND'S OF X ARE NOT EQUAL TO BOUNDS SPECIFIED FOR THE
--      ALLOCATOR'S DESIGNATED BASE TYPE. (THEY ARE EQUAL TO THE BOUNDS
--      SPECIFIED FOR T).

-- RM  01/08/80
-- NL  10/13/81
-- SPS 10/26/82
-- JBG 03/03/83
-- EG  07/05/84

WITH REPORT;

PROCEDURE  C48009D  IS

     USE REPORT ;

BEGIN

     TEST("C48009D","FOR ALLOCATORS OF THE FORM 'NEW T'(X)', CHECK " &
                    "THAT CONSTRAINT_ERROR IS RAISED WHEN "          &
                    "APPROPRIATE - UNCONSTRAINED ARRAY TYPES");
     DECLARE

          SUBTYPE TWO  IS INTEGER RANGE 1 .. 2;
          SUBTYPE TWON IS INTEGER RANGE IDENT_INT(1) .. IDENT_INT(2);
          TYPE UA  IS ARRAY(INTEGER RANGE <>) OF INTEGER;
          TYPE TD  IS ARRAY(TWO  RANGE <>) OF INTEGER RANGE 1 .. 7;
          TYPE TDN IS ARRAY(TWON RANGE <>) OF INTEGER RANGE 1 .. 7;
          TYPE ATD  IS ACCESS TD;
          TYPE ATDN IS ACCESS TDN;
          TYPE A_UA IS ACCESS UA;
          TYPE A_CA IS ACCESS UA(3 .. 4);
          TYPE A_CAN IS ACCESS UA(4 .. 3);
          VD  : ATD;
          VDN : ATDN;
          V_A_CA : A_CA;
          V_A_CAN : A_CAN;

     BEGIN

          BEGIN
               VD := NEW TD'(3, 4, 5);
               FAILED ("NO EXCEPTION RAISED - CASE 1A");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>  
                    NULL;
               WHEN OTHERS =>  
                    FAILED ("WRONG EXCEPTION RAISED - CASE 1A");
          END;

          BEGIN
               VDN := NEW TDN'(3, 4, 5);
               FAILED ("NO EXCEPTION RAISED - CASE 1B");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 1B");
          END;

          BEGIN
               VD := NEW TD'(IDENT_INT(0) .. 2 => 6);
               FAILED ("NO EXCEPTION RAISED - CASE 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    NULL;
               WHEN OTHERS =>  
                    FAILED ("WRONG EXCEPTION RAISED - CASE 2");
          END;

          BEGIN
               V_A_CA := NEW UA'(2 .. 3 => 3);
               FAILED ("NO EXCEPTION RAISED - CASE 3A");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3A");
          END;

          BEGIN
               V_A_CAN := NEW UA'(IDENT_INT(3) .. IDENT_INT(2) => 3);
               FAILED ("NO EXCEPTION RAISED - CASE 3B");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3B");
          END;

     END;

     RESULT;

END C48009D;
