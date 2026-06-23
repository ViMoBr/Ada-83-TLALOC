-- CC1221A.ADA

-- OBJECTIVE:
--     FOR A FORMAL INTEGER TYPE, CHECK THAT THE FOLLOWING BASIC
--     OPERATIONS ARE IMPLICITLY DECLARED AND ARE THEREFORE AVAILABLE
--     WITHIN THE GENERIC UNIT:  ASSIGNMENT, MEMBERSHIP, QUALIFICATION,
--     AND EXPLICIT CONVERSION TO AND FROM OTHER INTEGER TYPES.

-- HISTORY:
--     RJW 09/26/86  CREATED ORIGINAL TEST.
--     BCB 11/12/87  CHANGED HEADER TO STANDARD FORMAT.  SPLIT TEST
--                   INTO PARTS A, B, C, AND D.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE CC1221A IS

     SUBTYPE SUBINT IS INTEGER RANGE -100 .. 100;
     TYPE NEWINT IS NEW INTEGER;
     TYPE INT IS RANGE -300 .. 300;

BEGIN
     TEST ( "CC1221A", "FOR A FORMAL INTEGER TYPE, CHECK THAT THE " &
                       "FOLLOWING BASIC OPERATIONS ARE IMPLICITLY " &
                       "DECLARED AND ARE THEREFORE AVAILABLE " &
                       "WITHIN THE GENERIC UNIT:  ASSIGNMENT, " &
                       "MEMBERSHIP, QUALIFICATION, AND EXPLICIT " &
                       "CONVERSION TO AND FROM OTHER INTEGER TYPES");

     DECLARE -- (A) CHECKS FOR BASIC OPERATIONS OF A DISCRETE TYPE.
             --     PART I.

          GENERIC
               TYPE T IS RANGE <>;
               TYPE T1 IS RANGE <>;
               I  : T;
               I1 : T1;
          PROCEDURE P (J : T; STR : STRING);

          PROCEDURE P (J : T; STR : STRING) IS
               SUBTYPE ST IS T RANGE T'VAL (-1) .. T'VAL (1);
               K, L  : T;

               FUNCTION F (X : T) RETURN BOOLEAN IS
               BEGIN
                    RETURN IDENT_BOOL (TRUE);
               END F;

               FUNCTION F (X : T1) RETURN BOOLEAN IS
               BEGIN
                    RETURN IDENT_BOOL (FALSE);
               END F;

          BEGIN
               K := I;
               L := J;
               K := L;

               IF K /= J THEN
                    FAILED ( "INCORRECT RESULTS FOR ASSIGNMENT " &
                             "WITH TYPE - " & STR);
               END IF;

               IF I IN ST THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS FOR ""IN"" WITH " &
                             "TYPE  - " & STR);
               END IF;

               IF J NOT IN ST THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS FOR ""NOT IN"" WITH " &
                             "TYPE  - " & STR);
               END IF;

               IF T'(I) /= I THEN
                    FAILED ( "INCORRECT RESULTS FOR QUALIFICATION " &
                             "WITH TYPE - " & STR & " - 1" );
               END IF;

               IF F (T'(1)) THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS FOR QUALIFICATION " &
                             "WITH TYPE - " & STR & " - 2" );
               END IF;

               IF T (I1) /= I THEN
                    FAILED ( "INCORRECT RESULTS FOR EXPLICIT " &
                             "CONVERSION WITH TYPE - " & STR &
                             " - 1" );
               END IF;

               IF F (T (I1)) THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS FOR EXPLICIT  " &
                             "CONVERSION WITH TYPE - " & STR &
                             " - 2" );
               END IF;

          END P;

          PROCEDURE NP1 IS NEW P (SUBINT,  SUBINT,  0, 0);
          PROCEDURE NP2 IS NEW P (NEWINT,  NEWINT,  0, 0);
          PROCEDURE NP3 IS NEW P (INT,     INT,     0, 0);
          PROCEDURE NP4 IS NEW P (INTEGER, INTEGER, 0, 0);

     BEGIN
          NP1 (2, "SUBINT");
          NP2 (2, "NEWINT");
          NP3 (2, "INT");
          NP4 (2, "INTEGER");
     END; -- (A).

     RESULT;
END CC1221A;
