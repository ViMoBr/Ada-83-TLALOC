-- B74103C.ADA

-- CHECK THAT BEFORE THE FULL DECLARATION OF A PRIVATE TYPE, 

     -- (1) THE NAME OF THE PRIVATE TYPE,
     -- (2) A NAME THAT DENOTES A SUBTYPE OF THE PRIVATE TYPE, AND
     -- (3) A NAME THAT DENOTES A COMPOSITE TYPE WITH A SUBCOMPONENT 
     --     OF THE PRIVATE TYPE (OR SUBTYPE)

--  MAY NOT BE USED IN A DEFAULT EXPRESSION FOR A RECORD COMPONENT.


-- DSJ 4/27/83
-- BHS 6/14/84

PROCEDURE B74103C IS

     PACKAGE PACK1 IS

          TYPE P1 IS PRIVATE;
          TYPE LP2 IS LIMITED PRIVATE;

          SUBTYPE SP1 IS P1;
          SUBTYPE SLP2 IS LP2;

          TYPE ARR1_P1 IS ARRAY ( 1 .. 2 ) OF P1;
          TYPE ARR2_LP2 IS ARRAY ( 1 .. 2 ) OF LP2;
          TYPE ARR3_SP1 IS ARRAY ( 1 .. 2 ) OF SP1;
          TYPE ARR4_SLP2 IS ARRAY ( 1 .. 2 ) OF SLP2;
          TYPE ARR51 IS ARRAY ( 1 .. 2 ) OF ARR1_P1;
          TYPE ARR52 IS ARRAY ( 1 .. 2 ) OF ARR2_LP2;
          TYPE ARR53 IS ARRAY ( 1 .. 2 ) OF ARR3_SP1;
          TYPE ARR54 IS ARRAY ( 1 .. 2 ) OF ARR4_SLP2;

          TYPE REC1 IS
               RECORD
                    C1 : P1;
               END RECORD;

          TYPE REC2 IS
               RECORD
                    C2 : LP2;
               END RECORD;

          TYPE REC3 IS
               RECORD
                    C3 : SP1;
               END RECORD;

          TYPE REC4 IS
               RECORD
                    C4 : SLP2;
               END RECORD;
               
          TYPE REC51 IS
               RECORD
                    C5 : REC1;
               END RECORD;

          TYPE REC52 IS
               RECORD
                    C6 : REC2;
               END RECORD;

          TYPE REC53 IS
               RECORD
                    C7 : REC3;
               END RECORD;

          TYPE REC54 IS
               RECORD
                    C8 : REC4;
               END RECORD;

          SUBTYPE SS1 IS ARR1_P1;
          SUBTYPE SS2 IS ARR2_LP2;
          SUBTYPE SS3 IS ARR3_SP1;
          SUBTYPE SS4 IS ARR4_SLP2;
          SUBTYPE SS5 IS REC1;
          SUBTYPE SS6 IS REC2;
          SUBTYPE SS7 IS REC3;
          SUBTYPE SS8 IS REC4;

          ------------------------------------------------------------

          TYPE VISIBLE_REC IS
          RECORD
             C01 : INTEGER := P1'SIZE;      -- ERROR: USE OF TYPE NAME
             C02 : INTEGER := LP2'SIZE;     -- ERROR: USE OF TYPE NAME
             C03 : INTEGER := SP1'SIZE;     -- ERROR: USE OF TYPE NAME
             C04 : INTEGER := SLP2'SIZE;    -- ERROR: USE OF TYPE NAME
             C05 : INTEGER := ARR1_P1'SIZE; -- ERROR: USE OF TYPE NAME
             C06 : INTEGER := ARR2_LP2'SIZE;-- ERROR: USE OF TYPE NAME
             C07 : INTEGER := ARR3_SP1'SIZE;-- ERROR: USE OF TYPE NAME
             C08 : INTEGER := ARR4_SLP2'SIZE;-- ERROR: USE OF TYPE NAME
             C09 : INTEGER := REC1'SIZE;    -- ERROR: USE OF TYPE NAME
             C10 : INTEGER := REC2'SIZE;    -- ERROR: USE OF TYPE NAME
             C11 : INTEGER := REC3'SIZE;    -- ERROR: USE OF TYPE NAME
             C12 : INTEGER := REC4'SIZE;    -- ERROR: USE OF TYPE NAME
             C13 : INTEGER := SS1'SIZE;     -- ERROR: USE OF TYPE NAME
             C14 : INTEGER := SS2'SIZE;     -- ERROR: USE OF TYPE NAME
             C15 : INTEGER := SS3'SIZE;     -- ERROR: USE OF TYPE NAME
             C16 : INTEGER := SS4'SIZE;     -- ERROR: USE OF TYPE NAME
             C17 : INTEGER := SS5'SIZE;     -- ERROR: USE OF TYPE NAME
             C18 : INTEGER := SS6'SIZE;     -- ERROR: USE OF TYPE NAME
             C19 : INTEGER := SS7'SIZE;     -- ERROR: USE OF TYPE NAME
             C20 : INTEGER := SS8'SIZE;     -- ERROR: USE OF TYPE NAME
             C21 : INTEGER := ARR51'SIZE;   -- ERROR: USE OF TYPE NAME
             C22 : INTEGER := ARR52'SIZE;   -- ERROR: USE OF TYPE NAME
             C23 : INTEGER := ARR53'SIZE;   -- ERROR: USE OF TYPE NAME
             C24 : INTEGER := ARR54'SIZE;   -- ERROR: USE OF TYPE NAME
             C25 : INTEGER := REC51'SIZE;   -- ERROR: USE OF TYPE NAME
             C26 : INTEGER := REC52'SIZE;   -- ERROR: USE OF TYPE NAME
             C27 : INTEGER := REC53'SIZE;   -- ERROR: USE OF TYPE NAME
             C28 : INTEGER := REC54'SIZE;   -- ERROR: USE OF TYPE NAME
          END RECORD;

     PRIVATE

          TYPE PRIVATE_REC IS
          RECORD
             C01 : INTEGER := P1'SIZE;       -- ERROR: USE OF TYPE NAME
             C02 : INTEGER := LP2'SIZE;      -- ERROR: USE OF TYPE NAME
             C03 : INTEGER := SP1'SIZE;      -- ERROR: USE OF TYPE NAME
             C04 : INTEGER := SLP2'SIZE;     -- ERROR: USE OF TYPE NAME
             C05 : INTEGER := ARR1_P1'SIZE;  -- ERROR: USE OF TYPE NAME
             C06 : INTEGER := ARR2_LP2'SIZE; -- ERROR: USE OF TYPE NAME
             C07 : INTEGER := ARR3_SP1'SIZE; -- ERROR: USE OF TYPE NAME
             C08 : INTEGER := ARR4_SLP2'SIZE;-- ERROR: USE OF TYPE NAME
             C09 : INTEGER := REC1'SIZE;    -- ERROR: USE OF TYPE NAME
             C10 : INTEGER := REC2'SIZE;    -- ERROR: USE OF TYPE NAME
             C11 : INTEGER := REC3'SIZE;    -- ERROR: USE OF TYPE NAME
             C12 : INTEGER := REC4'SIZE;    -- ERROR: USE OF TYPE NAME
             C13 : INTEGER := SS1'SIZE;     -- ERROR: USE OF TYPE NAME
             C14 : INTEGER := SS2'SIZE;     -- ERROR: USE OF TYPE NAME
             C15 : INTEGER := SS3'SIZE;     -- ERROR: USE OF TYPE NAME
             C16 : INTEGER := SS4'SIZE;     -- ERROR: USE OF TYPE NAME
             C17 : INTEGER := SS5'SIZE;     -- ERROR: USE OF TYPE NAME
             C18 : INTEGER := SS6'SIZE;     -- ERROR: USE OF TYPE NAME
             C19 : INTEGER := SS7'SIZE;     -- ERROR: USE OF TYPE NAME
             C20 : INTEGER := SS8'SIZE;     -- ERROR: USE OF TYPE NAME
             C21 : INTEGER := ARR51'SIZE;   -- ERROR: USE OF TYPE NAME
             C22 : INTEGER := ARR52'SIZE;   -- ERROR: USE OF TYPE NAME
             C23 : INTEGER := ARR53'SIZE;   -- ERROR: USE OF TYPE NAME
             C24 : INTEGER := ARR54'SIZE;   -- ERROR: USE OF TYPE NAME
             C25 : INTEGER := REC51'SIZE;   -- ERROR: USE OF TYPE NAME
             C26 : INTEGER := REC52'SIZE;   -- ERROR: USE OF TYPE NAME
             C27 : INTEGER := REC53'SIZE;   -- ERROR: USE OF TYPE NAME
             C28 : INTEGER := REC54'SIZE;   -- ERROR: USE OF TYPE NAME
          END RECORD ;


          TYPE  P1 IS NEW INTEGER;
          TYPE  LP2 IS NEW INTEGER;

          TYPE OK_PRIVATE_REC IS
          RECORD
             CC01 : INTEGER := P1'SIZE;        -- TYPE NAME USE OK
             CC02 : INTEGER := LP2'SIZE;       -- TYPE NAME USE OK
             CC03 : INTEGER := SP1'SIZE;       -- TYPE NAME USE OK
             CC04 : INTEGER := SLP2'SIZE;      -- TYPE NAME USE OK
             CC05 : INTEGER := ARR1_P1'SIZE;   -- TYPE NAME USE OK
             CC06 : INTEGER := ARR2_LP2'SIZE;  -- TYPE NAME USE OK
             CC07 : INTEGER := ARR3_SP1'SIZE;  -- TYPE NAME USE OK
             CC08 : INTEGER := ARR4_SLP2'SIZE; -- TYPE NAME USE OK
             CC09 : INTEGER := REC1'SIZE;      -- TYPE NAME USE OK
             CC10 : INTEGER := REC2'SIZE;      -- TYPE NAME USE OK
             CC11 : INTEGER := REC3'SIZE;      -- TYPE NAME USE OK
             CC12 : INTEGER := REC4'SIZE;      -- TYPE NAME USE OK
             CC13 : INTEGER := SS1'SIZE;       -- TYPE NAME USE OK
             CC14 : INTEGER := SS2'SIZE;       -- TYPE NAME USE OK
             CC15 : INTEGER := SS3'SIZE;       -- TYPE NAME USE OK
             CC16 : INTEGER := SS4'SIZE;       -- TYPE NAME USE OK
             CC17 : INTEGER := SS5'SIZE;       -- TYPE NAME USE OK
             CC18 : INTEGER := SS6'SIZE;       -- TYPE NAME USE OK
             CC19 : INTEGER := SS7'SIZE;       -- TYPE NAME USE OK
             CC20 : INTEGER := SS8'SIZE;       -- TYPE NAME USE OK
             CC21 : INTEGER := ARR51'SIZE;     -- TYPE NAME USE OK
             CC22 : INTEGER := ARR52'SIZE;     -- TYPE NAME USE OK
             CC23 : INTEGER := ARR53'SIZE;     -- TYPE NAME USE OK
             CC24 : INTEGER := ARR54'SIZE;     -- TYPE NAME USE OK
             CC25 : INTEGER := REC51'SIZE;     -- TYPE NAME USE OK
             CC26 : INTEGER := REC52'SIZE;     -- TYPE NAME USE OK
             CC27 : INTEGER := REC53'SIZE;     -- TYPE NAME USE OK
             CC28 : INTEGER := REC54'SIZE;     -- TYPE NAME USE OK
          END RECORD;

     END PACK1;


BEGIN

     NULL;


END B74103C;
