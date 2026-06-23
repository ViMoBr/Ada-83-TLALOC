-- B74103F.ADA

-- CHECK THAT BEFORE THE FULL DECLARATION OF A PRIVATE TYPE, THE
-- FOLLOWING NAMES MAY NOT BE USED AS A GENERIC FORMAL PARAMETER 
-- ( OBJECT, ARRAY TYPE, OR ACCESS TYPE ) :

     -- (1) THE NAME OF THE PRIVATE TYPE,
     -- (2) A NAME THAT DENOTES A SUBTYPE OF THE PRIVATE TYPE, AND
     -- (3) A NAME THAT DENOTES A COMPOSITE TYPE WITH A SUBCOMPONENT 
     --     OF THE PRIVATE TYPE (OR SUBTYPE).


-- BHS 6/18/84

PROCEDURE B74103F IS

     PACKAGE PACK1 IS

          TYPE PR IS PRIVATE;
          TYPE LP IS LIMITED PRIVATE;

          SUBTYPE SPR IS PR;
          SUBTYPE SLP IS LP;

          TYPE ARR1_PR IS ARRAY (1..2) OF PR;
          TYPE ARR2_LP IS ARRAY (1..2) OF LP;
          TYPE ARR3_SP IS ARRAY (1..2) OF SPR;
          TYPE ARR4_SL IS ARRAY (1..2) OF SLP;
          TYPE ARR51 IS ARRAY (1..2) OF ARR1_PR;
          TYPE ARR52 IS ARRAY (1..2) OF ARR2_LP;
          TYPE ARR53 IS ARRAY (1..2) OF ARR3_SP;
          TYPE ARR54 IS ARRAY (1..2) OF ARR4_SL;

          TYPE REC1_PR IS
               RECORD
                    C1 : PR;
               END RECORD;

          TYPE REC2_LP IS
               RECORD
                    C2 : LP;
               END RECORD;

          TYPE REC3_SP IS
               RECORD
                    C3 : SPR;
               END RECORD;

          TYPE REC4_SL IS
               RECORD
                    C4 : SLP;
               END RECORD;

          TYPE REC51 IS
               RECORD
                    C5 : REC1_PR;
               END RECORD;

          TYPE REC52 IS
               RECORD
                    C6 : REC2_LP;
               END RECORD;

          TYPE REC53 IS
               RECORD
                    C7 : REC3_SP;
               END RECORD;

          TYPE REC54 IS
               RECORD
                    C8 : REC4_SL;
               END RECORD;

          SUBTYPE SA1 IS ARR1_PR;
          SUBTYPE SA2 IS ARR2_LP;
          SUBTYPE SA3 IS ARR3_SP;
          SUBTYPE SA4 IS ARR4_SL;
          SUBTYPE SR1 IS REC1_PR;
          SUBTYPE SR2 IS REC2_LP;
          SUBTYPE SR3 IS REC3_SP;
          SUBTYPE SR4 IS REC4_SL;

          SUBTYPE SMALL IS INTEGER RANGE 1..10;

          GENERIC  -- GEN1
               OBJ01 : IN OUT PR;           -- ERROR: USE OF PR
               OBJ02 : IN OUT LP;           -- ERROR: USE OF LP
               OBJ03 : IN OUT SPR;          -- ERROR: USE OF SPR
               OBJ04 : IN OUT SLP;          -- ERROR: USE OF SLP
               OBJ05 : IN OUT ARR1_PR;      -- ERROR: USE OF ARR1_PR
               OBJ06 : IN OUT ARR2_LP;      -- ERROR: USE OF ARR2_LP 
               OBJ07 : IN OUT ARR3_SP;      -- ERROR: USE OF ARR3_SP
               OBJ08 : IN OUT ARR4_SL;      -- ERROR: USE OF ARR4_SL
               OBJ09 : IN OUT ARR51;        -- ERROR: USE OF ARR51
               OBJ10 : IN OUT ARR52;        -- ERROR: USE OF ARR52
               OBJ11 : IN OUT ARR53;        -- ERROR: USE OF ARR53
               OBJ12 : IN OUT ARR54;        -- ERROR: USE OF ARR54
               OBJ13 : IN OUT REC1_PR;      -- ERROR: USE OF REC1_PR
               OBJ14 : IN OUT REC2_LP;      -- ERROR: USE OF REC2_LP
               OBJ15 : IN OUT REC3_SP;      -- ERROR: USE OF REC3_SP
               OBJ16 : IN OUT REC4_SL;      -- ERROR: USE OF REC4_SL
               OBJ17 : IN OUT REC51;        -- ERROR: USE OF REC51
               OBJ18 : IN OUT REC52;        -- ERROR: USE OF REC52
               OBJ19 : IN OUT REC53;        -- ERROR: USE OF REC53
               OBJ20 : IN OUT REC54;        -- ERROR: USE OF REC54
               OBJ21 : IN OUT SA1;          -- ERROR: USE OF SA1
               OBJ22 : IN OUT SA2;          -- ERROR: USE OF SA2
               OBJ23 : IN OUT SA3;          -- ERROR: USE OF SA3
               OBJ24 : IN OUT SA4;          -- ERROR: USE OF SA4
               OBJ25 : IN OUT SR1;          -- ERROR: USE OF SR1
               OBJ26 : IN OUT SR2;          -- ERROR: USE OF SR2
               OBJ27 : IN OUT SR3;          -- ERROR: USE OF SR3
               OBJ28 : IN OUT SR4;          -- ERROR: USE OF SR4

               TYPE A01 IS ARRAY(SMALL) OF PR;       -- ERROR: PR
               TYPE A02 IS ARRAY(SMALL) OF LP;       -- ERROR: LP
               TYPE A03 IS ARRAY(SMALL) OF SPR;      -- ERROR: SPR
               TYPE A04 IS ARRAY(SMALL) OF SLP;      -- ERROR: SLP
               TYPE A05 IS ARRAY(SMALL) OF ARR1_PR;  -- ERROR: ARR1_PR
               TYPE A06 IS ARRAY(SMALL) OF ARR2_LP;  -- ERROR: ARR2_LP
               TYPE A07 IS ARRAY(SMALL) OF ARR3_SP;  -- ERROR: ARR3_SP
               TYPE A08 IS ARRAY(SMALL) OF ARR4_SL;  -- ERROR: ARR4_SL
               TYPE A09 IS ARRAY(SMALL) OF ARR51;    -- ERROR: ARR51
               TYPE A10 IS ARRAY(SMALL) OF ARR52;    -- ERROR: ARR52
               TYPE A11 IS ARRAY(SMALL) OF ARR53;    -- ERROR: ARR53
               TYPE A12 IS ARRAY(SMALL) OF ARR54;    -- ERROR: ARR54
               TYPE A13 IS ARRAY(SMALL) OF REC1_PR;  -- ERROR: REC1_PR
               TYPE A14 IS ARRAY(SMALL) OF REC2_LP;  -- ERROR: REC2_LP
               TYPE A15 IS ARRAY(SMALL) OF REC3_SP;  -- ERROR: REC3_SP
               TYPE A16 IS ARRAY(SMALL) OF REC4_SL;  -- ERROR: REC4_SL
               TYPE A17 IS ARRAY(SMALL) OF REC51;    -- ERROR: REC51
               TYPE A18 IS ARRAY(SMALL) OF REC52;    -- ERROR: REC52
               TYPE A19 IS ARRAY(SMALL) OF REC53;    -- ERROR: REC53
               TYPE A20 IS ARRAY(SMALL) OF REC54;    -- ERROR: REC54
               TYPE A21 IS ARRAY(SMALL) OF SA1;      -- ERROR: SA1
               TYPE A22 IS ARRAY(SMALL) OF SA2;      -- ERROR: SA2
               TYPE A23 IS ARRAY(SMALL) OF SA3;      -- ERROR: SA3
               TYPE A24 IS ARRAY(SMALL) OF SA4;      -- ERROR: SA4
               TYPE A25 IS ARRAY(SMALL) OF SR1;      -- ERROR: SR1
               TYPE A26 IS ARRAY(SMALL) OF SR2;      -- ERROR: SR2
               TYPE A27 IS ARRAY(SMALL) OF SR3;      -- ERROR: SR3
               TYPE A28 IS ARRAY(SMALL) OF SR4;      -- ERROR: SR4

               TYPE AC01 IS ACCESS PR;             -- ERROR: PR
               TYPE AC02 IS ACCESS LP;             -- ERROR: LP
               TYPE AC03 IS ACCESS SPR;            -- ERROR: SPR
               TYPE AC04 IS ACCESS SLP;            -- ERROR: SLP
               TYPE AC05 IS ACCESS ARR1_PR;        -- ERROR: ARR1_PR
               TYPE AC06 IS ACCESS ARR2_LP;        -- ERROR: ARR2_LP
               TYPE AC07 IS ACCESS ARR3_SP;        -- ERROR: ARR3_SP
               TYPE AC08 IS ACCESS ARR4_SL;        -- ERROR: ARR4_SL
               TYPE AC09 IS ACCESS ARR51;          -- ERROR: ARR51
               TYPE AC10 IS ACCESS ARR52;          -- ERROR: ARR52
               TYPE AC11 IS ACCESS ARR53;          -- ERROR: ARR53
               TYPE AC12 IS ACCESS ARR54;          -- ERROR: ARR54
               TYPE AC13 IS ACCESS REC1_PR;        -- ERROR: REC1_PR
               TYPE AC14 IS ACCESS REC2_LP;        -- ERROR: REC2_LP
               TYPE AC15 IS ACCESS REC3_SP;        -- ERROR: REC3_SP
               TYPE AC16 IS ACCESS REC4_SL;        -- ERROR: REC4_SL
               TYPE AC17 IS ACCESS REC51;          -- ERROR: REC51
               TYPE AC18 IS ACCESS REC52;          -- ERROR: REC52
               TYPE AC19 IS ACCESS REC53;          -- ERROR: REC53
               TYPE AC20 IS ACCESS REC54;          -- ERROR: REC54
               TYPE AC21 IS ACCESS SA1;            -- ERROR: SA1
               TYPE AC22 IS ACCESS SA2;            -- ERROR: SA2
               TYPE AC23 IS ACCESS SA3;            -- ERROR: SA3
               TYPE AC24 IS ACCESS SA4;            -- ERROR: SA4
               TYPE AC25 IS ACCESS SR1;            -- ERROR: SR1
               TYPE AC26 IS ACCESS SR2;            -- ERROR: SR2
               TYPE AC27 IS ACCESS SR3;            -- ERROR: SR3
               TYPE AC28 IS ACCESS SR4;            -- ERROR: SR4

          PACKAGE GEN1 IS END GEN1;

          PRIVATE

          GENERIC  -- GEN2
               PRO01 : IN OUT PR;           -- ERROR: USE OF PR
               PRO02 : IN OUT LP;           -- ERROR: USE OF LP
               PRO03 : IN OUT SPR;          -- ERROR: USE OF SPR
               PRO04 : IN OUT SLP;          -- ERROR: USE OF SLP
               PRO05 : IN OUT ARR1_PR;      -- ERROR: USE OF ARR1_PR
               PRO06 : IN OUT ARR2_LP;      -- ERROR: USE OF ARR2_LP 
               PRO07 : IN OUT ARR3_SP;      -- ERROR: USE OF ARR3_SP
               PRO08 : IN OUT ARR4_SL;      -- ERROR: USE OF ARR4_SL
               PRO09 : IN OUT ARR51;        -- ERROR: USE OF ARR51
               PRO10 : IN OUT ARR52;        -- ERROR: USE OF ARR52
               PRO11 : IN OUT ARR53;        -- ERROR: USE OF ARR53
               PRO12 : IN OUT ARR54;        -- ERROR: USE OF ARR54
               PRO13 : IN OUT REC1_PR;      -- ERROR: USE OF REC1_PR
               PRO14 : IN OUT REC2_LP;      -- ERROR: USE OF REC2_LP
               PRO15 : IN OUT REC3_SP;      -- ERROR: USE OF REC3_SP
               PRO16 : IN OUT REC4_SL;      -- ERROR: USE OF REC4_SL
               PRO17 : IN OUT REC51;        -- ERROR: USE OF REC51
               PRO18 : IN OUT REC52;        -- ERROR: USE OF REC52
               PRO19 : IN OUT REC53;        -- ERROR: USE OF REC53
               PRO20 : IN OUT REC54;        -- ERROR: USE OF REC54
               PRO21 : IN OUT SA1;          -- ERROR: USE OF SA1
               PRO22 : IN OUT SA2;          -- ERROR: USE OF SA2
               PRO23 : IN OUT SA3;          -- ERROR: USE OF SA3
               PRO24 : IN OUT SA4;          -- ERROR: USE OF SA4
               PRO25 : IN OUT SR1;          -- ERROR: USE OF SR1
               PRO26 : IN OUT SR2;          -- ERROR: USE OF SR2
               PRO27 : IN OUT SR3;          -- ERROR: USE OF SR3
               PRO28 : IN OUT SR4;          -- ERROR: USE OF SR4

               TYPE B01 IS ARRAY(SMALL) OF PR;       -- ERROR: PR
               TYPE B02 IS ARRAY(SMALL) OF LP;       -- ERROR: LP
               TYPE B03 IS ARRAY(SMALL) OF SPR;      -- ERROR: SPR
               TYPE B04 IS ARRAY(SMALL) OF SLP;      -- ERROR: SLP
               TYPE B05 IS ARRAY(SMALL) OF ARR1_PR;  -- ERROR: ARR1_PR
               TYPE B06 IS ARRAY(SMALL) OF ARR2_LP;  -- ERROR: ARR2_LP
               TYPE B07 IS ARRAY(SMALL) OF ARR3_SP;  -- ERROR: ARR3_SP
               TYPE B08 IS ARRAY(SMALL) OF ARR4_SL;  -- ERROR: ARR4_SL
               TYPE B09 IS ARRAY(SMALL) OF ARR51;    -- ERROR: ARR51
               TYPE B10 IS ARRAY(SMALL) OF ARR52;    -- ERROR: ARR52
               TYPE B11 IS ARRAY(SMALL) OF ARR53;    -- ERROR: ARR53
               TYPE B12 IS ARRAY(SMALL) OF ARR54;    -- ERROR: ARR54
               TYPE B13 IS ARRAY(SMALL) OF REC1_PR;  -- ERROR: REC1_PR
               TYPE B14 IS ARRAY(SMALL) OF REC2_LP;  -- ERROR: REC2_LP
               TYPE B15 IS ARRAY(SMALL) OF REC3_SP;  -- ERROR: REC3_SP
               TYPE B16 IS ARRAY(SMALL) OF REC4_SL;  -- ERROR: REC4_SL
               TYPE B17 IS ARRAY(SMALL) OF REC51;    -- ERROR: REC51
               TYPE B18 IS ARRAY(SMALL) OF REC52;    -- ERROR: REC52
               TYPE B19 IS ARRAY(SMALL) OF REC53;    -- ERROR: REC53
               TYPE B20 IS ARRAY(SMALL) OF REC54;    -- ERROR: REC54
               TYPE B21 IS ARRAY(SMALL) OF SA1;      -- ERROR: SA1
               TYPE B22 IS ARRAY(SMALL) OF SA2;      -- ERROR: SA2
               TYPE B23 IS ARRAY(SMALL) OF SA3;      -- ERROR: SA3
               TYPE B24 IS ARRAY(SMALL) OF SA4;      -- ERROR: SA4
               TYPE B25 IS ARRAY(SMALL) OF SR1;      -- ERROR: SR1
               TYPE B26 IS ARRAY(SMALL) OF SR2;      -- ERROR: SR2
               TYPE B27 IS ARRAY(SMALL) OF SR3;      -- ERROR: SR3
               TYPE B28 IS ARRAY(SMALL) OF SR4;      -- ERROR: SR4

               TYPE BC01 IS ACCESS PR;             -- ERROR: PR
               TYPE BC02 IS ACCESS LP;             -- ERROR: LP
               TYPE BC03 IS ACCESS SPR;            -- ERROR: SPR
               TYPE BC04 IS ACCESS SLP;            -- ERROR: SLP
               TYPE BC05 IS ACCESS ARR1_PR;        -- ERROR: ARR1_PR
               TYPE BC06 IS ACCESS ARR2_LP;        -- ERROR: ARR2_LP
               TYPE BC07 IS ACCESS ARR3_SP;        -- ERROR: ARR3_SP
               TYPE BC08 IS ACCESS ARR4_SL;        -- ERROR: ARR4_SL
               TYPE BC09 IS ACCESS ARR51;          -- ERROR: ARR51
               TYPE BC10 IS ACCESS ARR52;          -- ERROR: ARR52
               TYPE BC11 IS ACCESS ARR53;          -- ERROR: ARR53
               TYPE BC12 IS ACCESS ARR54;          -- ERROR: ARR54
               TYPE BC13 IS ACCESS REC1_PR;        -- ERROR: REC1_PR
               TYPE BC14 IS ACCESS REC2_LP;        -- ERROR: REC2_LP
               TYPE BC15 IS ACCESS REC3_SP;        -- ERROR: REC3_SP
               TYPE BC16 IS ACCESS REC4_SL;        -- ERROR: REC4_SL
               TYPE BC17 IS ACCESS REC51;          -- ERROR: REC51
               TYPE BC18 IS ACCESS REC52;          -- ERROR: REC52
               TYPE BC19 IS ACCESS REC53;          -- ERROR: REC53
               TYPE BC20 IS ACCESS REC54;          -- ERROR: REC54
               TYPE BC21 IS ACCESS SA1;            -- ERROR: SA1
               TYPE BC22 IS ACCESS SA2;            -- ERROR: SA2
               TYPE BC23 IS ACCESS SA3;            -- ERROR: SA3
               TYPE BC24 IS ACCESS SA4;            -- ERROR: SA4
               TYPE BC25 IS ACCESS SR1;            -- ERROR: SR1
               TYPE BC26 IS ACCESS SR2;            -- ERROR: SR2
               TYPE BC27 IS ACCESS SR3;            -- ERROR: SR3
               TYPE BC28 IS ACCESS SR4;            -- ERROR: SR4

          PACKAGE GEN2 IS END GEN2;
          ----------------------------------------------------------

          TYPE PR IS NEW INTEGER;
          TYPE LP IS NEW INTEGER;

          ----------------------------------------------------------

          GENERIC  -- GEN3
               OK01 : IN OUT PR;           -- LEGAL USE OF PR
               OK02 : IN OUT LP;           -- LEGAL USE OF LP
               OK03 : IN OUT SPR;          -- LEGAL USE OF SPR
               OK04 : IN OUT SLP;          -- LEGAL USE OF SLP
               OK05 : IN OUT ARR1_PR;      -- LEGAL USE OF ARR1_PR
               OK06 : IN OUT ARR2_LP;      -- LEGAL USE OF ARR2_LP 
               OK07 : IN OUT ARR3_SP;      -- LEGAL USE OF ARR3_SP
               OK08 : IN OUT ARR4_SL;      -- LEGAL USE OF ARR4_SL
               OK09 : IN OUT ARR51;        -- LEGAL USE OF ARR51
               OK10 : IN OUT ARR52;        -- LEGAL USE OF ARR52
               OK11 : IN OUT ARR53;        -- LEGAL USE OF ARR53
               OK12 : IN OUT ARR54;        -- LEGAL USE OF ARR54
               OK13 : IN OUT REC1_PR;      -- LEGAL USE OF REC1_PR
               OK14 : IN OUT REC2_LP;      -- LEGAL USE OF REC2_LP
               OK15 : IN OUT REC3_SP;      -- LEGAL USE OF REC3_SP
               OK16 : IN OUT REC4_SL;      -- LEGAL USE OF REC4_SL
               OK17 : IN OUT REC51;        -- LEGAL USE OF REC51
               OK18 : IN OUT REC52;        -- LEGAL USE OF REC52
               OK19 : IN OUT REC53;        -- LEGAL USE OF REC53
               OK20 : IN OUT REC54;        -- LEGAL USE OF REC54
               OK21 : IN OUT SA1;          -- LEGAL USE OF SA1
               OK22 : IN OUT SA2;          -- LEGAL USE OF SA2
               OK23 : IN OUT SA3;          -- LEGAL USE OF SA3
               OK24 : IN OUT SA4;          -- LEGAL USE OF SA4
               OK25 : IN OUT SR1;          -- LEGAL USE OF SR1
               OK26 : IN OUT SR2;          -- LEGAL USE OF SR2
               OK27 : IN OUT SR3;          -- LEGAL USE OF SR3
               OK28 : IN OUT SR4;          -- LEGAL USE OF SR4

               TYPE K01 IS ARRAY(SMALL) OF PR;       -- LEGAL PR
               TYPE K02 IS ARRAY(SMALL) OF LP;       -- LEGAL LP
               TYPE K03 IS ARRAY(SMALL) OF SPR;      -- LEGAL SPR
               TYPE K04 IS ARRAY(SMALL) OF SLP;      -- LEGAL SLP
               TYPE K05 IS ARRAY(SMALL) OF ARR1_PR;  -- LEGAL ARR1_PR
               TYPE K06 IS ARRAY(SMALL) OF ARR2_LP;  -- LEGAL ARR2_LP
               TYPE K07 IS ARRAY(SMALL) OF ARR3_SP;  -- LEGAL ARR3_SP
               TYPE K08 IS ARRAY(SMALL) OF ARR4_SL;  -- LEGAL ARR4_SL
               TYPE K09 IS ARRAY(SMALL) OF ARR51;    -- LEGAL ARR51
               TYPE K10 IS ARRAY(SMALL) OF ARR52;    -- LEGAL ARR52
               TYPE K11 IS ARRAY(SMALL) OF ARR53;    -- LEGAL ARR53
               TYPE K12 IS ARRAY(SMALL) OF ARR54;    -- LEGAL ARR54
               TYPE K13 IS ARRAY(SMALL) OF REC1_PR;  -- LEGAL REC1_PR
               TYPE K14 IS ARRAY(SMALL) OF REC2_LP;  -- LEGAL REC2_LP
               TYPE K15 IS ARRAY(SMALL) OF REC3_SP;  -- LEGAL REC3_SP
               TYPE K16 IS ARRAY(SMALL) OF REC4_SL;  -- LEGAL REC4_SL
               TYPE K17 IS ARRAY(SMALL) OF REC51;    -- LEGAL REC51
               TYPE K18 IS ARRAY(SMALL) OF REC52;    -- LEGAL REC52
               TYPE K19 IS ARRAY(SMALL) OF REC53;    -- LEGAL REC53
               TYPE K20 IS ARRAY(SMALL) OF REC54;    -- LEGAL REC54
               TYPE K21 IS ARRAY(SMALL) OF SA1;      -- LEGAL SA1
               TYPE K22 IS ARRAY(SMALL) OF SA2;      -- LEGAL SA2
               TYPE K23 IS ARRAY(SMALL) OF SA3;      -- LEGAL SA3
               TYPE K24 IS ARRAY(SMALL) OF SA4;      -- LEGAL SA4
               TYPE K25 IS ARRAY(SMALL) OF SR1;      -- LEGAL SR1
               TYPE K26 IS ARRAY(SMALL) OF SR2;      -- LEGAL SR2
               TYPE K27 IS ARRAY(SMALL) OF SR3;      -- LEGAL SR3
               TYPE K28 IS ARRAY(SMALL) OF SR4;      -- LEGAL SR4

               TYPE AK01 IS ACCESS PR;             -- LEGAL PR
               TYPE AK02 IS ACCESS LP;             -- LEGAL LP
               TYPE AK03 IS ACCESS SPR;            -- LEGAL SPR
               TYPE AK04 IS ACCESS SLP;            -- LEGAL SLP
               TYPE AK05 IS ACCESS ARR1_PR;        -- LEGAL ARR1_PR
               TYPE AK06 IS ACCESS ARR2_LP;        -- LEGAL ARR2_LP
               TYPE AK07 IS ACCESS ARR3_SP;        -- LEGAL ARR3_SP
               TYPE AK08 IS ACCESS ARR4_SL;        -- LEGAL ARR4_SL
               TYPE AK09 IS ACCESS ARR51;          -- LEGAL ARR51
               TYPE AK10 IS ACCESS ARR52;          -- LEGAL ARR52
               TYPE AK11 IS ACCESS ARR53;          -- LEGAL ARR53
               TYPE AK12 IS ACCESS ARR54;          -- LEGAL ARR54
               TYPE AK13 IS ACCESS REC1_PR;        -- LEGAL REC1_PR
               TYPE AK14 IS ACCESS REC2_LP;        -- LEGAL REC2_LP
               TYPE AK15 IS ACCESS REC3_SP;        -- LEGAL REC3_SP
               TYPE AK16 IS ACCESS REC4_SL;        -- LEGAL REC4_SL
               TYPE AK17 IS ACCESS REC51;          -- LEGAL REC51
               TYPE AK18 IS ACCESS REC52;          -- LEGAL REC52
               TYPE AK19 IS ACCESS REC53;          -- LEGAL REC53
               TYPE AK20 IS ACCESS REC54;          -- LEGAL REC54
               TYPE AK21 IS ACCESS SA1;            -- LEGAL SA1
               TYPE AK22 IS ACCESS SA2;            -- LEGAL SA2
               TYPE AK23 IS ACCESS SA3;            -- LEGAL SA3
               TYPE AK24 IS ACCESS SA4;            -- LEGAL SA4
               TYPE AK25 IS ACCESS SR1;            -- LEGAL SR1
               TYPE AK26 IS ACCESS SR2;            -- LEGAL SR2
               TYPE AK27 IS ACCESS SR3;            -- LEGAL SR3
               TYPE AK28 IS ACCESS SR4;            -- LEGAL SR4

          PACKAGE GEN3 IS END GEN3;
     
     END PACK1;

BEGIN

     NULL;

END B74103F;
