-- BD3003A.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION CLAUSE CANNOT BE GIVEN:
--     - IN A PACKAGE FOR A TYPE DECLARED IN AN INNER PACKAGE
--       SPECIFICATION;
--     - IN A PACKAGE OR TASK SPECIFICATION, FOR A TYPE DECLARED IN AN
--       ENCLOSING PACKAGE SPECIFICATION OR DECLARATIVE PART;
--     - IN A PACKAGE BODY FOR A TYPE DECLARED IN THE CORRESPONDING
--       PACKAGE SPECIFICATION.

-- HISTORY:
--     JKC 04/12/88  CREATED ORIGINAL TEST.

PROCEDURE BD3003A IS

     PACKAGE P IS
          TYPE ENUM2 IS (D,E,F);
          TYPE ENUM6 IS (P,Q,R);

          PACKAGE INNER_P IS
               TYPE ENUM1 IS (A,B,C);
          END INNER_P;

          USE INNER_P;

          FOR ENUM1 USE (1,2,3);                           -- ERROR:

          PACKAGE INNER_Q IS
               FOR ENUM2 USE (4,5,6);                      -- ERROR:
          END INNER_Q;
     END P;

     PACKAGE BODY P IS
          FOR ENUM6 USE (16,17,18);                        -- ERROR:
     END P;

     PACKAGE Q IS
          TYPE ENUM4 IS (J,K,L);

          TASK T IS
               FOR ENUM4 USE (10,11,12);                   -- ERROR:
          END T;
     END Q;

     PACKAGE BODY Q IS
          TASK BODY T IS
          BEGIN
               NULL;
          END T;
     END Q;

BEGIN
     DECLARE
          TYPE ENUM3 IS (G,H,I);

          PACKAGE S IS
               FOR ENUM3 USE (7,8,9);                      -- ERROR:
          END S;

          TYPE ENUM5 IS (M,N,O);

          TASK TASK_2 IS
               FOR ENUM5 USE (13,14,15);                   -- ERROR:
          END TASK_2;

          TASK BODY TASK_2 IS
          BEGIN
               NULL;
          END TASK_2;

     BEGIN
          NULL;
     END;
END BD3003A;
