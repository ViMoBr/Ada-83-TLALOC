-- B92001A.ADA

-- CHECK THAT NEITHER ASSIGNMENT NOR THE PREDEFINED COMPARISONS
-- = AND /= ARE AVAILABLE FOR TASK OBJECTS.

-- WEI 3/ 4/82
-- RJK 2/ 1/84     ADDED TO ACVC.
-- TBN 7/14/86     RENAMED FROM B920BDA-B.ADA.

PROCEDURE B92001A IS

     TASK T1;
     TASK T2;
     TASK TYPE TT1;
     TASK TYPE TT2;


     TYPE ATT1 IS ACCESS TT1;
     TYPE ATT2 IS ACCESS TT2;
     TYPE AI IS ACCESS INTEGER;

     POINTER_AI : AI := NEW INTEGER;

     OBJ_TT1_1, OBJ_TT1_2 : TT1;
     OBJ_TT2_1 : TT2;
     POINTER_TT1_1 : ATT1 := NEW TT1;
     POINTER_TT1_2 : ATT1 := NEW TT1;
     POINTER_TT2_1 : ATT2 := NEW TT2;

     TASK BODY T1 IS
     BEGIN
          NULL;
     END T1;

     TASK BODY T2 IS
     BEGIN
          NULL;
     END T2;

     TASK BODY TT1 IS
     BEGIN
          NULL;
     END TT1;

     TASK BODY TT2 IS
     BEGIN
          NULL;
     END TT2;

BEGIN

     POINTER_AI.ALL := 13; -- OK. CHECK IF 'ALL' WORKS.

     T1 := T2;                                         -- ERROR: :=.
     OBJ_TT1_1 := OBJ_TT1_2;                           -- ERROR: :=.
     OBJ_TT2_1 := OBJ_TT1_1;                           -- ERROR: :=.

     IF OBJ_TT1_1 = OBJ_TT1_1 THEN                     -- ERROR: =.
          NULL; 
     END IF;

     IF OBJ_TT1_1 /= OBJ_TT1_1 THEN                    -- ERROR: /=.
          NULL; 
     END IF;

     IF OBJ_TT2_1 = OBJ_TT1_1 THEN                     -- ERROR: =.
          NULL; 
     END IF;

     POINTER_TT1_1.ALL := POINTER_TT1_2.ALL;           -- ERROR: :=.
     POINTER_TT2_1.ALL := POINTER_TT1_1.ALL;           -- ERROR: :=.
     IF POINTER_TT1_1.ALL = POINTER_TT1_1.ALL THEN     -- ERROR: =.
          NULL;
     END IF;

     IF POINTER_TT1_1.ALL/= POINTER_TT1_1.ALL THEN     -- ERROR: /=.
          NULL;
     END IF;

     IF POINTER_TT2_1.ALL = POINTER_TT1_1.ALL THEN     -- ERROR: =.
          NULL;
     END IF;

END B92001A;
