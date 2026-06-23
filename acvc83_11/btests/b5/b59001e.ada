-- B59001E.ADA


-- CHECK THAT JUMPS BETWEEN BRANCHES OF A 'CASE' STATEMENT  OR OF AN
--    'IF' STATEMENT  ARE NOT PERMITTED.


-- RM 06/04/81
-- SPS 3/8/83
-- SPS 9/2/83

PROCEDURE  B59001E  IS
BEGIN

     DECLARE

          I : INTEGER := 17 ;

     BEGIN

          CASE  I  IS
               WHEN  17  =>
                    << L2 >>
                    GOTO L1 ;              -- ERROR: TO THE OTHER BRANCH
               WHEN  OTHERS  =>
                    << L1 >>
                    GOTO L2 ;              -- ERROR: TO THE OTHER BRANCH

                    DECLARE
                    BEGIN
                         GOTO  L2 ;        -- ERROR: TO THE OTHER BRANCH
                    END ;
          END CASE;

          NULL ;

          IF  I = 17  THEN
               << L12 >>
               GOTO L11 ;                  -- ERROR: TO ANOTHER BRANCH
               GOTO L14 ;                  -- ERROR: TO ANOTHER BRANCH
          ELSIF  I = 19  THEN
               << L11 >>
               GOTO L12 ;                  -- ERROR: TO ANOTHER BRANCH
               GOTO L14 ;                  -- ERROR: TO ANOTHER BRANCH

               DECLARE
               BEGIN
                    GOTO  L12 ;            -- ERROR: TO ANOTHER BRANCH
                    GOTO  L14 ;            -- ERROR: TO ANOTHER BRANCH
               END ;
          ELSE
               << L14 >>
               GOTO L11 ;                  -- ERROR: TO ANOTHER BRANCH
               GOTO L12 ;                  -- ERROR: TO ANOTHER BRANCH
               CASE  I  IS
                    WHEN  17  =>
                         << L15 >>
                         GOTO L11 ;        -- ERROR: TO ANOTHER BRANCH
                         GOTO L12 ;        -- ERROR: TO ANOTHER BRANCH
                         GOTO L16 ;        -- ERROR: TO ANOTHER BRANCH
                    WHEN  OTHERS  =>
                         << L16 >>
                         GOTO L11 ;        -- ERROR: TO ANOTHER BRANCH
                         GOTO L12 ;        -- ERROR: TO ANOTHER BRANCH
                         GOTO L15 ;        -- ERROR: TO ANOTHER BRANCH

                         DECLARE
                         BEGIN
                              GOTO  L11 ;  -- ERROR: TO ANOTHER BRANCH
                         END ;
               END CASE;

          END IF;


     END ;


END B59001E;
