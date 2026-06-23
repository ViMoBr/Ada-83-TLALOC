-- A91001I.ADA

-- CHECK THAT DEGENERATE FORMS OF TASK SPECIFICATIONS ARE ALLOWED.

-- TBN 1/29/86

WITH REPORT; USE REPORT;
PROCEDURE A91001I IS

     BEGIN
          TEST ("A91001I", "CHECK THAT DEGENERATE FORMS OF TASK " &
                           "SPECIFICATIONS ARE ALLOWED");

          DECLARE  -- (A)

               TASK FRED;

               TASK BODY FRED IS
               BEGIN
                    NULL;
               END;

               TASK TOM IS
               END;

               TASK BODY TOM IS
               BEGIN
                    NULL;
               END;
          
               TASK MIKE IS
               END MIKE;

               TASK BODY MIKE IS
               BEGIN
                    NULL;
               END;

               --------------------

               TASK TYPE TT1;

               TASK BODY TT1 IS
               BEGIN
                    NULL;
               END;

               TASK TYPE TT2 IS
               END;

               TASK BODY TT2 IS
               BEGIN
                    NULL;
               END;
          
               TASK TYPE TT3 IS
               END TT3;

               TASK BODY TT3 IS
               BEGIN
                    NULL;
               END;

          BEGIN  -- (A)

               DECLARE     -- (B)

                    T1 : TT1;
                    T2 : TT2;
                    T3 : TT3;

               BEGIN       -- (B)
                    NULL;
               END;        -- (B)

          END;   -- (A)

          RESULT;
     END A91001I;
