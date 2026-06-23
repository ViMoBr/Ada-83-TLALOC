-- BD1B04D.ADA

-- OBJECTIVE:
--     CHECK THAT A 'SMALL CLAUSE FOR T CANNOT FOLLOW THE USE, IN A
--     DECLARATION OF A GENERIC FORMAL TYPE OR OBJECT OF: A SUBTYPE OF
--     T; A RECORD OR ARRAY TYPE WITH A (SUB)COMPONENT OF A SUBTYPE OF
--     T.

-- HISTORY:
--     DHH 04/01/88 CREATED ORIGINAL TEST.

PROCEDURE BD1B04D IS

----------------------- GENERIC FORMAL OBJECTS -----------------------

-- SUBTYPE
     TYPE T IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P IS
          SUBTYPE SUB_T IS T;

          GENERIC
               PT : SUB_T;
          PACKAGE RTN IS
          END RTN;

     END P;
     USE P;

     FOR T'SMALL USE 0.0625;                                 --  ERROR:

-- RECORD COMPONENT
     TYPE T1 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P1 IS
          SUBTYPE SUB_T1 IS T1;

          TYPE REC IS
               RECORD
                    Z : SUB_T1;
               END RECORD;

          GENERIC
               PT : REC;
          PACKAGE RTN IS
          END RTN;

     END P1;
     USE P1;
     FOR T1'SMALL USE 0.0625;                                --  ERROR:

-- RECORD SUBCOMPONENT
     TYPE T2 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P2 IS
          SUBTYPE SUB_T2 IS T2;

          TYPE EC IS
               RECORD
                    Z : SUB_T2;
               END RECORD;

          TYPE REC1 IS
               RECORD
                    Z : EC;
               END RECORD;

          GENERIC
               PT : REC1;
          PACKAGE RTN2 IS
          END RTN2;
     END P2;
     USE P2;

     FOR T2'SMALL USE 0.0625;                                --  ERROR:

-- ARRAY COMPONENT
     TYPE T3 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P3 IS
          SUBTYPE SUB_T3 IS T3;

          TYPE ARR IS ARRAY(1 .. 5) OF SUB_T3;

          GENERIC
               PT : ARR;
          PACKAGE RTN3 IS
          END RTN3;
     END P3;
     USE P3;

     FOR T3'SMALL USE 0.0625;                                --  ERROR:

-- ARRAY SUBCOMPONENT
     TYPE T4 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P4 IS
          SUBTYPE SUB_T4 IS T4;

          TYPE ARR4 IS ARRAY(1 .. 5) OF SUB_T4;
          TYPE ARY IS ARRAY(1 .. 2) OF ARR4;

          GENERIC
              PT : ARY;
          PACKAGE RTN4 IS
          END RTN4;
     END P4;
     USE P4;

     FOR T4'SMALL USE 0.0625;                                --  ERROR:

------------------------ GENERIC FORMAL TYPES ------------------------
     TYPE ENUM IS (A, B);
-- SUBTYPE
     TYPE T5 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P5 IS
          SUBTYPE SUB_T5 IS T5;

          GENERIC
               TYPE PT IS ARRAY(ENUM) OF SUB_T5;
          PACKAGE RTN5 IS
          END RTN5;

     END P5;
     USE P5;

     FOR T5'SMALL USE 0.0625;                           --  ERROR:

-- RECORD COMPONENT
     TYPE T6 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P6 IS
          SUBTYPE SUB_T6 IS T6;

          TYPE REC IS
               RECORD
                    Z : SUB_T6;
               END RECORD;

          GENERIC
               TYPE PT IS ACCESS REC;
          PACKAGE RTN6 IS
          END RTN6;

     END P6;
     USE P6;
     FOR T6'SMALL USE 0.0625;                           --  ERROR:

-- RECORD SUBCOMPONENT
     TYPE T7 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P7 IS
          SUBTYPE SUB_T7 IS T7;

          TYPE EC IS
               RECORD
                    Z : SUB_T7;
               END RECORD;

          TYPE REC1 IS
               RECORD
                    Z : EC;
               END RECORD;

          GENERIC
               TYPE PT IS ARRAY(ENUM) OF REC1;
          PACKAGE RTN7 IS
          END RTN7;

     END P7;
     USE P7;
     FOR T7'SMALL USE 0.0625;                           --  ERROR:

-- ARRAY COMPONENT
     TYPE T8 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P8 IS
          SUBTYPE SUB_T8 IS T8;

          TYPE ARR IS ARRAY(1 .. 5) OF SUB_T8;

          GENERIC
               TYPE PT IS ARRAY(ENUM) OF ARR;
          PACKAGE RTN8 IS
          END RTN8;

     END P8;
     USE P8;
     FOR T8'SMALL USE 0.0625;                           --  ERROR:

-- ARRAY SUBCOMPONENT
     TYPE T9 IS DELTA 0.0625 RANGE 0.0 .. 5.0;

     PACKAGE P9 IS
          SUBTYPE SUB_T9 IS T9;

          TYPE ARR4 IS ARRAY(1 .. 5) OF SUB_T9;
          TYPE ARY IS ARRAY(1 .. 2) OF ARR4;

          GENERIC
               TYPE PT IS ACCESS ARY;
          PACKAGE RTN9 IS
          END RTN9;

     END P9;
     USE P9;
     FOR T9'SMALL USE 0.0625;                           --  ERROR:


BEGIN
     NULL;
END BD1B04D;
