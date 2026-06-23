-- B45209A.ADA


-- CHECK THAT THE OPERANDS OF A MEMBERSHIP OPERATION MUST ALL HAVE THE
--    SAME TYPE.


-- RM 03/20/81
-- SPS 2/10/83
-- JWC 6/28/85   RENAMED FROM B45203B-AB.ADA

PROCEDURE  B45209A  IS
BEGIN

     DECLARE

          TYPE  ENUM1  IS  ( AA , BB , CC , LIT , XX , YY , ZZ );
          TYPE  ENUM2  IS  ( PP , QQ , RR );

          BOOLVAR   :  BOOLEAN ;

     BEGIN

          BOOLVAR  :=  LIT IN ENUM2 ;                 -- ERROR: BAD TYPE
          BOOLVAR  :=  LIT NOT IN ENUM2 ;             -- ERROR: BAD TYPE
          BOOLVAR  :=  LIT     IN             QQ..QQ ;-- ERROR: BAD TYPE

     END ;


     DECLARE

          TYPE  ENUM  IS  ( AA , BB , CC , LIT , XX , YY , ZZ );
          TYPE  NEWENUM   IS  NEW ENUM RANGE AA..YY ;

          VAR  :           NEWENUM  :=  LIT ;
          CON  :  CONSTANT ENUM     :=  LIT ;

          BOOLVAR   :  BOOLEAN ;

     BEGIN

          BOOLVAR  :=  CON     IN NEWENUM ;           -- ERROR: BAD TYPE
          BOOLVAR  :=  VAR NOT IN ENUM ;              -- ERROR: BAD TYPE
          BOOLVAR  :=  CON     IN NEWENUM'(YY) ..AA ; -- ERROR: BAD TYPE

     END ;


END B45209A ;
