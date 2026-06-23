-- C48009E.ADA

-- FOR ALLOCATORS OF THE FORM "NEW T'(X)", CHECK THAT CONSTRAINT_ERROR
-- IS RAISED IF T IS A CONSTRAINED ARRAY TYPE AND:
--   1) A NAMED NULL OR NON-NULL BOUND FOR X DOES NOT EQUAL THE
--      CORRESPONDING BOUND FOR T;
--   2) A BOUND OF T DOES NOT EQUAL THE CORRESPONDING VALUE SPECIFIED IN
--      THE DECLARATION OF THE ALLOCATOR'S BASE TYPE; 
--   3) A POSITIONAL AGGREGATE DOES NOT HAVE THE NUMBER OF COMPONENTS
--      REQUIRED BY T OR BY THE ALLOCATOR'S BASE TYPE. 

-- RM  01/08/80
-- NL  10/13/81
-- SPS 10/26/82
-- JBG 03/03/83
-- EG  07/05/84

WITH REPORT;

PROCEDURE  C48009E  IS

     USE REPORT ;

BEGIN

     TEST("C48009E","FOR ALLOCATORS OF THE FORM 'NEW T'(X)', CHECK " &
                    "THAT CONSTRAINT_ERROR IS RAISED WHEN "          &
                    "APPROPRIATE - CONSTRAINED ARRAY TYPES");
     DECLARE

          TYPE UA IS ARRAY(INTEGER RANGE <>) OF INTEGER;
          TYPE CA3_2 IS ARRAY(3 .. 2) OF INTEGER;
          TYPE SA1_3 IS ARRAY(1 .. 3) OF INTEGER;
          TYPE NA1_3 IS ARRAY(1 .. IDENT_INT(3)) OF INTEGER;
          SUBTYPE CA2_6 IS UA(2 .. 6);
          SUBTYPE CA1_4 IS UA(1 .. 4);
          SUBTYPE CA1_6 IS UA(1 .. 6);
          SUBTYPE CA4_1 IS UA(4 .. 1);
          SUBTYPE CA4_2 IS UA(4 .. 2);

          TYPE A_CA3_2 IS ACCESS CA3_2;
          TYPE A_SA1_3 IS ACCESS SA1_3;
          TYPE A_NA1_3 IS ACCESS NA1_3;
          TYPE A_CA1_5 IS ACCESS UA(1 .. 5);
          TYPE A_CA4_2 IS ACCESS CA4_2;

          V_A_CA3_2 : A_CA3_2;
          V_A_SA1_3 : A_SA1_3;
          V_A_NA1_3 : A_NA1_3;
          V_A_CA1_5 : A_CA1_5;

          FUNCTION ALLOC1(X : CA2_6) RETURN A_CA1_5 IS
          BEGIN
               IF EQUAL(1, 1) THEN
                    RETURN NEW CA2_6'(X);
               ELSE
                    RETURN NULL;
               END IF;
          END ALLOC1;
          FUNCTION ALLOC2(X : CA4_1) RETURN A_CA4_2 IS
          BEGIN
               IF EQUAL(1, 1) THEN
                    RETURN NEW CA4_1'(X);
               ELSE
                    RETURN NULL;
               END IF;
          END ALLOC2;

     BEGIN

          BEGIN
               V_A_CA3_2 := NEW CA3_2'(IDENT_INT(4) .. IDENT_INT(2)
                                       => 5);
               FAILED ("NO EXCEPTION RAISED - CASE 1A");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 1A");
          END;

          BEGIN
               V_A_NA1_3 := NEW NA1_3'(1 .. IDENT_INT(2) => 4);
               FAILED ("NO EXCEPTION RAISED - CASE 1B");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 1B");
          END;

          BEGIN
               IF ALLOC1((2 .. 6 => 2)) = NULL THEN
                    FAILED ("IMPOSSIBLE - CASE 2A");
               END IF;
               FAILED ("NO EXCEPTION RAISED - CASE 2A");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 2A");
          END;

          BEGIN
               IF ALLOC2((4 .. 1 => 3)) = NULL THEN
                    FAILED ("IMPOSSIBLE - CASE 2B");
               END IF;
               FAILED ("NO EXCEPTION RAISED - CASE 2B");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 2B");
          END;

          BEGIN
               V_A_SA1_3 := NEW SA1_3'(1, 2);
               FAILED ("NO EXCEPTION RAISED - CASE 3A");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>  
                    NULL;
               WHEN OTHERS =>  
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3A");
          END;

          BEGIN
               V_A_SA1_3 := NEW SA1_3'(3, 4, 5, 6);
               FAILED ("NO EXCEPTION RAISED - CASE 3B");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>  
                    NULL;
               WHEN OTHERS =>  
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3B");
          END;

          BEGIN
               V_A_NA1_3 := NEW NA1_3'(1, 2);
               FAILED ("NO EXCEPTION RAISED - CASE 3C");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>  
                    NULL;
               WHEN OTHERS =>  
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3C");
          END;

          BEGIN -- SATISFIES T BUT NOT BASE TYPE.
               V_A_CA1_5 := NEW CA1_4'(1, 2, 3, 4);
               FAILED ("NO EXCEPTION RAISED - CASE 3D");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>  
                    NULL;
               WHEN OTHERS =>  
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3D");
          END;

          BEGIN -- SATISFIES T BUT NOT BASE TYPE.
               V_A_CA1_5 := NEW CA1_6'(1, 2, 3, 4, 5, 6);
               FAILED ("NO EXCEPTION RAISED - CASE 3E");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3E");
          END;

          BEGIN -- SATISFIES BASE TYPE BUT NOT T.
               V_A_CA1_5 := NEW CA1_4'(1, 2, 3, 4, 5);
               FAILED ("NO EXCEPTION RAISED - CASE 3F");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3F");
          END;

          BEGIN -- SATISFIES BASE TYPE BUT NOT T.
               V_A_CA1_5 := NEW CA1_6'(1, 2, 3, 4, 5);
               FAILED ("NO EXCEPTION RAISED - CASE 3G");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CASE 3G");
          END;

     END ;

     RESULT ;

END C48009E ;
