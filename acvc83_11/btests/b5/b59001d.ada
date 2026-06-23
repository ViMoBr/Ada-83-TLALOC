-- B59001D.ADA

-- CHECK THAT JUMPS INTO COMPOUND STATEMENTS ARE NOT ALLOWED.

-- RM  06/09/81
-- SPS 03/08/83
-- EG  10/18/85  CORRECT ERROR COMMENTS

PROCEDURE  B59001D  IS
BEGIN

     BEGIN

          GOTO  L111 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          IF  FALSE  THEN
               << L111 >>
               NULL ;
          ELSE
               << L112 >>
               NULL ;
          END IF;

          GOTO  L112 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          GOTO  L131 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          IF  FALSE  THEN
               << L133 >>
               NULL ;
          ELSE
               FOR  J  IN  1..1  LOOP
                    << L131 >>
                    << L132 >>
                    NULL ;
               END LOOP;
          END IF;

          GOTO  L132 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT
          GOTO  L133 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          GOTO  L211 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          CASE  2  IS
               WHEN  1  =>
                    << L211 >>
                    NULL ;
               WHEN  OTHERS  =>
                    << L212 >>
                    NULL ;
          END CASE;

          GOTO  L212 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          GOTO  L231 ;            -- ERROR: UNDCL LABEL

          CASE  2  IS
               WHEN  1  =>
                    << L233 >>
                    NULL ;
               WHEN  OTHERS  =>
                    DECLARE
                    BEGIN
                         << L231 >>
                         << L232 >>
                         NULL ;
                    END ;
          END CASE;

          GOTO  L232 ;            -- ERROR: UNDCL LABEL
          GOTO  L233 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          GOTO  L311 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          FOR  I  IN  1..1  LOOP
               << L311 >>
               << L312 >>
               NULL ;
          END LOOP;

          GOTO  L312 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          GOTO  L331 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          FOR  I  IN  1..1  LOOP
               CASE  2  IS
                    WHEN  1  =>
                         << L331 >>
                         NULL ;
                    WHEN  OTHERS  =>
                         << L332 >>
                         NULL ;
               END CASE;
          END LOOP;

          GOTO  L332 ;            -- ERROR: JUMP INTO COMPOUND STATEMEMT

          GOTO  L411 ;            -- ERROR: UNDCL LABEL

          DECLARE
               K : INTEGER := 17 ;
          BEGIN
               << L411 >>
               NULL ;
               << L412 >>
               NULL ;
          END;

          GOTO  L412 ;            -- ERROR: UNDCL LABEL

     END ;

END B59001D;
