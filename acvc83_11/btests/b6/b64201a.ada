-- B64201A.ADA

-- CHECK THAT AGGREGATES ARE NOT ALLOWED IN DEFAULT EXPRESSIONS
-- FOR IN PARAMETERS OF A LIMITED TYPE, INCLUDING:
--    (A) LIMITED PRIVATE TYPES, AND
--    (B) TASK TYPES OR COMPOSITE TYPES HAVING AT LEAST ONE SUBCOMPONENT
--        OF A TASK TYPE. 

-- INITIALIZATION IS OTHERWISE ALLOWED FOR SUCH TYPES.


-- CVP 5/14/81
-- JBG 6/9/83
-- BHS 7/03/84

PROCEDURE B64201A IS
BEGIN

     DECLARE  -- (A)
          PACKAGE PKG IS

               TYPE LPTYPE IS LIMITED PRIVATE;
               CLP  : CONSTANT LPTYPE;

          PRIVATE

               TYPE LPTYPE IS NEW INTEGER RANGE 0..127;
               CLP  : CONSTANT LPTYPE := 127;
          END PKG;

          USE PKG;
     
          TYPE RECTYPE IS
               RECORD
                    F : LPTYPE;
               END RECORD;

          TYPE ATYPE IS ARRAY (1..2) OF LPTYPE;

          PROCEDURE P1 (X : IN LPTYPE := 7) IS      -- ERROR: 7.
          BEGIN
               NULL;
          END P1;

          PROCEDURE P2 (X : IN LPTYPE := CLP) IS    -- OK.
          BEGIN
               NULL;
          END P2;

          PROCEDURE P3 (A : ATYPE := (CLP,CLP)) IS  -- ERROR: (CLP,CLP)
          BEGIN
               NULL;
          END P3;

          PROCEDURE P4 (R : RECTYPE := (F=>CLP)) IS -- ERROR: (F=>CLP)
          BEGIN
               NULL;
          END P4;

     BEGIN  -- (A)

          NULL;

     END;   -- (A)



     DECLARE  -- (B)
          TASK TYPE T_TYPE;
     
          TYPE R1_TYPE IS
               RECORD
                    TT : T_TYPE;
               END RECORD;

          TYPE R2_TYPE IS
               RECORD
                    RR : R1_TYPE;
               END RECORD;

          TYPE AT_TYPE IS ARRAY (1 .. 2) OF T_TYPE;
          TYPE AR_TYPE IS ARRAY (1 .. 2) OF R1_TYPE;

          T1 : T_TYPE;
          R1 : R1_TYPE;
          AR1 : AR_TYPE;

          TASK BODY T_TYPE IS
          BEGIN
               NULL;
          END T_TYPE;

          PROCEDURE P1 (TX : T_TYPE := T1) IS           -- OK.
          BEGIN
               NULL;
          END P1;

          PROCEDURE P2 (R1X : R1_TYPE := R1) IS         -- OK.
          BEGIN
               NULL;
          END P2;

          PROCEDURE P3 (R2X : R2_TYPE := (RR=>R1)) IS  -- ERROR: 
                                                       -- (RR=>R1)
          BEGIN
               NULL;
          END P3;

          PROCEDURE P4 (ATX : AT_TYPE := (T1, T1)) IS   -- ERROR: 
                                                        -- (T1, T1)
          BEGIN
               NULL;
          END P4;

          PROCEDURE P5 (ARX : AR_TYPE := (R1, R1)) IS   -- ERROR:
                                                        --  (R1, R1)
          BEGIN
               NULL;
          END P5;

          FUNCTION F6 (ATR : AR_TYPE := AR1)             -- OK.
                      RETURN INTEGER IS
          BEGIN
               RETURN 1;
          END F6;


     BEGIN  -- (B)

          NULL;

     END;   -- (B)


END B64201A;
