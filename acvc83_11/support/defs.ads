-----------------------------------------------------------------------
--                                                                   --
--   THIS PROGRAM IS CALLED MACROSUB.  IT IS USED TO REPLACE THE     --
--   MACROS IN THE ACVC TEST SUITE WITH THEIR PROPER VALUES.  THE    --
--   STEPS LISTED BELOW SHOULD BE FOLLOWED TO ENSURE PROPER RUNNING  --
--   OF THE MACROSUB PROGRAM:                                        --
--                                                                   --
--           1) Edit the file MACRO.DFS (included with the testtape) --
--              and insert your macro values.  The macros which use  --
--              the value of MAX_IN_LEN are calculated automatically --
--              and do not need to be entered.                       --
--                                                                   --
--           2) Create a file called TSTTESTS.DAT which includes all --
--              of the .TST test file names and their directory      --
--              specifications, if necessary.  If a different name   --
--              other than TSTTESTS.DAT is used, this name must be   --
--              substituted in the MACROSUB.ADA file.                --
--                                                                   --
--           3) Compile and link MACROSUB.                           --
--                                                                   --
--           4) Run the MACROSUB program.                            --
--                                                                   --
--   WHEN THE PROGRAM FINISHES RUNNING, THE MACROS WILL HAVE BEEN    --
--   REPLACED WITH THE APPROPRIATE VALUES FROM MACRO.DFS.            --
--                                                                   --
-----------------------------------------------------------------------

WITH TEXT_IO;
USE TEXT_IO;

PACKAGE DEFS IS

-----------------------------------------------------------------------
--                                                                   --
--   THIS PACKAGE IS USED BY MACROSUB.ADA, PARSEMAC.ADA, AND BY      --
--   GETSUBS.ADA.  THE PACKAGE CONTAINS VARIABLE DECLARATIONS WHICH  --
--   NEED TO BE KNOWN BY ALL OF THE PROCEDURES AND PACKAGES WHICH    --
--   MAKE UP THE PROGRAM.                                            --
--                                                                   --
-----------------------------------------------------------------------

     MAX_VAL_LENGTH : CONSTANT INTEGER := 512;

     SUBTYPE VAL_STRING IS STRING (1..MAX_VAL_LENGTH);

     TYPE REC_TYPE IS RECORD
          MACRO_NAME : STRING (1..80);
          NAME_LENGTH, VALUE_LENGTH : INTEGER;
          MACRO_VALUE : VAL_STRING;
     END RECORD;

     TYPE TABLE_TYPE IS ARRAY (1..100) OF REC_TYPE;

     SYMBOL_TABLE : TABLE_TYPE;

     NUM_MACROS : INTEGER;

END DEFS;
