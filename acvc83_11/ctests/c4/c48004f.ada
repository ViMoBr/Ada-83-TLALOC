-- C48004F.ADA

-- CHECK THAT THE FORM "NEW T" IS PERMITTED IF T IS AN ACCESS TYPE.

-- RM  01/12/80
-- JBG 03/03/83
-- EG  07/05/84

WITH REPORT;

PROCEDURE C48004F  IS

     USE REPORT;

BEGIN

     TEST("C48004F","CHECK THAT THE FORM 'NEW T' IS PERMITTED IF T " &
                    "IS AN ACCESS TYPE");

     DECLARE

          TYPE AINT IS ACCESS INTEGER;
          TYPE A_AINT IS ACCESS AINT;
          VA_AINT : A_AINT;

          TYPE AST IS ACCESS STRING;
          SUBTYPE CAST_4 IS AST(1 .. 4);
          TYPE A_AST IS ACCESS AST;
          TYPE ACAST_3 IS ACCESS AST(1 .. 3);
          V_AAST : A_AST;
          V_ACAST_3 : ACAST_3;

          TYPE UR(A, B : INTEGER) IS
               RECORD
                    C : INTEGER;
               END RECORD;
          SUBTYPE CR IS UR(1, 2);
          TYPE A_CR IS ACCESS CR;
          TYPE AA_CR IS ACCESS A_CR;
          V_AA_CR : AA_CR;

     BEGIN

          VA_AINT := NEW AINT;
          IF VA_AINT.ALL /= NULL THEN
               FAILED ("VARIABLE IS NOT NULL - CASE 1");
          END IF;

          BEGIN

               V_ACAST_3 := NEW CAST_4;
               IF V_ACAST_3.ALL /= NULL THEN
                    FAILED ("VARIABLE IS NOT NULL - CASE 2");
               END IF;

          EXCEPTION

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED - CASE 2");

          END;

          V_AAST := NEW AST;
          IF V_AAST.ALL /= NULL THEN
               FAILED ("VARIABLE IS NOT NULL - CASE 3");
          END IF;

          V_AA_CR := NEW A_CR;
          IF V_AA_CR.ALL /= NULL THEN
               FAILED ("VARIABLE IS NOT NULL - CASE 4");
          END IF;

     END;

     RESULT;

END C48004F;
