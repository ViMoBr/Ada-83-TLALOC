-- C74402B.ADA

-- CHECK THAT INITIALIZATION OF IN PARAMETERS THAT ARE OF
-- LIMITED PRIVATE TYPE IS PERMITTED.
-- (SEE ALSO 6.4.2/T1 FOR TESTS OF OTHER LIMITED TYPES.)

-- DAS  1/21/81
-- ABW  6/30/82
-- BHS  7/10/84

WITH REPORT;
PROCEDURE C74402B IS

     USE REPORT;

BEGIN

     TEST( "C74402B" , "CHECK THAT INITIALIZATION OF IN PARAMETERS " &
                       "OF LIMITED PRIVATE TYPE IS PERMITTED" );

     DECLARE

          PACKAGE PKG IS

               TYPE LPTYPE IS LIMITED PRIVATE;
               CLP : CONSTANT LPTYPE;
               XLP : CONSTANT LPTYPE;
               FUNCTION EQCLP (L : IN LPTYPE) RETURN BOOLEAN;
               FUNCTION EQXLP (L : IN LPTYPE) RETURN BOOLEAN;

          PRIVATE

               TYPE LPTYPE IS NEW INTEGER RANGE 0..127;
               CLP : CONSTANT LPTYPE := 127;
               XLP : CONSTANT LPTYPE := 0;

          END;

          PACKAGE BODY PKG IS

               FUNCTION EQCLP (L : IN LPTYPE) RETURN BOOLEAN IS
               BEGIN
                    RETURN (L = CLP);
               END EQCLP;

               FUNCTION EQXLP (L : IN LPTYPE) RETURN BOOLEAN IS
               BEGIN
                    RETURN (L = XLP);
               END EQXLP;

          END PKG;

          USE PKG;

          PROCEDURE PROC1 (Y : IN LPTYPE := CLP) IS
          BEGIN
               IF (EQCLP (Y)) THEN
                    FAILED( "LIMITED PRIVATE NOT PASSED, " &
                            "DEFAULT CLP EMPLOYED" );
               ELSIF (NOT EQXLP (Y)) THEN
                    FAILED( "NO LIMITED PRIVATE FOUND" );
               END IF;
          END PROC1;

          PROCEDURE PROC2 (Y : IN LPTYPE := CLP) IS
          BEGIN
               IF (NOT EQCLP(Y)) THEN
                    FAILED( "DEFAULT NOT EMPLOYED" );
               END IF;
          END PROC2;

     BEGIN

          PROC1(XLP);
          PROC2;

     END;

     RESULT;

END C74402B;
