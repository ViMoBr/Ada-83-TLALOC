-- BD1B05E.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION CLAUSE FOR T CANNOT
--     FOLLOW A QUALIFIED EXPRESSION, AN EXPLICIT TYPE
--     CONVERSION, AN ALLOCATION, OR MEMBERSHIP TEST IF THE TYPE MARK
--     IS: A SUBTYPE OF T; A RECORD OR ARRAY TYPE WITH A
--     (SUB)COMPONENT OF A SUBTYPE OF T; AN ARRAY TYPE WITH AN INDEX
--     SUBTYPE OF A SUBTYPE OF T.

-- HISTORY:
--     DHH 06/09/88 CREATED ORIGINAL TEST.

PROCEDURE BD1B05E IS

     INT : INTEGER := 0;
----------------------- QUALIFIED EXPRESSIONS -----------------------

     PACKAGE ENCLOSE IS
     END ENCLOSE;

     PACKAGE BODY ENCLOSE IS
     BEGIN

          DECLARE   -- SUBTYPE
               TYPE T IS (A, B, C);

               PACKAGE P IS
                    SUBTYPE SUB_T IS T;
                    SUBTYPE PT IS T RANGE SUB_T'(A) .. SUB_T'(B);
               END P;
               USE P;
               FOR T USE (A => 1, B =>2, C => 3);             -- ERROR:
          BEGIN
               NULL;
          END;   -- SUBTYPE

          DECLARE   -- RECORD COMPONENT
               TYPE T1 IS (A, B, C);

               PACKAGE P1 IS
                    SUBTYPE SUB_T1 IS T1;

                    TYPE REC IS
                         RECORD
                              Z : SUB_T1;
                         END RECORD;

                    FUNCTION USELESS1(Y : REC := REC'(Z => A))
                                                        RETURN INTEGER;

               END P1;
               USE P1;
               FOR T1 USE (A => 1, B =>2, C => 3);           --  ERROR:

               PACKAGE BODY P1 IS
                    FUNCTION USELESS1(Y : REC := REC'(Z => A))
                                                      RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS1;
               END P1;

          BEGIN
               NULL;
          END;   -- RECORD COMPONENT

          DECLARE   -- RECORD SUBCOMPONENT
               TYPE T2 IS (A, B, C);

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

                    FUNCTION USELESS2(Y : REC1 := REC1'(Z => (Z => A)))
                                                        RETURN INTEGER;

               END P2;
               USE P2;

               FOR T2 USE (A => 1, B =>2, C => 3);           --  ERROR:

               PACKAGE BODY P2 IS
                    FUNCTION USELESS2(Y : REC1 := REC1'(Z => (Z => A)))
                                                      RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS2;
               END P2;

          BEGIN
               NULL;
          END;   -- RECORD SUBCOMPONENT

          DECLARE   -- ARRAY COMPONENT
               TYPE T3 IS (A, B, C);

               PACKAGE P3 IS
                    SUBTYPE SUB_T3 IS T3;

                    TYPE ARR IS ARRAY(1 .. 5) OF SUB_T3;

                    FUNCTION USELESS3(Y : ARR := ARR'(1 .. 5 => (A)))
                                                        RETURN INTEGER;
               END P3;
               USE P3;

               FOR T3 USE (A => 1, B =>2, C => 3);           --  ERROR:

               PACKAGE BODY P3 IS
                    FUNCTION USELESS3(Y : ARR := ARR'(1 .. 5 => (A)))
                                                      RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS3;
               END P3;

          BEGIN
               NULL;
          END;   -- ARRAY COMPONENT

          DECLARE      -- ARRAY SUBCOMPONENT
               TYPE T4 IS (A, B, C);

               PACKAGE P4 IS
                    SUBTYPE SUB_T4 IS T4;

                    TYPE ARR4 IS ARRAY(1 .. 5) OF SUB_T4;
                    TYPE ARY IS ARRAY(1 .. 2) OF ARR4;

                    FUNCTION USELESS4(Y : ARY := ARY'(1 .. 2 =>
                                     (1 .. 5 => (A)))) RETURN INTEGER;
               END P4;
               USE P4;

               FOR T4 USE (A => 1, B =>2, C => 3);           --  ERROR:

               PACKAGE BODY P4 IS
                    FUNCTION USELESS4(Y : ARY := ARY'(1 .. 2 =>
                                   (1 .. 5 => (A)))) RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS4;
               END P4;

          BEGIN
               NULL;
          END;   --   ARRAY SUBCOMPONENT

          DECLARE      -- ARRAY INDEX
               TYPE TA IS (A, B, C);

               PACKAGE PA IS
                    SUBTYPE SUB_TA IS TA;

                    TYPE ARRA IS ARRAY(SUB_TA) OF INTEGER;

                    FUNCTION USELESS5(Y : ARRA := ARRA'(A .. C => (3)))
                                                        RETURN INTEGER;
               END PA;
               USE PA;

               FOR TA USE (A => 1, B =>2, C => 3);          --  ERROR:

               PACKAGE BODY PA IS
                    FUNCTION USELESS5(Y : ARRA := ARRA'(A .. C => (3)))
                                                      RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS5;
               END PA;

          BEGIN
               NULL;
          END;   -- ARRAY INDEX

----------------------- EXPLICIT TYPE CONVERSION -----------------------

          DECLARE   -- SUBTYPE
               TYPE T IS (A, B, C);

               PACKAGE P IS
                    SUBTYPE SUB_T IS T;

                    FUNCTION USELESS(Y : T := SUB_T(A))
                                                      RETURN INTEGER;
               END P;
               USE P;
               FOR T USE (A => 1, B =>2, C => 3);             -- ERROR:

               PACKAGE BODY P IS
                    FUNCTION USELESS(Y : T := SUB_T(A))
                                                      RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS;
               END P;

          BEGIN
               NULL;
          END;   -- SUBTYPE

------------------------------ ALLOCATION ------------------------------

           DECLARE   -- RECORD COMPONENT
               TYPE T1 IS (A, B, C);

               PACKAGE P1 IS
                    SUBTYPE SUB_T1 IS T1;

                    TYPE REC IS
                         RECORD
                              Z : SUB_T1;
                         END RECORD;

                    TYPE PTR IS ACCESS REC;

                    FUNCTION USELESS1(Y : PTR := NEW REC)
                                                        RETURN INTEGER;

               END P1;
               USE P1;
               FOR T1 USE (A => 1, B =>2, C => 3);           --  ERROR:

               PACKAGE BODY P1 IS
                    FUNCTION USELESS1(Y : PTR := NEW REC)
                                                      RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS1;
               END P1;

          BEGIN
               NULL;
          END;   -- RECORD COMPONENT

------------------------------ MEMBERSHIP ------------------------------

          DECLARE   -- ARRAY COMPONENT
               TYPE T3 IS (A, B, C);

               PACKAGE P3 IS
                    SUBTYPE SUB_T3 IS T3;

                    TYPE ARR IS ARRAY(1 .. 5) OF SUB_T3;

                    FUNCTION USELESS3(Y : BOOLEAN := ((1 .. 5 => (A))
                                               IN ARR)) RETURN INTEGER;
               END P3;
               USE P3;

               FOR T3 USE (A => 1, B =>2, C => 3);           --  ERROR:

               PACKAGE BODY P3 IS
                    FUNCTION USELESS3(Y : BOOLEAN := ((1 .. 5 => (A))
                                             IN ARR)) RETURN INTEGER IS
                    BEGIN
                         RETURN 1;
                    END USELESS3;
               END P3;

          BEGIN
               NULL;
          END;   -- ARRAY COMPONENT

     END ENCLOSE;

BEGIN
     NULL;
END BD1B05E;
