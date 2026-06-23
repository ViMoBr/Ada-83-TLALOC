-- A22002A.ADA

-- CHECK THAT DELIMITERS (WHICH INCLUDE COMPOUND SYMBOLS) ARE ACCEPTED.
-- & ' ( ) * + , - . / : ; < = > |
-- => .. ** := /= >= <= << >> <>

-- DCB 1/5/80
-- DCB 1/22/80
-- JRK 10/21/80
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT;
PROCEDURE A22002A IS

     USE REPORT;

     C1:STRING(1..6);     -- USE OF : ( ) ..
     C2:STRING(1..6);
     C3:STRING(1..12);

     I1, I2, I3, I4 : INTEGER;

     TYPE TABLE IS ARRAY (1..10) OF INTEGER;
     A : TABLE := (2|4|10=>1,1|3|5..9=>0);        -- USE OF | => ,

     TYPE BUFFER IS
          RECORD
               LENGTH : INTEGER;
               POS    : INTEGER;
               IMAGE  : INTEGER;
          END RECORD;
     R1 : BUFFER;

     TYPE BOX IS ARRAY(INTEGER RANGE<>) OF INTEGER;     -- USE OF <>

BEGIN
     TEST ("A22002A", "CHECK THAT DELIMITERS ARE ACCEPTED");

     C1 := "ABCDEF";
     C2 := "GHIJKL";
     C3 := C2&C1;       -- USE OF &

     I1:=2*(3-1+2)/2;I2:=2**3;  -- USE OF := ( ) * + - / ; **

     I3 := A'LAST;      -- USE OF '

     R1.POS := 3;       -- USE OF .

     <<LABEL>>  -- USE OF << >>

     IF I1>2 AND
        I1=4 AND
        I1<8 AND
        I2=8 AND
        I2/=3 AND
        I3<=10 AND
        I3>=10 THEN     -- USE OF < = > /= <= >=
          NULL;
     END IF;

     RESULT;
END A22002A;
