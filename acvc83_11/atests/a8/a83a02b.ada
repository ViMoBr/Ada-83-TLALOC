-- A83A02B.ADA


-- CHECK THAT A LABEL IN A NESTED TASK CAN BE IDENTICAL TO A LABEL
--    OUTSIDE THE TASK.  


-- "INSIDE LABEL":  INSIDE   * TASK BODY                  _TASK        A
--                           * BLOCK IN TASK BODY         _TASKBLOCK   B
--                           * LOOP IN BLOCK IN TASK BODY _TASKBLOCKLOOP
--                           * ACCEPT ST. WITHIN TASK BDY _TASKACCEPT  D

-- "OUTSIDE LABEL": INSIDE   * MAIN                       _MAIN        1
--                           * BLOCK IN MAIN              _BLOCK       2
--                           * LOOP IN BLOCK IN MAIN      _BLOCKLOOP   3
--                           * LOOP IN MAIN               _LOOP        4

-- CASES TESTED:  A1  B2  A3  B4                        |  1 2 3 4
--                D1  C2  C3  D4                     ---+----------
--                                                    A |  X . X .
--                                                    B |  . X . X
--                                                    C |  . X X .
--                                                    D |  X . . X
  

-- RM 02/10/80


WITH REPORT ;
PROCEDURE  A83A02B  IS

     USE REPORT ;

     TASK TYPE  TASK1  IS
          ENTRY  E1 ;
     END  TASK1 ;

     TASK BODY  TASK1  IS
     BEGIN

          << LAB_TASK_MAIN >>                    NULL ;  -- A1    A
          << LAB_TASK_BLOCKLOOP >>               NULL ;  -- A3

          BEGIN

               << LAB_TASKBLOCK_BLOCK >>         NULL ;  -- B2    B
               << LAB_TASKBLOCK_LOOP >>          NULL ;  -- B4

               FOR  I  IN  1..2  LOOP
                    << LAB_TASKBLOCKLOOP_BLOCK >>NULL ;  -- C2    C
                    << LAB_TASKBLOCKLOOP_BLOCKLOOP >>
                                                 NULL ;  -- C3        
               END LOOP;

          END ;

          ACCEPT  E1  DO
               << LAB_TASKACCEPT_MAIN >>         NULL ;  -- D1    D
               << LAB_TASKACCEPT_LOOP >>         NULL ;  -- D4
          END  E1 ;

     END  TASK1 ;

BEGIN                                                       

     TEST( "A83A02B" , "CHECK THAT A LABEL IN A NESTED TASK" &
                       " CAN BE IDENTICAL TO A LABEL"   &
                       " OUTSIDE THE TASK" );

     << LAB_TASK_MAIN >>                         NULL ;  -- A1         1
     << LAB_TASKACCEPT_MAIN >>                   NULL ;  -- D1


     BEGIN

          << LAB_TASKBLOCK_BLOCK >>              NULL ;  -- B2         2
          << LAB_TASKBLOCKLOOP_BLOCK >>          NULL ;  -- C2

          FOR  I  IN  1..2  LOOP
               << LAB_TASK_BLOCKLOOP >>          NULL ;  -- A3         3
               << LAB_TASKBLOCKLOOP_BLOCKLOOP >> NULL ;  -- C3
          END LOOP;

     END ;

     FOR  I  IN  1..2  LOOP
          << LAB_TASKBLOCK_LOOP >>               NULL ;  -- B4         4
          << LAB_TASKACCEPT_LOOP >>              NULL ;  -- D4
     END LOOP;


     RESULT ;


END A83A02B ;
