-- BD1B06A.ADA

-- OBJECTIVE:
--     CHECK THAT A SIZE CLAUSE FOR T IS ILLEGAL IF AN EXPRESSION IN
--     THE CLAUSE CONTAINS A FORCING OCCURRENCE OF T.

-- HISTORY:
--     DHH 08/19/88 CREATED ORIGINAL TEST.

PROCEDURE BD1B06A IS

     B : BOOLEAN;
BEGIN

-- SUBTYPE
     DECLARE
          TYPE T IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T IS T;

          FOR T'SIZE USE SUB_T'WIDTH;              -- ERROR: ATTRIBUTE.

     BEGIN
          NULL;
     END;

     DECLARE
          TYPE T IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T IS T;

          FOR T'SIZE USE SUB_T'(1);             -- ERROR: QUALIFIED EXP.

     BEGIN
          NULL;
     END;

     DECLARE
          TYPE T IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T IS T;

          FOR T'SIZE USE SUB_T(1);              -- ERROR: EXPLICIT CONV.

     BEGIN
          NULL;
     END;

     DECLARE
          SUBTYPE B IS BOOLEAN;

          TYPE T IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T IS T;

          FOR T'SIZE USE B'POS((1 IN SUB_T));     -- ERROR: MEMBERSHIP.

     BEGIN
          NULL;
     END;


-- RECORD COMPONENT

     DECLARE
          SUBTYPE B IS BOOLEAN;

          TYPE T1 IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T1 IS T1;

          TYPE REC IS
               RECORD
                    Z : SUB_T1;
               END RECORD;

          FOR T1'SIZE USE REC'BASE'SIZE;           -- ERROR: ATTRIBUTE.

      BEGIN
           NULL;
      END;

-- RECORD SUBCOMPONENT
     DECLARE
          SUBTYPE B IS BOOLEAN;

          TYPE T2 IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T2 IS T2;

          TYPE EC IS
               RECORD
                    Z : SUB_T2;
               END RECORD;

          TYPE REC1 IS
               RECORD
                    X : EC;
               END RECORD;

          FOR T2'SIZE USE REC1'BASE'SIZE;          -- ERROR: ATTRIBUTE.

      BEGIN
           NULL;
      END;

-- ARRAY COMPONENT
     DECLARE
          SUBTYPE B IS BOOLEAN;

          TYPE T3 IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T3 IS T3;

          TYPE ARR IS ARRAY(1 .. 5) OF SUB_T3;

          FOR T3'SIZE USE ARR'FIRST;               -- ERROR: ATTRIBUTE.

     BEGIN
          NULL;
     END;

-- ARRAY SUBCOMPONENT
     DECLARE
          SUBTYPE B IS BOOLEAN;

          TYPE T4 IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T4 IS T4;

          TYPE ARR4 IS ARRAY(1 .. 5) OF SUB_T4;
          TYPE ARR IS ARRAY(1 .. 3) OF ARR4;

          FOR T4'SIZE USE ARR'FIRST;         -- ERROR: ATTRIBUTE.

     BEGIN
          NULL;
     END;

-- INDEX SUBTYPE
     DECLARE
          SUBTYPE B IS BOOLEAN;

          TYPE T5 IS NEW INTEGER RANGE 1 .. 10;
          SUBTYPE SUB_T5 IS T5;

          TYPE ARR IS ARRAY(SUB_T5 RANGE 1 .. 5) OF BOOLEAN;

          FOR T5'SIZE USE ARR'FIRST;                -- ERROR: ATTRIBUTE.

     BEGIN
          NULL;
     END;

END BD1B06A;
