-- B99001A.ADA

-- CHECK THAT THE ATTRIBUTE  'TERMINATED'  MAY NOT BE USED FOR
--     A TASK TYPE OR SUBTYPE.

-- RM 5/14/82
-- TBN 12/17/85     RENAMED FROM B99001A-AB.ADA. ADDED CHECK THAT A
--                  TASK SUBTYPE NAME CANNOT BE USED WITHIN THE TASK
--                  BODY AS A PREFIX TO 'TERMINATED.
-- RJW 4/14/86      RENAMED SUBTYPE.

PROCEDURE  B99001A  IS
BEGIN

     ------------------------------------------------------------------

     DECLARE

          TASK TYPE  T_TYPE  IS
               ENTRY  E ;
          END  T_TYPE ;

          SUBTYPE T_SUBTYPE IS T_TYPE;
          T_OBJECT : T_TYPE ;

          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN := T_TYPE'TERMINATED ;  -- OK.
          BEGIN

               ACCEPT  E ;

               IF T_SUBTYPE'TERMINATED THEN   -- ERROR: SUBTYPE PREFIX.
                    NULL;
               END IF;

          END  T_TYPE ;

     BEGIN

          IF  T_TYPE'TERMINATED  THEN         -- ERROR: TASK TYPE.
               NULL ;
          ELSE
               T_OBJECT.E ;
          END IF;

     END ;

     -------------------------------------------------------------------

END  B99001A ;
