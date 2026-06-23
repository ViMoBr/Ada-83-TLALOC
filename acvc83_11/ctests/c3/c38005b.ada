-- C38005B.ADA

-- OBJECTIVE:
--     CHECK THAT ANY OBJECT WITH A FORMAL PRIVATE TYPE, WHOSE ACTUAL
--     TYPE IN AN INSTANTIATION IS AN ACCESS TYPE, IS INITIALIZED BY
--     DEFAULT TO THE VALUE NULL. THIS INCLUDES OBJECTS WHICH ARE ARRAY
--     AND RECORD COMPONENTS.

-- HISTORY:
--     DHH 07/12/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C38005B IS

BEGIN
     TEST("C38005B", "CHECK THAT ANY OBJECT WITH A FORMAL PRIVATE " &
                     "TYPE, WHOSE ACTUAL TYPE IN AN INSTANTIATION " &
                     "IS AN ACCESS TYPE, IS INITIALIZED BY DEFAULT " &
                     "TO THE VALUE NULL. THIS INCLUDES OBJECTS WHICH " &
                     "ARE ARRAY AND RECORD COMPONENTS");
     DECLARE
          TYPE ARRY IS ARRAY(1 .. 10) OF BOOLEAN;
          TYPE REC1 IS
               RECORD
                    A : INTEGER;
                    B : ARRY;
               END RECORD;

          TYPE POINTER IS ACCESS REC1;

          GENERIC
               TYPE NEW_PTR IS PRIVATE;
          PACKAGE GEN_PACK IS
               TYPE PTR_ARY IS ARRAY(1 .. 5) OF NEW_PTR;
               TYPE RECORD1 IS
                    RECORD
                         A : NEW_PTR;
                         B : PTR_ARY;
                    END RECORD;

               OBJ : NEW_PTR;
               ARY : PTR_ARY;
               REC : RECORD1;
          END GEN_PACK;

          PACKAGE TEST_P IS NEW GEN_PACK(POINTER);
          USE TEST_P;

     BEGIN
          IF OBJ /= NULL THEN
               FAILED("OBJECT NOT INITIALIZED TO NULL");
          END IF;

          FOR I IN 1 .. 5 LOOP
               IF ARY(I) /= NULL THEN
                    FAILED("ARRAY COMPONENT " &
                            INTEGER'IMAGE(I) &
                           " NOT INITIALIZED TO NULL");
               END IF;
          END LOOP;

          IF REC.A /= NULL THEN
               FAILED("RECORD OBJECT NOT INITIALIZED TO NULL");
          END IF;

          FOR I IN 1 .. 5 LOOP
               IF REC.B(I) /= NULL THEN
                    FAILED("RECORD SUBCOMPONENT " &
                           INTEGER'IMAGE(I) &
                           " NOT INITIALIZED TO NULL");
               END IF;
          END LOOP;
     END;

     RESULT;
END C38005B;
