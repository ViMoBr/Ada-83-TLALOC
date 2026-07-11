
WITH TEXT_IO;
USE TEXT_IO;
WITH DEFS;
USE DEFS;

PACKAGE GETSUBS IS

------------------------------------------------------------------------
--                                                                    --
--  THIS PACKAGE IS USED BY MACROSUB.ADA FOR READING FROM MACRO.DFS   --
--  THE VALUES FOR THE MACRO SUBSTITUTIONS FOR A TEST TAPE.           --
--                                                                    --
------------------------------------------------------------------------

     PROCEDURE CALC_MAX_VALS(INDEX, LENGTH, MAX_IN_LEN : IN INTEGER;
                             CALCULATED : IN OUT BOOLEAN);

     PROCEDURE FILL_TABLE;

END GETSUBS;
