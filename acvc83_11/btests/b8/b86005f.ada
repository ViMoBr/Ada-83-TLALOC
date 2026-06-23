-- B86005F.ADA

-- OBJECTIVE:
--     CHECK THAT THE IDENTIFIERS OF THE NON-GRAPHIC CHARACTERS ARE NOT
--     DIRECTLY VISIBLE IN STANDARD.

-- HISTORY:
--     DHH 07/20/88 CREATED ORIGINAL TEST.

PROCEDURE B86005F IS
     C1 : CHARACTER;
BEGIN

     IF STANDARD.NUL = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.SOH = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.STX = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.ETX = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.EOT = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.ENQ = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.ACK = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.BEL = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.BS = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.HT = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.LF = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.VT = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.FF = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.CR = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.SO = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.SI = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.DLE = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.DC1 = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.DC2 = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.DC3 = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.DC4 = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.NAK = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.SYN = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.ETB = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.CAN = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.EM = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.SUB = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.ESC = 'A' THEN    -- ERROR:
          NULL;
     END IF;

     IF STANDARD.FS = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.GS = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.RS = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.US = 'A' THEN     -- ERROR:
          NULL;
     END IF;

     IF STANDARD.DEL = 'A' THEN    -- ERROR:
          NULL;
     END IF;

END B86005F;
