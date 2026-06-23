-- CD3014A.ADA

-- OBJECTIVE:
--     IF ENUMERATION REPRESENTATION CLAUSES ARE ALLOWED, CHECK THAT
--     THE TYPE CAN BE USED CORRECTLY IN ORDERING RELATIONS, INDEXING
--     ARRAYS, AND IN GENERIC INSTANTIATIONS.

-- HISTORY
--     BCB 03/20/89  CHANGED EXTENSION FROM '.ADA' TO '.DEP'.
--     DHH 09/30/87 CREATED ORIGINAL TEST

WITH REPORT; USE REPORT;
PROCEDURE CD3014A IS

BEGIN

     TEST ("CD3014A", "IF ENUMERATION REPRESENTATION CLAUSES ARE " &
                      "ALLOWED, CHECK THAT THE TYPE CAN BE USED " &
                      "CORRECTLY IN ORDERING RELATIONS, INDEXING " &
                      "ARRAYS, AND IN GENERIC INSTANTIATIONS");

     DECLARE
          PACKAGE PACK IS

               TYPE HUE IS (RED,BLUE,YELLOW,'R','B','Y');

               FOR HUE USE
                         (RED => 8, BLUE => 9,
                               YELLOW => 10, 'R' => 11,
                               'B' => 12, 'Y' => 13);

               TYPE BASE IS ARRAY(HUE) OF INTEGER;
               COLOR,BASIC : HUE;
               BARRAY : BASE;

               GENERIC
                    TYPE ENUM IS (<>);
               PROCEDURE CHANGE(X,Y : IN OUT ENUM);

          END PACK;

          PACKAGE BODY PACK IS

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

          END PACK;
     BEGIN
          NULL;
     END;

     RESULT;
END CD3014A;
