-- B34017A.ADA

-- OBJECTIVE:
--     CHECK THAT IF A DERIVED TYPE IS DECLARED IN THE VISIBLE PART OF A
--     PACKAGE, IT MAY NOT BE USED AS THE PARENT TYPE OF ANOTHER DERIVED
--     TYPE DEFINITION IN THE SAME VISIBLE PART (INCLUDING IN NESTED
--     PACKAGES).

-- HISTORY:
--     DSJ 04/27/83
--     JBG 09/19/83
--     JRK 01/06/84
--     PWB 11/25/86  SPLIT CASES FOR NUMERIC TYPES TO B34017B, PENDING
--                   LMP RULING AS TO WHETHER NUMERIC TYPES ARE DERIVED.
--     JET 01/21/88  ADDED CASES IN WHICH PARENT TYPE IS AN ENUMERATION,
--                   ACCESS, AND TASK TYPE.

PROCEDURE B34017A IS

     PACKAGE P IS
          TYPE ARR IS ARRAY (1..2) OF INTEGER;
          TYPE T3 IS NEW ARR;                     -- OK.

          PACKAGE INNER IS

               TYPE IN3 IS NEW T3;                -- ERROR: T3 DERIVED.
               TYPE INARR IS NEW ARR;             -- OK.

          PRIVATE

               TYPE PR3 IS NEW T3;                -- ERROR: T3 DERIVED.
               TYPE PR4 IS NEW ARR;               -- OK.
          END INNER;

          TYPE NT3 IS NEW T3;             -- ERROR: T3 DERIVED.
     PRIVATE
          TYPE P3 IS NEW T3;                      -- OK.
     END P;

     PACKAGE PACK1 IS
          TYPE REC IS
               RECORD
                    C : INTEGER;
               END RECORD;
     END PACK1;

     USE PACK1;

     PACKAGE PACK2 IS

          TYPE T5 IS NEW REC;
          SUBTYPE S5 IS T5;

          TYPE T6 IS NEW T5;                      -- ERROR: USE OF T5.
          TYPE T7 IS NEW S5;                      -- ERROR: USE OF T5.

          PACKAGE PACK4 IS
               TYPE U1 IS NEW T5;                 -- ERROR: USE OF T5.
               TYPE U2 IS NEW S5;                 -- ERROR: USE OF S5.
          END PACK4;

     PRIVATE

          TYPE T10 IS NEW T5;                     -- OK.
          TYPE T11 IS NEW S5;                     -- OK.
     END PACK2;

     PACKAGE PACK3 IS
          TYPE ENUM IS (ZERO, ONE, TWO);
          TYPE DE IS NEW ENUM;                    -- OK.

          PACKAGE INNER IS
               TYPE NDDE IS NEW DE;               -- ERROR: DE DERIVED.
               TYPE NDE IS NEW ENUM;              -- OK.
          PRIVATE
               TYPE NPDDE IS NEW DE;              -- ERROR: DE DERIVED.
               TYPE NPDE IS NEW ENUM;             -- OK.
          END INNER;

          TYPE DDE IS NEW DE;                     -- ERROR: DE DERIVED.
     PRIVATE
          TYPE PDDE IS NEW DE;                    -- OK.
     END PACK3;

     PACKAGE PACK4 IS
          TYPE ACC IS ACCESS INTEGER;
          TYPE DA IS NEW ACC;                     -- OK.

          PACKAGE INNER IS
               TYPE NDDA IS NEW DA;               -- ERROR: DA DERIVED.
               TYPE NDA IS NEW ACC;               -- OK.
          PRIVATE
               TYPE NPDDA IS NEW DA;              -- ERROR: DA DERIVED.
               TYPE NPDA IS NEW ACC;              -- OK.
          END INNER;

          TYPE DDA IS NEW DA;                     -- ERROR: DA DERIVED.
     PRIVATE
          TYPE PDDA IS NEW DA;                    -- OK.
     END PACK4;

     PACKAGE PACK5 IS
          TASK TYPE T IS
          END T;

          TYPE DT IS NEW T;                       -- OK.

          PACKAGE INNER IS
               TYPE NDDT IS NEW DT;               -- ERROR: DT DERIVED.
               TYPE NDT IS NEW T;                 -- OK.
          PRIVATE
               TYPE NPDDT IS NEW DT;              -- ERROR: DT DERIVED.
               TYPE NPDT IS NEW T;                -- OK.
          END INNER;

          TYPE DDT IS NEW DT;                     -- ERROR: DT DERIVED.
     PRIVATE
          TYPE PDDT IS NEW DT;                    -- OK.
     END PACK5;

     PACKAGE BODY PACK5 IS
          TASK BODY T IS
          BEGIN
               NULL;
          END T;
     END PACK5;

BEGIN
     NULL;
END B34017A;
