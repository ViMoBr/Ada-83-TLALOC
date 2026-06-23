with TEXT_IO;
use  TEXT_IO;

-- A21001A.ADA

-- CHECK THAT THE BASIC CHARACTER SET IS ACCEPTED
-- OUTSIDE OF STRING LITERALS AND COMMENTS.

-- DCB 1/22/80

WITH REPORT;
PROCEDURE A21001A IS

     USE REPORT;

BEGIN
     TEST ("A21001A", "CHECK THAT BASIC CHARACTER SET IS ACCEPTED" );

     DECLARE

          TYPE TABLE IS ARRAY (1..10) OF INTEGER;
          A : TABLE := ( 2 | 4 | 10 => 1 , 1 | 3 | 5..9 => 0 ) ;
                                        -- USE OF : ( ) | ,

          TYPE BUFFER IS
               RECORD
                    LENGTH : INTEGER;
                    POS : INTEGER;
                    IMAGE : INTEGER;
               END RECORD;           -- USED TO TEST . LATER
          R1 : BUFFER;

          ABCDEFGHIJKLM : INTEGER;   -- USE OF A B C D E F G H I J K L M
          NOPQRSTUVWXYZ : INTEGER;   -- USE OF N O P Q R S T U V W X Y Z
          Z_1234567890  : INTEGER;   -- USE OF _ 1 2 3 4 5 6 7 8 9 0

          I1, I2, I3 : INTEGER;
          C1, C2 : STRING (1..6);
          C3 : STRING (1..12);

     BEGIN

          I1 := 2 * ( 3 - 1 + 2 ) / 2 ; I2 := 8 ;  -- USES ( ) * + - / ;

          C1 := "ABCDEF" ;              -- USE OF "
          C2 := C1;
          C3 := C1 & C2 ;               -- USE OF &

          I2 := 16#D#;                  -- USE OF #

          I3 := A'LAST;                 -- USE OF '

          R1.POS := 3;                  -- USE OF .

          IF I1 > 2 AND
             I1 = 4 AND
             I1 < 8 THEN                -- USE OF > = <
               NULL;
          END IF;

     END;

     RESULT;
END A21001A;
