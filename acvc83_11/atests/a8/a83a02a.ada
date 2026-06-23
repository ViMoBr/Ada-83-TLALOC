-- A83A02A.ADA


-- CHECK THAT A LABEL IN A NESTED SUBPROGRAM OR PACKAGE CAN BE IDENTICAL
--    TO A LABEL OUTSIDE SUCH CONSTRUCT.  


-- "INSIDE LABEL":  INSIDE   * PACKAGE                    _PACK        A
--                           * FUNCTION INSIDE PACKAGE    _PACKFUN     B
--                           * PROCEDURE                  _PROC        C
--                           * PROCEDURE INSIDE BLOCK     _BLOCKPROC   D

-- "OUTSIDE LABEL": INSIDE   * MAIN                       _MAIN        1
--                           * BLOCK IN MAIN              _BLOCK       2
--                           * LOOP IN BLOCK IN MAIN      _BLOCKLOOP   3
--                           * LOOP IN MAIN               _LOOP        4

-- CASES TESTED:  A1  B2  A3  B4                           1 2 3 4
--                D1  C2  C3  D4
--                    D2          AB                  A    X . X .
--                                                    B    . X . X
--                                                    C    . X X .
--                                                    D    X . . X
  

-- RM 02/09/80


WITH REPORT ;
PROCEDURE  A83A02A  IS

     USE REPORT ;

     PROCEDURE  PROC1  IS
     BEGIN
          << LAB_PROC_BLOCK >>                NULL ;    -- C2   C       
          << LAB_PROC_BLOCKLOOP >>            NULL ;    -- C3
     END  PROC1 ;

     PACKAGE  PACK1  IS
          FUNCTION  F  RETURN INTEGER ;
     END  PACK1 ;

     PACKAGE BODY  PACK1  IS
          FUNCTION  F  RETURN INTEGER  IS
          BEGIN
               << LAB_PACKFUN_BLOCK >>        NULL ;    -- B2    B
               << LAB_PACKFUN_LOOP >>         NULL ;    -- B4
               << LAB_PACKFUN_PACK >>         NULL ;    -- BA (AB)
               RETURN 7 ;
          END  F ;
     BEGIN
          << LAB_PACK_MAIN >>                 NULL ;    -- A1    A
          << LAB_PACK_BLOCKLOOP >>            NULL ;    -- A3
          << LAB_PACKFUN_PACK >>              NULL ;    -- BA (AB)
     END  PACK1 ;

BEGIN                                                       

     TEST( "A83A02A" , "CHECK THAT A LABEL IN A NESTED SUBPROGRAM" &
                       " OR PACKAGE CAN BE IDENTICAL TO A LABEL"   &
                       " OUTSIDE SUCH CONSTRUCT" );

     << LAB_PACK_MAIN >>                      NULL ;    -- A1          1
     << LAB_BLOCKPROC_MAIN >>                 NULL ;    -- D1


     DECLARE  -- 

          PROCEDURE  PROC2  IS
          BEGIN
               << LAB_BLOCKPROC_MAIN >>       NULL ;    -- D1    D
               << LAB_BLOCKPROC_LOOP >>       NULL ;    -- D4
               << LAB_BLOCKPROC_BLOCK >>      NULL ;    -- D2
          END  PROC2 ;

     BEGIN

          << LAB_PACKFUN_BLOCK >>             NULL ;    -- B2          2
          << LAB_PROC_BLOCK >>                NULL ;    -- C2
          << LAB_BLOCKPROC_BLOCK >>           NULL ;    -- D2

          FOR  I  IN  1..2  LOOP
               << LAB_PACK_BLOCKLOOP >>       NULL ;    -- A3          3
               << LAB_PROC_BLOCKLOOP >>       NULL ;    -- C3
          END LOOP;

     END ;

     FOR  I  IN  1..2  LOOP
          << LAB_PACKFUN_LOOP >>              NULL ;    -- B4          4
          << LAB_BLOCKPROC_LOOP >>            NULL ;    -- D4
     END LOOP;


     RESULT ;


END A83A02A ;
