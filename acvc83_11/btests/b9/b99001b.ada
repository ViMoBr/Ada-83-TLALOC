-- B99001B.ADA

-- OBJECTIVE:
--     CHECK THAT THE ATTRIBUTE  'CALLABLE'  MAY NOT BE USED FOR
--     A TASK TYPE.

-- HISTORY:
--     RM  05/14/82 CREATED ORIGINAL TEST.
--     DHH 08/16/88 REVISED HEADER AND ENTERED TEST FOR TASK SUBTYPE.

PROCEDURE  B99001B  IS
BEGIN
     DECLARE

          TASK TYPE  T_TYPE  IS
               ENTRY  E ;
          END  T_TYPE ;

          SUBTYPE SUB_T IS T_TYPE;

          T_OBJECT : T_TYPE ;

          TASK BODY  T_TYPE  IS
               BUSY : BOOLEAN;
          BEGIN
               BUSY := SUB_T'CALLABLE;               -- ERROR: SUBTYPE
               ACCEPT  E ;
          END  T_TYPE ;

     BEGIN

          IF  T_TYPE'CALLABLE  THEN         -- ERROR: TASK TYPE.
               T_OBJECT.E ;
          END IF;

     END ;

END  B99001B ;
