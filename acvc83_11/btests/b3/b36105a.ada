-- B36105A.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN EITHER L OR R ARE NOT NUMERIC LITERALS, NAMED
--     NUMBERS, OR ATTRIBUTES, A DISCRETE RANGE OF THE FORM L .. R IS
--     ILLEGAL WHEN USED IN A CONSTRAINED ARRAY TYPE DEFINITION, A LOOP
--     PARAMETER SPECIFICATION, OR THE DECLARATION OF A FAMILY OF
--     ENTRIES.

-- HISTORY:
--     JBG 05/25/83  CREATED ORIGINAL TEST.
--     BCB 08/01/88  MODIFIED HEADER FORMAT AND INCLUDED CHECKS FOR
--                   OTHER TYPES OF ILLEGAL UNIVERSAL INTEGER
--                   EXPRESSIONS.

PROCEDURE B36105A IS

     TYPE A IS ARRAY (-1..1) OF INTEGER;          -- ERROR: -1.
     TYPE B IS ARRAY (1..+2) OF INTEGER;          -- ERROR: +2.

     TYPE C IS ARRAY(1+3..8) OF INTEGER;          -- ERROR: 1+3.
     TYPE D IS ARRAY(1..8-3) OF INTEGER;          -- ERROR: 8-3.

     TYPE Z IS ARRAY(ABS 1..7) OF INTEGER;        -- ERROR: ABS 1.

     TASK T IS
          ENTRY E(-1..1);                         -- ERROR: -1.
          ENTRY F(0..+4);                         -- ERROR: +4.
          ENTRY G(1*2..5);                        -- ERROR: 1*2.
          ENTRY H(1..6/2);                        -- ERROR: 6/2.
     END T;

     TASK BODY T IS
     BEGIN
          NULL;
     END;

BEGIN

     FOR I IN -1..1                               -- ERROR: -1.
     LOOP
          NULL;
     END LOOP;

     FOR J IN 0..1+0                              -- ERROR: 1+0.
     LOOP
          NULL;
     END LOOP;

     FOR K IN 1-0..5                              -- ERROR: 1-0.
     LOOP
          NULL;
     END LOOP;

END B36105A;
