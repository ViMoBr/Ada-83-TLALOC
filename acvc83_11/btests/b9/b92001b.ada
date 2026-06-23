-- B92001B.ADA

-- CHECK THAT TASK OBJECTS AND OBJECTS HAVING A SUBCOMPONENT OF A TASK 
-- TYPE CANNOT BE ASSIGNED OR COMPARED FOR EQUALITY OR INEQUALITY.

-- TBN 1/30/86

PROCEDURE B92001B IS

     TASK TYPE T1;

     OBJ_T1 : T1;
     OBJ_T2 : T1 := OBJ_T1;                                 -- ERROR: :=
     OBJ_T3 : T1;

     TYPE MY_REC1 IS
          RECORD
               ONE : T1;
          END RECORD;

     OBJ_REC1 : MY_REC1 := (ONE => OBJ_T1);                 -- ERROR: :=
     OBJ_REC4, OBJ_REC5 : MY_REC1;

     TYPE MY_REC2 IS
          RECORD
               ONE : T1 := OBJ_T1;                          -- ERROR: :=
          END RECORD;

     TYPE MY_ARRAY1 IS ARRAY (1 .. 2) OF T1;

     OBJ_ARA1 : MY_ARRAY1 := (OBJ_T1, OBJ_T1);              -- ERROR: :=
     OBJ_ARA3, OBJ_ARA4 : MY_ARRAY1;

     TYPE MY_ARRAY2 IS ARRAY (1 .. 2) OF MY_REC1;

     OBJ_ARA2 : MY_ARRAY2 := ((ONE=> OBJ_T1),(ONE=> OBJ_T1));  -- ERROR:
     OBJ_ARA5, OBJ_ARA6 : MY_ARRAY2;

     TYPE MY_REC3 IS
          RECORD
               NEXT : MY_ARRAY1;
          END RECORD;

     OBJ_REC3 : MY_REC3 := (NEXT => (OBJ_T1, OBJ_T1));      -- ERROR: :=
     OBJ_REC6, OBJ_REC7 : MY_REC3;

     TASK BODY T1 IS
     BEGIN
          NULL;
     END T1;


BEGIN
     OBJ_T3 := OBJ_T1;                        -- ERROR: ASSIGNMENT.
     OBJ_ARA3 := OBJ_ARA4;                    -- ERROR: ASSIGNMENT.
     OBJ_REC4 := OBJ_REC5;                    -- ERROR: ASSIGNMENT.
     OBJ_ARA5 := OBJ_ARA6;                    -- ERROR: ASSIGNMENT.
     OBJ_REC6 := OBJ_REC7;                    -- ERROR: ASSIGNMENT.

     IF OBJ_T3 = OBJ_T1 THEN                  -- ERROR: EQUALITY.
          NULL;
     END IF;
     IF OBJ_T3 /= OBJ_T1 THEN                 -- ERROR: INEQUALITY.
          NULL;
     END IF;
     IF OBJ_ARA3 = OBJ_ARA4 THEN              -- ERROR: EQUALITY.
          NULL;
     END IF;
     IF OBJ_ARA3 /= OBJ_ARA4 THEN             -- ERROR: INEQUALITY.
          NULL;
     END IF;
     IF OBJ_REC4 = OBJ_REC5 THEN              -- ERROR: EQUALITY.
          NULL;
     END IF;
     IF OBJ_REC4 /= OBJ_REC5 THEN             -- ERROR: INEQUALITY.
          NULL;
     END IF;
     IF OBJ_ARA5 = OBJ_ARA6 THEN              -- ERROR: EQUALITY.
          NULL;
     END IF;
     IF OBJ_ARA5 /= OBJ_ARA6 THEN             -- ERROR: INEQUALITY.
          NULL;
     END IF;
     IF OBJ_REC6 = OBJ_REC7 THEN              -- ERROR: EQUALITY.
          NULL;
     END IF;
     IF OBJ_REC6 /= OBJ_REC7 THEN             -- ERROR: INEQUALITY.
          NULL;
     END IF;

END B92001B;
