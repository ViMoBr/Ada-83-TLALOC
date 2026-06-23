-- BD1B02B.ADA

-- OBJECTIVE:
--     CHECK THAT A COLLECTION SIZE CLAUSE FOR TYPE T CANNOT FOLLOW AN
--     EXPRESSION OR RANGE INCLUDING AN ATTRIBUTE OF: A SUBTYPE OF T; A
--     RECORD OR ARRAY WITH A (SUB)COMPONENT OF A SUBTYPE OF T.

-- HISTORY:
--     DHH 04/01/88 CREATED ORIGINAL TEST.

PROCEDURE BD1B02B IS

-- SUBTYPE

     TYPE TEST IS
          RECORD
               X : INTEGER;
               Y : STRING(1 .. 7);
          END RECORD;
     TYPE T IS ACCESS TEST;

     SUBTYPE SUB_T IS T;

     OBJ : INTEGER := SUB_T'SIZE;
     FOR T'SIZE USE 1024;                    --  ERROR:

-- RECORD COMPONENT
     TYPE TEST1 IS
          RECORD
               X : INTEGER;
               Y : STRING(1 .. 7);
          END RECORD;
     TYPE T1 IS ACCESS TEST1;

     SUBTYPE SUB_T1 IS T1;

     TYPE REC IS
          RECORD
               Z : SUB_T1;
          END RECORD;
     TREC : INTEGER := REC'SIZE;
     FOR T1'SIZE USE 1024;                    --  ERROR:

-- RECORD SUBCOMPONENT
     TYPE TEST2 IS
          RECORD
               X : INTEGER;
               Y : STRING(1 .. 7);
          END RECORD;
     TYPE T2 IS ACCESS TEST2;

     SUBTYPE SUB_T2 IS T2;

     TYPE EC IS
          RECORD
               Z : SUB_T2;
          END RECORD;

     TYPE REC1 IS
          RECORD
               Z : EC;
          END RECORD;
     TREC1 : INTEGER := REC1'SIZE;
     FOR T2'SIZE USE 1024;                    --  ERROR:

-- ARRAY COMPONENT
     TYPE TEST3 IS
          RECORD
               X : INTEGER;
               Y : STRING(1 .. 7);
          END RECORD;
     TYPE T3 IS ACCESS TEST3;

     SUBTYPE SUB_T3 IS T3;

     TYPE ARR IS ARRAY(1 .. 5) OF SUB_T3;
     TARR : INTEGER := ARR'SIZE;
     FOR T3'SIZE USE 1024;                    --  ERROR:

-- ARRAY SUBCOMPONENT
     TYPE TEST4 IS
          RECORD
               X : INTEGER;
               Y : STRING(1 .. 7);
          END RECORD;
     TYPE T4 IS ACCESS TEST4;

     SUBTYPE SUB_T4 IS T4;

     TYPE ARR4 IS ARRAY(1 .. 5) OF SUB_T4;
     TYPE ARY IS ARRAY(1 .. 3) OF ARR4;
     TARY : INTEGER := ARY'SIZE;
     FOR T4'SIZE USE 1024;                    --  ERROR:

BEGIN
     NULL;
END BD1B02B;
