-- B51001A.ADA

-- CHECK THAT DECLARATIONS CANNOT BE INTERLEAVED WITH STATEMENTS
--    IN A SEQUENCE OF STATEMENTS.

-- DCB 2/1/80
-- SPS 3/15/83

PROCEDURE B51001A IS

     I1, I2, I3, I4 : INTEGER;

     PACKAGE P IS
          C1, C2 : CHARACTER;
     END P;

     PACKAGE BODY P IS
     BEGIN
          C1 := 'A';
          C9 : INTEGER; -- ERROR: DECLARATION INTERLEAVED WITH
                        --        STATEMENT IN PACKAGE BODY.
          C2 := 'B';
     END P;

BEGIN

     I1 := 3;
     I9 : INTEGER;      -- ERROR: DECLARATION INTERLEAVED WITH
                        --        STATEMENT IN PROCEDURE BODY.
     I2 := 4;

     IF I2 = I3 THEN
          I4 := I2;
          I8 : INTEGER; -- ERROR: DECLARATION INTERLEAVED WITH
                        --        STATEMENT IN IF BODY.
          I2 := 3;
     END IF;

     CASE I1 IS
          WHEN 1..3 =>
               I2 := 7;
               I9 : INTEGER; -- ERROR: DECL INTERLEAVED WITH STMT
                             --        IN CASE BODY.
               I1 := 5;
          WHEN OTHERS => NULL;
     END CASE;

     WHILE I1 < 10 LOOP
          I1  := I1 + 1;
          I20 :  INTEGER; -- ERROR: DECL INTERLEAVED WITH STMT
                          --        IN LOOP BODY.
          I2  := I1;
     END LOOP;

     DECLARE
          I5 : INTEGER;

     BEGIN
          I5 := I1 + I2;
          I99 : INTEGER;     -- ERROR: DECL INTERLEAVED WITH STMT
                             --        IN INNER BLOCK.
          I3 := 3;
     END;

END B51001A;
