-- B32201A.ADA


-- (A) CHECK THAT THE FOLLOWING ATTRIBUTES CANNOT APPEAR IN A NUMBER
--    DECLARATION:
--
--    (A1) BECAUSE THEY ARE NOT OF TYPE UNIVERSAL INTEGER:
--
--        'ADDRESS       'FIRST         'VALUE         'PRED
--        'MACHINE_OVERFLOWS            'CONSTRAINED   'BASE
--        'LAST          'SUCC          'IMAGE         'VAL
--        'MACHING_ROUNDS               'RANGE         'TERMINATED
--
--    (A2) BECAUSE THEY ARE NOT STATIC:
--
--        'LAST_BIT      'FIRST_BIT     'COUNT         'LENGTH
--        'POSITION      'STORAGE_SIZE
--
--    (A3) BECAUSE THEY ARE NOT STATIC FOR NON-STATIC (SCALAR) SUBTYPES:
--
--        'POS           'SIZE
--
--    (A4) BECAUSE IT IS NOT STATIC IF THE ARG IS NOT STATIC:
--
--        'POS
--
-- (B) CHECK THAT A USER-DEFINED FUNCTION, A USER-DEFINED OPERATOR, OR
--    THE OPERATOR  '&'  CANNOT APPEAR IN A NUMBER DECLARATION.
--
-- (C) CHECK THAT A STRING LITERAL OR CHARACTER LITERAL CANNOT APPEAR
--    IN A NUMBER DECLARATION.


-- RM  03/02/81
-- VKG 01/05/83
-- SPS 2/4/83

WITH SYSTEM; USE SYSTEM;
PROCEDURE  B32201A  IS
BEGIN


     -------------------------------------------------------------------
     --------------------  ATTRIBUTES ON THE LIST  ---------------------

     DECLARE

          MY_ADDRESS  : CONSTANT :=  B32201A'ADDRESS;       -- ERROR: A1
          A02         : CONSTANT :=  INTEGER'BASE'FIRST;    -- ERROR: A1
          A03         : CONSTANT :=  INTEGER'SIZE;          -- OK.
          A04         : CONSTANT :=  INTEGER'FIRST;         -- ERROR: A1
          A05         : CONSTANT :=  INTEGER'LAST;          -- ERROR: A1
          TYPE  ARRAY1   IS  ARRAY( 1..3 ) OF INTEGER;
          A06         : CONSTANT :=  ARRAY1'FIRST;          -- ERROR: A1
          A07         : CONSTANT :=  ARRAY1'LAST;           -- ERROR: A1
          A101        : CONSTANT :=  INTEGER'POS(17);       -- OK.
          A102        : CONSTANT :=  CHARACTER'POS('B');    -- OK.
          A11         : CONSTANT :=  INTEGER'VAL(17);       -- ERROR: A1
          A12         : CONSTANT :=  INTEGER'PRED(17);      -- ERROR: A1
          A13         : CONSTANT :=  INTEGER'SUCC(17);      -- ERROR: A1
          A14         : CONSTANT :=  BOOLEAN'POS(
                                 FLOAT'MACHINE_ROUNDS );    -- OK.
          A15         : CONSTANT :=  BOOLEAN'POS(
                                 FLOAT'MACHINE_OVERFLOWS);  -- OK.
          A16         : CONSTANT :=  ARRAY1'LENGTH;         -- ERROR: A2
          A17         : CONSTANT :=  ARRAY1'RANGE'SIZE;     -- ERROR: 
                                           -- ARRAY1'RANGE NOT A SUBTYPE
          TYPE  R ( A :  INTEGER ) IS  RECORD NULL; END RECORD;
          R1          :  R(3);
          A181        : CONSTANT :=  BOOLEAN'POS(
                                 R1'CONSTRAINED );          -- ERROR: A4
          A182        : CONSTANT :=  R1'CONSTRAINED;        -- ERROR: A1
          A19         : CONSTANT :=  R1.A'POSITION;         -- ERROR: A2
          A20         : CONSTANT :=  R1.A'FIRST_BIT;        -- ERROR: A2
          A21         : CONSTANT :=  R1.A'LAST_BIT;         -- ERROR: A2
          TYPE  ACC1  IS ACCESS INTEGER;
          A22         : CONSTANT :=  ACC1'STORAGE_SIZE;     -- ERROR: A2

          TASK  TSK1  IS
               ENTRY  E1;
          END TSK1;

          A23         : CONSTANT :=  TSK1'STORAGE_SIZE;     -- ERROR: A2
          A24         : CONSTANT :=  BOOLEAN'POS(
                                 TSK1'TERMINATED );         -- ERROR: A4

          SUBTYPE L IS INTEGER RANGE 
               BOOLEAN'POS (R1'CONSTRAINED) .. 5;           -- NONSTATIC

          A26         : CONSTANT := L'POS (0);              -- ERROR: A3
          A27         : CONSTANT := L'SIZE;                 -- ERROR: A3

          TASK BODY  TSK1  IS
               A25    : CONSTANT :=  E1'COUNT;              -- ERROR: A2
          BEGIN
               ACCEPT  E1;
          END TSK1;

     BEGIN

          NULL;

     END;


     -------------------------------------------------------------------
     ------------------------  OPERATORS  ------------------------------

     DECLARE

          TYPE  ARR  IS  ARRAY(1..2) OF INTEGER;
          SUBTYPE LARGEINT IS INTEGER RANGE 0..INTEGER'LAST;
          NULL_SLICE  :  ARR  := ( 7 , 11 );       -- TO BE SLICED LATER
          
          FUNCTION  RECURSIVE_MINUS
                         ( P , Q : LARGEINT )
                    RETURN  LARGEINT IS
          BEGIN
               IF  P >= Q  THEN
                    RETURN  STANDARD."-"( P , Q );
               ELSE
                    RETURN  0;
               END IF;
          END;

          FUNCTION  "-"
                         ( P , Q : LARGEINT )
                    RETURN  LARGEINT IS
          BEGIN
               IF  P >= Q  THEN
                    RETURN  STANDARD."-"( P , Q );
               ELSE
                    RETURN  0;
               END IF;
          END;

     BEGIN

          DECLARE

               B1   : CONSTANT :=  RECURSIVE_MINUS(21,23);  -- ERROR: B
               B2   : CONSTANT :=  7 + 5 - 19;              -- OK
               B3   : CONSTANT :=  17 & NULL_SLICE(1..0);   -- ERROR: B

          BEGIN
               NULL;
          END;

     END;


     -------------------------------------------------------------------
     ------------  STRING LITERALS, CHARACTER LITERALS  ----------------

     DECLARE

          C1          : CONSTANT :=  "ABRACADABRA";         -- ERROR: C
          C2          : CONSTANT :=  'A';                   -- ERROR: C
          C3          : CONSTANT :=  ASCII.DEL;             -- ERROR: C

     BEGIN

          NULL;

     END;

     -------------------------------------------------------------------


END B32201A;
