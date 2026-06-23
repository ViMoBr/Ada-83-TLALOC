-- C36305A.ADA

-- CHECK THAT A STRING VARIABLE IS CONSIDERED AN ARRAY.

-- DAT 2/17/81
-- SPS 10/25/82

WITH REPORT;
PROCEDURE C36305A IS

     USE REPORT;

     S : STRING (IDENT_INT(5) .. IDENT_INT (10));
     T : STRING (S'RANGE);
     U : STRING (T'FIRST .. T'LAST);
     SUBTYPE I_5 IS INTEGER RANGE U'RANGE(1);
     I5 : I_5;
     C : CONSTANT STRING := "ABCDEF";

BEGIN
     TEST ("C36305A", "CHECK THAT STRINGS ARE REALLY ARRAYS");

     IF S'FIRST /= 5
     OR S'LAST /= 10
     OR S'LENGTH /= 6
     OR U'FIRST(1) /= 5
     OR U'LAST(1) /= 10
     OR U'LENGTH(1) /= 6
     THEN
          FAILED ("INCORRECT STRING ATTRIBUTE VALUES");
     END IF;

     IF 4 IN U'RANGE
     OR 3 IN U'RANGE(1)
     OR 0 IN U'RANGE
     OR 1 IN U'RANGE
     OR 5 NOT IN U'RANGE
     OR 7 NOT IN U'RANGE
     OR 10 NOT IN U'RANGE
     OR NOT (11 NOT IN U'RANGE)
     THEN
          FAILED ("INCORRECT STRING RANGE ATTRIBUTE");
     END IF;

     BEGIN
          BEGIN
               BEGIN
                    I5 := 4;
                    FAILED ("BAD I5 SUBRANGE 1");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => NULL;
               END;
               I5 := INTEGER'(11);
               FAILED ("BAD I5 SUBRANGE 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS => FAILED ("WRONG EXCEPTION RAISED 1");
          END;
          I5 := INTEGER'(5);
          I5 := I5 + I5;
          I5 := NATURAL'(8);
     EXCEPTION
          WHEN OTHERS => FAILED ("WRONG EXCEPTION RAISED 2");
     END;

     FOR I IN S'RANGE LOOP
          S(I) :=  C(11 - I);
     END LOOP;
     T := S;
     FOR I IN REVERSE U'RANGE LOOP
          U(I) := T(15 - I);
     END LOOP;

     FOR I IN 1 .. C'LENGTH LOOP
          IF C(1 .. I) /= U(5 .. I + 4)
          OR U(I + 4 .. U'LAST) /= C(I .. C'LAST)
          OR C(I) /= U (I + 4)
          OR C(I .. I)(I .. I)(I) /= U(U'RANGE)(I + 4) THEN
               FAILED ("INCORRECT CHARACTER MISMATCH IN STRING");
               EXIT;
          END IF;
     END LOOP;

     IF U /= C
     OR U /= "ABCDEF"
     OR U(U'RANGE) /= C(C'RANGE)
     OR U(5 .. 10) /= C(1 .. 6)
     OR U(5 .. 6) /= C(1 .. 2)
     THEN
          FAILED ("STRINGS AS ARRAYS BEHAVE INCORRECTLY");
     END IF;

     RESULT;
END C36305A;
