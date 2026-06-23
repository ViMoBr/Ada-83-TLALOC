-- B59001F.ADA


-- CHECK THAT JUMPS FROM AN EXCEPTION HANDLER TO A LABEL
--    DEFINED IN THE SEQUENCE OF STATEMENTS GUARDED BY THE EXCEPTION
--    HANDLER ARE NOT ALLOWED.

-- CHECK THAT JUMPS FROM AN EXCEPTION HANDLER IN A UNIT  TO ANOTHER
--    EXCEPTION HANDLER BELONGING TO THE SAME UNIT  ARE NOT ALLOWED.

-- CHECK THAT JUMPS FROM A GUARDED SEQUENCE-OF-STATEMENTS TO AN
--    EXCEPTION HANDLER GUARDING IT  ARE NOT ALLOWED.


-- RM 05/22/81 (BLOCKS ONLY)
-- RM 06/02/81 (BLOCKS, SUBPROGRAMS, PACKAGES, TASKS)
-- RM 06/04/81 (THIRD SUBOBJECTIVE ADDED)
-- SPS 3/8/83

PROCEDURE  B59001F  IS
BEGIN

     -------------------------------------------------------------------
     ------------------------  IN BLOCKS  ------------------------------

     BEGIN

          NULL ;

          DECLARE
          BEGIN
               << LAB >>
               << LAB0 >>
               GOTO L1 ;                  -- ERROR: INTO HANDLER
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    << L2 >>
                    GOTO L1 ;             -- ERROR: TO FRATERNAL HANDLER
               WHEN NUMERIC_ERROR     =>
                    IF  FALSE  THEN
                         GOTO LAB ;       -- ERROR: TO GUARDED STATEMENT
                    ELSE
                         GOTO LAB0 ;      -- ERROR: TO GUARDED STATEMENT
                    END IF;
                    << L1 >>
                    GOTO L2 ;             -- ERROR: TO FRATERNAL HANDLER
          END ;

          NULL ;

     END ;


     -------------------------------------------------------------------
     ----------------------  IN SUBPROGRAMS  ---------------------------

     DECLARE

          PROCEDURE  PROC  IS
          BEGIN
               << LAB >>
               << LAB0 >>
               GOTO L2 ;                  -- ERROR: INTO HANDLER
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    << L2 >>
                    GOTO L1 ;             -- ERROR: TO FRATERNAL HANDLER
               WHEN NUMERIC_ERROR     =>
                    IF  FALSE  THEN
                         GOTO LAB ;       -- ERROR: TO GUARDED STATEMENT
                    ELSE
                         GOTO LAB0 ;      -- ERROR: TO GUARDED STATEMENT
                    END IF;
                    << L1 >>
                    GOTO L2 ;             -- ERROR: TO FRATERNAL HANDLER
          END ;

     BEGIN

          NULL ;

     END ;


     DECLARE

          FUNCTION  FUNC  RETURN INTEGER  IS
          BEGIN
               << LAB >>
               << LAB0 >>
               RETURN 17 ;
               GOTO L1 ;                  -- ERROR: INTO HANDLER
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    << L2 >>
                    GOTO L1 ;             -- ERROR: TO FRATERNAL HANDLER
               WHEN NUMERIC_ERROR     =>
                    IF  FALSE  THEN
                         GOTO LAB ;       -- ERROR: TO GUARDED STATEMENT
                    ELSE
                         GOTO LAB0 ;      -- ERROR: TO GUARDED STATEMENT
                    END IF;
                    << L1 >>
                    GOTO L2 ;             -- ERROR: TO FRATERNAL HANDLER
          END ;

     BEGIN

          NULL ;

     END ;


     -------------------------------------------------------------------
     -------------------------  IN PACKAGES  ---------------------------

     DECLARE

          PACKAGE  PACK  IS
               I : INTEGER ;
          END ;

          PACKAGE BODY  PACK  IS
          BEGIN
               << LAB >>
               << LAB0 >>
               GOTO L1 ;                  -- ERROR: INTO HANDLER
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    << L2 >>
                    GOTO L1 ;             -- ERROR: TO FRATERNAL HANDLER
               WHEN NUMERIC_ERROR     =>
                    IF  FALSE  THEN
                         GOTO LAB ;       -- ERROR: TO GUARDED STATEMENT
                    ELSE
                         GOTO LAB0 ;      -- ERROR: TO GUARDED STATEMENT
                    END IF;
                    << L1 >>
                    GOTO L2 ;             -- ERROR: TO FRATERNAL HANDLER
          END ;

     BEGIN

          NULL ;

     END ;


     -------------------------------------------------------------------
     --------------------------  IN TASKS  -----------------------------

     DECLARE

          TASK  TK ;

          TASK BODY  TK  IS
          BEGIN
               << LAB >>
               << LAB0 >>
               GOTO L1 ;                  -- ERROR: INTO HANDLER
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    << L2 >>
                    GOTO L1 ;             -- ERROR: TO FRATERNAL HANDLER
               WHEN NUMERIC_ERROR     =>
                    IF  FALSE  THEN
                         GOTO LAB ;       -- ERROR: TO GUARDED STATEMENT
                    ELSE
                         GOTO LAB0 ;      -- ERROR: TO GUARDED STATEMENT
                    END IF;
                    << L1 >>
                    GOTO L2 ;             -- ERROR: TO FRATERNAL HANDLER
          END ;

     BEGIN

          NULL ;

     END ;

     -------------------------------------------------------------------


END B59001F;
