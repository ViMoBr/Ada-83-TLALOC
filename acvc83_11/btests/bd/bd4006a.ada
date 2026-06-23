-- BD4006A.ADA

-- OBJECTIVE:
--     CHECK THAT THE EXPRESSIONS IN ALIGNMENT AND COMPONENT CLAUSES
--     MUST BE STATIC, INTEGER EXPRESSIONS.

-- HISTORY:
--     BCB 04/11/88  CREATED ORIGINAL TEST.

PROCEDURE BD4006A IS

     TYPE REC1 IS RECORD
          NULL;
     END RECORD;

     TYPE REC2 IS RECORD
          INT2 : INTEGER;
     END RECORD;

     TYPE REC3 IS RECORD
          INT3 : INTEGER;
     END RECORD;

     TYPE NEWREC IS RECORD
          NULL;
     END RECORD;

     TYPE NEWREC2 IS RECORD
          INT2 : INTEGER;
     END RECORD;

     TYPE NEWREC3 IS RECORD
          INT3 : INTEGER;
     END RECORD;

     NONSTATIC : INTEGER := 0;

     FOR REC1 USE RECORD AT MOD NONSTATIC;       -- ERROR: NON-STATIC
                                                 -- ALIGNMENT VALUE.
     END RECORD;

     FOR  REC2 USE RECORD AT MOD 8;
          INT2 AT NONSTATIC RANGE 0 .. INTEGER'SIZE-1;
                                                 -- ERROR: NON-STATIC
                                                 -- COMPONENT VALUE.
     END RECORD;

     FOR REC3 USE RECORD AT MOD 16;
          INT3 AT 1 RANGE NONSTATIC .. INTEGER'SIZE-1;
                                                 -- ERROR: NON-STATIC
                                                 -- RANGE VALUE.
     END RECORD;

     FOR NEWREC USE RECORD AT MOD 0.0;           -- ERROR: NON-INTEGER
                                                 -- ALIGNMENT VALUE.
     END RECORD;

     FOR NEWREC2 USE RECORD AT MOD 8;
          INT2 AT 0.0 RANGE 0 .. INTEGER'SIZE-1; -- ERROR: NON-INTEGER
                                                 -- COMPONENT VALUE.
     END RECORD;

     FOR NEWREC3 USE RECORD AT MOD 16;
          INT3 AT 1 RANGE 0.0 .. INTEGER'SIZE-1; -- ERROR: NON-INTEGER
                                                 -- RANGE VALUE.
     END RECORD;

BEGIN
     NULL;
END BD4006A;
