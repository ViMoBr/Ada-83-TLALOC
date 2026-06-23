-- B59001A.ADA

-- OBJECTIVE:
--     CHECK THAT GOTO STATEMENTS TO NONEXISTENT LABELS ARE NOT
--     PERMITTED.  (LABELS WHICH DO NOT EXIST IN THE SCOPES WHERE THEY
--     ARE EXPECTED BUT DO EXIST IN SCOPES WHERE THEY ARE NOT SEEN BY
--     THE GOTO STATEMENTS REFERENCING THEIR NAMES ARE TREATED IN OTHER
--     TESTS UNDER THIS SAME TEST OBJECTIVE.)
--     (LABELS WHICH DO EXIST IN THE SCOPES WHERE THEY ARE EXPECTED
--     BUT ARE SITUATED INSIDE NON-RECEPTIVE CONSTRUCTS (COMPOUND
--     STATEMENTS, HANDLERS)  ARE TREATED IN OTHER TESTS
--     UNDER THIS SAME TEST OBJECTIVE.)

--     CHECK THAT A GOTO STATEMENT CANNOT TRANSFER CONTROL OUT OF A
--     SUBPROGRAM OR PACKAGE.

-- HISTORY:
--     RM  06/04/81
--     SPS 03/08/83
--     EG  10/18/85  CORRECT ERROR COMMENTS.
--     DWC 10/02/87  RENAMED 'NONEXISTENT' LABELS TO UNIQUE
--                   LABEL NAMES.

PROCEDURE  B59001A  IS
BEGIN

     << OUTER_LABEL >>

     GOTO  NONEXISTENT1 ;                       -- ERROR: NO SUCH LABEL

     ------------------------------------------------------------------
     --------------------  FROM SUBPROGRAMS  --------------------------

     DECLARE

          PROCEDURE  PROC  IS

               PROCEDURE  INNER_PROC  IS
               BEGIN
                    GOTO  NONEXISTENT ;          -- ERROR: NO SUCH LABEL
                    GOTO  OUTER_LABEL ;          -- ERROR: OUTER LABEL
                    GOTO  OUTER_PROC_LABEL ;     -- ERROR: UNDCL LABEL
               END ;

          BEGIN
               << OUTER_PROC_LABEL >>
               GOTO  NONEXISTENT ;               -- ERROR: NO SUCH LABEL
               GOTO  OUTER_LABEL ;               -- ERROR: OUTER LABEL
          END ;

     BEGIN

          GOTO  NONEXISTENT2 ;                  -- ERROR: NO SUCH LABEL

     END ;

     DECLARE

          FUNCTION  FUN  RETURN INTEGER  IS

               FUNCTION  INNER_FUN  RETURN INTEGER  IS
               BEGIN
                    RETURN  17 ;
                    GOTO  NONEXISTENT ;          -- ERROR: NO SUCH LABEL
                    GOTO  OUTER_LABEL ;          -- ERROR: OUTER LABEL
                    GOTO  OUTER_LABEL_2 ;        -- ERROR: OUTER LABEL
                    GOTO  OUT2_LABEL ;           -- ERROR: UNDCL LABEL
                    GOTO  OUTER_FUNC_LABEL ;     -- ERROR: UNDCL LABEL
               END  INNER_FUN ;

          BEGIN
               RETURN  19 ;
               << OUTER_FUNC_LABEL >>
               GOTO  NONEXISTENT ;               -- ERROR: NO SUCH LABEL
               GOTO  OUTER_LABEL ;               -- ERROR: OUTER LABEL
               GOTO  OUTER_LABEL_2 ;             -- ERROR: OUTER LABEL
               GOTO  OUT2_LABEL ;                -- ERROR: UNDCL LABEL
          END  FUN ;

     BEGIN

          << OUT2_LABEL >>
          GOTO  NONEXISTENT3 ;                  -- ERROR: NO SUCH LABEL

     END ;

     -------------------------------------------------------------------
     ------------------------  FROM PACKAGES  --------------------------

     DECLARE

          PACKAGE  PACK  IS

               PACKAGE  INNER_PACK  IS
                    TYPE  T  IS NEW INTEGER ;
               END  INNER_PACK ;

          END  PACK ;

          PACKAGE BODY  PACK  IS

               PACKAGE BODY  INNER_PACK  IS
               BEGIN
                    GOTO  NONEXISTENT ;          -- ERROR: NO SUCH LABEL
                    GOTO  OUTER_LABEL ;          -- ERROR: OUTER LABEL
                    GOTO  OUTER_LABEL_2 ;        -- ERROR: OUTER LABEL
                    GOTO  OUT3_LABEL ;           -- ERROR: UNDCL LABEL
                    GOTO  OUTER_PACK_LABEL ;     -- ERROR: UNDCL LABEL
               END  INNER_PACK ;

          BEGIN
               << OUTER_PACK_LABEL >>
               GOTO  NONEXISTENT ;               -- ERROR: NO SUCH LABEL
               GOTO  OUTER_LABEL ;               -- ERROR: OUTER LABEL
               GOTO  OUTER_LABEL_2 ;             -- ERROR: OUTER LABEL
               GOTO  OUT3_LABEL ;                -- ERROR: UNDCL LABEL
          END  PACK ;

     BEGIN

          << OUT3_LABEL >>
          GOTO  NONEXISTENT4 ;                  -- ERROR: NO SUCH LABEL

     END ;

     -------------------------------------------------------------------

     << OUTER_LABEL_2 >>
     NULL ;

END B59001A;
