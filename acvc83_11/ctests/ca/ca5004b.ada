-- CA5004B.ADA

-- CHECK THAT PRAGMA ELABORATE IS ACCEPTED AND OBEYED EVEN IF THE UNIT
--    NAMED IN THE PRAGMA DOES NOT YET HAVE A BODY IN THE LIBRARY OR IF 
--    ITS BODY IS OBSOLETE.
-- CHECK THAT MORE THAN ONE NAME IS ALLOWED IN A PRAGMA ELABORATE.

-- BHS 8/03/84
-- JRK 9/20/84

-------------------------------------------------------------

PACKAGE HEADER IS 

     PROCEDURE WRONG (WHY : STRING);

END HEADER;


WITH REPORT; USE REPORT;
PRAGMA ELABORATE (REPORT);
PACKAGE BODY HEADER IS

     PROCEDURE WRONG (WHY : STRING) IS
     BEGIN
          FAILED ("PACKAGE WITH " & WHY & " NOT ELABORATED " &
                  "CORRECTLY");
     END WRONG;

BEGIN

     TEST ("CA5004B", "PRAGMA ELABORATE IS ACCEPTED AND OBEYED " &
                      "EVEN WHEN THE BODY OF THE UNIT NAMED IS " &
                      "MISSING OR OBSOLETE");

END HEADER;

------------------------------------------------------------------

PACKAGE CA5004B0 IS

     I : INTEGER := 1;

     FUNCTION F RETURN BOOLEAN;

END CA5004B0;


PACKAGE BODY CA5004B0 IS

     FUNCTION F RETURN BOOLEAN IS
     BEGIN
          RETURN TRUE;
     END F;

END CA5004B0;

---------------------------------------------------------

PACKAGE CA5004B0 IS          -- OLD BODY NOW OBSOLETE.

     I : INTEGER := 2;
     B : BOOLEAN := TRUE;

     FUNCTION F RETURN BOOLEAN;

END CA5004B0;

---------------------------------------------------------

PACKAGE CA5004B1 IS

     J : INTEGER := 3;

     PROCEDURE P (X : INTEGER);

END CA5004B1;                -- NO BODY GIVEN YET.

----------------------------------------------------------

WITH HEADER; USE HEADER;
WITH CA5004B0, CA5004B1;
USE CA5004B0, CA5004B1;
PRAGMA ELABORATE (HEADER, CA5004B0, CA5004B1);
PACKAGE CA5004B2 IS

     K1 : INTEGER := CA5004B0.I;
     K2 : INTEGER := CA5004B1.J;

END CA5004B2;


PACKAGE BODY CA5004B2 IS
BEGIN

     IF K1 /= 4 THEN
          WRONG ("OBSOLETE BODY");
     END IF;

     IF K2 /= 5 THEN
          WRONG ("NO BODY");
     END IF;

END CA5004B2;

--------------------------------------------------

WITH REPORT, CA5004B2;
USE REPORT, CA5004B2;
PROCEDURE CA5004B IS
BEGIN

     RESULT;

END CA5004B;

----------------------------------------------------

PACKAGE BODY CA5004B0 IS

     FUNCTION F RETURN BOOLEAN IS
     BEGIN
          RETURN FALSE;
     END F;

BEGIN

     I := 4;

END CA5004B0;

---------------------------------------------------

PACKAGE BODY CA5004B1 IS

     PROCEDURE P (X : INTEGER) IS
     BEGIN
          NULL;
     END P;

BEGIN

     J := 5;

END CA5004B1;
