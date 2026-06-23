-- CE3707A.ADA

-- OBJECTIVE:
--     CHECK THAT INTEGER_IO GET CAN READ A VALUE FROM A STRING.  CHECK
--     THAT IT TREATS THE END OF THE STRING AS A FILE TERMINATOR.  CHECK
--     THAT LAST CONTAINS THE INDEX VALUE OF THE LAST CHARACTER READ
--     FROM THE STRING.

-- HISTORY:
--     SPS 10/05/82
--     VKG 01/13/83
--     JLH 09/11/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3707A IS

     PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
     USE IIO;
     X : INTEGER;
     L : POSITIVE;
     STR : STRING(1..6) := "123456" ;

BEGIN

     TEST ("CE3707A", "CHECK THAT INTEGER_IO GET OPERATES CORRECTLY " &
                      "ON STRINGS");

-- LEFT JUSTIFIED STRING NON NULL

     GET ("2362  ", X, L);
     IF X /= 2362 THEN
          FAILED ("VALUE FROM STRING INCORRECT - 1");
     END IF;

     IF L /= 4 THEN
          FAILED ("VALUE OF LAST INCORRECT - 1");
     END IF;

-- STRING LITERAL WITH BLANKS

     BEGIN
          GET ("  ", X, L);
          FAILED ("END_ERROR NOT RAISED - 2");
     EXCEPTION
          WHEN END_ERROR =>
               IF L /= 4 THEN
                    FAILED ("AFTER END ERROR VALUE OF LAST " &
                            "INCORRECT - 2");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 2");
     END;

-- NULL STRING

     BEGIN
          GET ("", X, L);
          FAILED (" END_ERROR NOT RAISED - 3");
     EXCEPTION
          WHEN END_ERROR =>
               IF L /= 4 THEN
                    FAILED ("AFTER END_ERROR VALUE OF LAST " &
                            "INCORRECT - 3");
               END IF;
          WHEN OTHERS =>
               FAILED ("SOME EXCEPTION RAISED - 3");
     END;

-- NULL SLICE

     BEGIN
          GET(STR(5..IDENT_INT(2)), X, L);
          FAILED ("END_ERROR NOT RAISED - 4");
     EXCEPTION
          WHEN END_ERROR =>
               IF L /= 4 THEN
                    FAILED ("AFTER END_ERROR VALUE OF LAST " &
                            "INCORRECT - 4");
               END IF;
          WHEN OTHERS =>
               FAILED ("SOME EXCEPTION RAISED - 4");
     END;

-- NON-NULL SLICE

     GET (STR(2..3), X, L);
     IF X /= 23 THEN
           FAILED ("INTEGER VALUE INCORRECT - 5");
     END IF;
     IF L /= 3 THEN
          FAILED ("LAST INCORRECT FOR SLICE - 5");
     END IF;

-- RIGHT JUSTIFIED NEGATIVE NUMBER

     GET("   -2345",X,L);
     IF X /= -2345 THEN
          FAILED ("INTEGER VALUE INCORRECT - 6");
     END IF;
     IF L /= 8 THEN
          FAILED ("LAST INCORRECT FOR NEGATIVE NUMBER - 6");
     END IF;

     RESULT;

END CE3707A;
