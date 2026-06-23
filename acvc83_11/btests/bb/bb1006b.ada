-- BB1006B.ADA

-- CHECK THAT THE ATTRIBUTE 'FAILURE IS NOT A PREDEFINED EXCEPTION.

-- TBN 4/3/86

PROCEDURE BB1006B IS

     TASK T1;

     TASK BODY T1 IS

     BEGIN
          NULL;
     END T1;

     TASK T2;

     TASK BODY T2 IS

     BEGIN
          RAISE T1'FAILURE;                   -- ERROR:
     END T2;

     TASK T3;

     TASK BODY T3 IS

     BEGIN
          RAISE T3'FAILURE;                   -- ERROR:
     END T3;

BEGIN
     NULL;
END BB1006B;
