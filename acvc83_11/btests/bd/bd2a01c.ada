-- BD2A01C.ADA

-- OBJECTIVE:
--     CHECK THAT A SIZE SPECIFICATION CANNOT BE GIVEN FOR A NAME
--     DECLARED BY AN OBJECT DECLARATION.

-- HISTORY:
--     DHH 11/01/88 CREATED ORIGINAL TEST.

PROCEDURE BD2A01C IS

     B : INTEGER;
     FOR B'SIZE USE INTEGER'SIZE;                       -- ERROR:

     C : BOOLEAN;
     FOR C'SIZE USE INTEGER'SIZE;                       -- ERROR:

     D : CHARACTER;
     FOR D'SIZE USE CHARACTER'SIZE;                     -- ERROR:

     TASK TYPE T IS
     END T;

     E : T;
     FOR E'SIZE USE 1024;                               -- ERROR:

     TYPE ARR IS ARRAY(1 .. 6) OF INTEGER;
     F : ARR;
     FOR F'SIZE USE 12 * INTEGER'SIZE;                  -- ERROR;

     TYPE REC IS
          RECORD
               Z : INTEGER;
          END RECORD;
     G : REC;
     FOR G'SIZE USE 2 * INTEGER'SIZE;                   -- ERROR:

     TYPE FLT IS DIGITS 5;
     H : FLT;
     FOR H'SIZE USE FLOAT'SIZE;                         -- ERROR:

     I : ARRAY(1 .. 6) OF BOOLEAN;
     FOR I'SIZE USE INTEGER'SIZE;                       -- ERROR:

     TASK BODY T IS
     BEGIN
          NULL;
     END;
BEGIN
     NULL;
END BD2A01C;
