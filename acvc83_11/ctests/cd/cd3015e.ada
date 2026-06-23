-- CD3015E.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN THERE IS NO ENUMERATION CLAUSE FOR THE PARENT
--     TYPE IN A GENERIC UNIT, THE DERIVED TYPE CAN BE USED CORRECTLY
--     IN ORDERING RELATIONS, INDEXING ARRAYS, AND IN GENERIC
--     INSTANTIATIONS.

-- HISTORY
--     DHH 10/05/87 CREATED ORIGINAL TEST
--     DHH 03/30/89 CHANGED EXTENSION FROM '.DEP' TO '.ADA' AND ADDED
--                  CHECK FOR REPRESENTATION CLAUSE.

WITH REPORT; USE REPORT;
WITH ENUM_CHECK;                        -- CONTAINS A CALL TO 'FAILED'.
PROCEDURE CD3015E IS

BEGIN

     TEST ("CD3015E", "CHECK THAT WHEN THERE " &
                      "IS NO ENUMERATION CLAUSE FOR THE PARENT " &
                      "TYPE IN A GENERIC UNIT, THE " &
                      "DERIVED TYPE CAN BE USED CORRECTLY IN " &
                      "ORDERING RELATIONS, INDEXING ARRAYS, AND IN " &
                      "GENERIC INSTANTIATIONS");

     DECLARE

          GENERIC
          PACKAGE GENPACK IS

               TYPE MAIN IS (RED,BLUE,YELLOW,'R','B','Y');

               TYPE HUE IS NEW MAIN;
               FOR HUE USE
                         (RED => 1, BLUE => 6,
                               YELLOW => 11, 'R' => 16,
                               'B' => 22, 'Y' => 30);

               TYPE BASE IS ARRAY(HUE) OF INTEGER;
               COLOR,BASIC : HUE;
               BARRAY : BASE;
               T : INTEGER := 1;

               TYPE INT1 IS RANGE 1 .. 30;
               FOR INT1'SIZE USE HUE'SIZE;

               PROCEDURE CHECK_1 IS NEW ENUM_CHECK(HUE, INT1);

               GENERIC
                    TYPE ENUM IS (<>);
               PROCEDURE CHANGE(X,Y : IN OUT ENUM);

          END GENPACK;

          PACKAGE BODY GENPACK IS

               PROCEDURE CHANGE(X,Y : IN OUT ENUM) IS
                    T : ENUM;
               BEGIN
                    T := X;
                    X := Y;
                    Y := T;
               END CHANGE;

               PROCEDURE PROC IS NEW CHANGE(HUE);

          BEGIN
               BASIC := RED;
               COLOR := HUE'SUCC(BASIC);
               IF (COLOR < BASIC OR
                        BASIC >= 'R' OR
                        'Y' <= COLOR OR
                        COLOR > 'B') THEN
                    FAILED("ORDERING RELATIONS ARE INCORRECT");
               END IF;

               PROC(BASIC,COLOR);

               IF COLOR /= RED THEN
                    FAILED("GENERIC INSTANTIATION FAILED");
               END IF;

               FOR I IN HUE LOOP
                    BARRAY(I) := IDENT_INT(T);
                    T := T + 1;
               END LOOP;

               IF BARRAY /= (RED => 1, BLUE => 2, YELLOW => 3,
                              'R' => 4, 'B' => 5, 'Y' => 6) THEN
                    FAILED("INDEXING ARRAY FAILURE");
               END IF;

               CHECK_1 (YELLOW, 11, "HUE");

          END GENPACK;

          PACKAGE P IS NEW GENPACK;
     BEGIN
          NULL;
     END;

     RESULT;
END CD3015E;
