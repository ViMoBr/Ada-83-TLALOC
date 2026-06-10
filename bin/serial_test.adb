-- serial_test.adb
--
-- Programme de test TLALOC : envoi de caractères et commandes
-- vers le terminal Arduino ILI9481 via /dev/ttyUSB0
--
-- Compiler :  a83.sh serial_test.adb
-- Préparer le port avant l'exécution :
--   stty -F /dev/ttyUSB0 9600 cs8 -cstopb -parenb raw -echo
-- Exécuter :
--   ./serial_test
--
-- Protocole binaire (voir serial_terminal_ili9481.ino) :
--   0x01 nn  = couleur texte  (nn = 0..7)
--   0x02 nn  = couleur fond   (nn = 0..7)
--   0x03     = effacer écran
--   0x0A     = nouvelle ligne
--   0x20..0x7E = caractère imprimable

with SEQUENTIAL_IO;
with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			SERIAL_TEST
is			-----------

  -- Instanciation de SEQUENTIAL_IO pour CHARACTER
  -- Chaque WRITE envoie exactement 1 octet — parfait pour le protocole

  package CHAR_IO is new SEQUENTIAL_IO( ELEMENT_TYPE => CHARACTER );
  use CHAR_IO;

  -- Commandes protocole (constantes CHARACTER)

  CMD_FG_COLOR  : constant CHARACTER := CHARACTER'VAL( 16#01# );
  CMD_BG_COLOR  : constant CHARACTER := CHARACTER'VAL( 16#02# );
  CMD_CLS       : constant CHARACTER := CHARACTER'VAL( 16#03# );
  CMD_NEWLINE   : constant CHARACTER := CHARACTER'VAL( 16#0A# );

  -- Index de couleurs
  COL_NOIR      : constant CHARACTER := CHARACTER'VAL( 0 );
  COL_ROUGE     : constant CHARACTER := CHARACTER'VAL( 1 );
  COL_VERT      : constant CHARACTER := CHARACTER'VAL( 2 );
  COL_JAUNE     : constant CHARACTER := CHARACTER'VAL( 3 );
  COL_BLEU      : constant CHARACTER := CHARACTER'VAL( 4 );
  COL_MAGENTA   : constant CHARACTER := CHARACTER'VAL( 5 );
  COL_CYAN      : constant CHARACTER := CHARACTER'VAL( 6 );
  COL_BLANC     : constant CHARACTER := CHARACTER'VAL( 7 );

  PORT          : CHAR_IO.FILE_TYPE;


  -- Procédure utilitaire : envoyer une chaîne caractère par caractère

  procedure SEND_STR( F : in CHAR_IO.FILE_TYPE; S : in STRING )
  is
    I : INTEGER;
  begin
    I := S'FIRST;
    while I <= S'LAST loop
      CHAR_IO.WRITE( F, S(I) );
      I := I + 1;
    end loop;
  end SEND_STR;


begin

  -- Ouverture du port série
  -- stty doit avoir été exécuté avant (vitesse, mode raw)

  CHAR_IO.OPEN( PORT, CHAR_IO.OUT_FILE, "/dev/ttyACM0" );

  PUT_LINE( "Port serie ouvert." );

  -- -------------------------------------------------------
  -- Section 1 : effacement écran + message de bienvenue
  -- -------------------------------------------------------

  CHAR_IO.WRITE( PORT, CMD_CLS );

  CHAR_IO.WRITE( PORT, CMD_FG_COLOR );
  CHAR_IO.WRITE( PORT, COL_JAUNE );

  SEND_STR( PORT, "=== TLALOC Ada 83 -> ILI9481 ===" );
  CHAR_IO.WRITE( PORT, CMD_NEWLINE );

  -- -------------------------------------------------------
  -- Section 2 : alphabet en blanc
  -- -------------------------------------------------------

  CHAR_IO.WRITE( PORT, CMD_FG_COLOR );
  CHAR_IO.WRITE( PORT, COL_BLANC );

  SEND_STR( PORT, "Alphabet : " );

  declare
    C : CHARACTER;
    V : INTEGER;
  begin
    V := CHARACTER'POS( 'A' );
    while V <= CHARACTER'POS( 'Z' ) loop
      C := CHARACTER'VAL( V );
      CHAR_IO.WRITE( PORT, C );
      V := V + 1;
    end loop;
  end;
  CHAR_IO.WRITE( PORT, 'Z' );

  CHAR_IO.WRITE( PORT, CMD_NEWLINE );

  -- -------------------------------------------------------
  -- Section 3 : chiffres en cyan
  -- -------------------------------------------------------

  CHAR_IO.WRITE( PORT, CMD_FG_COLOR );
  CHAR_IO.WRITE( PORT, COL_CYAN );

  SEND_STR( PORT, "Chiffres : 0123456789" );
  CHAR_IO.WRITE( PORT, CMD_NEWLINE );

  -- -------------------------------------------------------
  -- Section 4 : message final en vert
  -- -------------------------------------------------------

  CHAR_IO.WRITE( PORT, CMD_FG_COLOR );
  CHAR_IO.WRITE( PORT, COL_VERT );

  SEND_STR( PORT, "Test termine avec succes." );
  CHAR_IO.WRITE( PORT, CMD_NEWLINE );

  -- Retour couleur par défaut
  CHAR_IO.WRITE( PORT, CMD_FG_COLOR );
  CHAR_IO.WRITE( PORT, COL_BLANC );

  -- Fermeture propre
  CHAR_IO.CLOSE( PORT );

  PUT_LINE( "Envoi termine, port ferme." );

end	SERIAL_TEST;
	-----------
