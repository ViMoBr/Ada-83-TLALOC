-- CD3014E.ADA

-- OBJECTIVE:
--     IF ENUMERATION REPRESENTATION CLAUSES WITH NON-CONTIGUOUS
--     CODES ARE ALLOWED IN GENERIC UNITS, CHECK THAT THE
--     TYPE CAN BE USED CORRECTLY IN ORDERING RELATIONS, INDEXING
--     ARRAYS, AND IN GENERIC INSTANTIATIONS.

-- HISTORY
--     BCB 03/20/89  CHANGED EXTENSION FROM '.ADA' TO '.DEP'.
--     DHH 09/30/87 CREATED ORIGINAL TEST

WITH REPORT; USE REPORT;
PROCEDURE CD3014E IS

BEGIN

     TEST ("CD3014E", "IF ENUMERATION REPRESENTATION CLAUSES " &
                      "WITH NON-CONTIGUOUS CODES ARE ALLOWED IN" &
                      "GENERIC UNITS, CHECK THAT THE TYPE CAN BE " &
                      "USED CORRECTLY IN ORDERING RELATIONS, " &
                      "INDEXING ARRAYS, AND IN GENERIC INSTANTIATIONS");

     DECLARE

          GENERIC
          PACKAGE GENPACK IS

               TYPE HUE IS (RED,BLUE,YELLOW,'R','B','Y');

               FOR HUE USE
                         (RED => 1, BLUE => 6,
                               YELLOW => 11, 'R' => 16,
                               'B' => 22, 'Y' => 30);

               TYPE BASE IS ARRAY(HUE) OF INTEGER;
               COLOR,BASIC : HUE;
               BARRAY : BASE;

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

               BARRAY := (IDENT_INT(1),IDENT_INT(2),IDENT_INT(3),
                         IDENT_INT(4),IDENT_INT(5),IDENT_INT(6));

               IF BARRAY /= (RED => 1, BLUE => 2, YELLOW => 3,
                              'R' => 4, 'B' => 5, 'Y' => 6) THEN
                    FAILED("INDEXING ARRAY FAILURE");
               END IF;

          END GENPACK;

          PACKAGE P IS NEW GENPACK;
     BEGIN
          NULL;
     END;

     RESULT;
END CD3014E;
