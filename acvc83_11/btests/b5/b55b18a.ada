-- B55B18A.ADA

-- CHECK THAT THE LOOP_PARAMETER CANNOT BE USED IN THE DEFINITION OF THE
--     DISCRETE_RANGE.

-- RM 6/23/82
-- SPS 3/1/83
-- JBG 3/15/83

PROCEDURE B55B18A IS
BEGIN


     FOR I IN  I .. 10 LOOP   -- ERROR: SECOND USE OF  'I'  ILLEGAL.
          NULL;
     END LOOP;


     DECLARE
          J : INTEGER := 1;
     BEGIN

          FOR J IN  J .. 10 LOOP  -- ERROR: SECOND USE OF  'J'  ILLEGAL.
              NULL;
          END LOOP;

     END;

     DECLARE

          FUNCTION M RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END M;

     BEGIN

L:        FOR K IN L.K .. 10 LOOP      -- ERROR: L.K.
               NULL;
          END LOOP L;

          FOR M IN M .. 10 LOOP        -- ERROR: SECOND M.
               NULL;
          END LOOP;

     END;

END B55B18A;
