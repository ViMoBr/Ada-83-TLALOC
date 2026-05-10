------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO;
use  TEXT_IO;
with IDL;					--| LA VERSION ADAPTÉE À LA GESTION DES	STRUCTURES DE GRAMMAIRE LALR
--|-------------------------------------------------------------------------------------------------
--|	LALR_TOOLS
procedure	LALR_TOOLS is

  C	: CHARACTER;
  L	: NATURAL;
  CMD	: STRING(1..64);
begin

  loop
    NEW_LINE;
    PUT_LINE ( "--------------------------" );
    PUT_LINE ( "          LALR TOOLS" );
    PUT_LINE ( "--------------------------" );
    NEW_LINE;
    PUT_LINE ( "LIRE GRAMMAIRE .......... R" );
    PUT_LINE ( "OPTIMISER ............... O" );
    PUT_LINE ( "INITIALIER .............. I" );
    PUT_LINE ( "CREER LES ETATS ......... E" );
    PUT_LINE ( "ANALYSE LALR ............ L" );
    PUT_LINE ( "VERIFICATION ............ V" );
    PUT_LINE ( "IMPRIME LES TABLES ...... P" );
    PUT_LINE ( "BINARISE LES TABLES ..... B" );
    NEW_LINE;
    PUT_LINE ( "QUITTER ................. Q" );
    NEW_LINE;
    PUT (	"     CHOIX : " ); GET_LINE (	CMD, L );
    C := CMD( 1 );
    NEW_LINE;

    case C is
    when 'R' | 'O' | 'I' | 'E' | 'L' | 'V' | 'B' | 'P' =>
      PUT	( "NOM DE TEXTE : "	); GET_LINE ( CMD, L );
      NEW_LINE;
    when 'Q' =>
      exit;
    when others =>
      PUT	( " ?! COMMANDE INCOMPRISE" );
      goto FIN_TRAITEMENT;
    end case;

    if C = 'P' then
      PUT_LINE ( "---------- PRINT_STAT ----------" );  IDL.PRINT_STAT ( CMD( 1..L ) );
      goto FIN_TRAITEMENT;
    end if;

    PUT_LINE ( "---------- READ_GRMR ----------" );   IDL.READ_GRMR (	CMD( 1..L	) );
    if C = 'R' then	goto FIN_TRAITEMENT; end if;

    PUT_LINE ( "---------- OPTR_GRMR ----------" );   IDL.OPTR_GRMR (	CMD( 1..L	) );
    if C = 'O' then	goto FIN_TRAITEMENT; end if;

    PUT_LINE ( "---------- INIT_GRMR ----------" );   IDL.INIT_GRMR (	CMD( 1..L	) );
    if C = 'I' then	goto FIN_TRAITEMENT; end if;

    PUT_LINE ( "---------- STAT_GRMR ----------" );   IDL.STAT_GRMR (	CMD( 1..L	) );
    if C = 'E' then	goto FIN_TRAITEMENT; end if;

    PUT_LINE ( "---------- LALR_GRMR ----------" );   IDL.LALR_GRMR (	CMD( 1..L	) );
    if C = 'L' then	goto FIN_TRAITEMENT; end if;

    PUT_LINE ( "---------- CHECK_GRMR ----------"	);  IDL.CHECK_GRMR ( CMD( 1..L ) );
    if C = 'V' then	goto FIN_TRAITEMENT; end if;

    PUT_LINE ( "---------- LOAD_GRMR ----------" );   IDL.LOAD_GRMR (	CMD( 1..L	) );

<<FIN_TRAITEMENT>>
    NEW_LINE;

  end loop;

  PUT_LINE ( "AU REVOIR ..." );

--|-------------------------------------------------------------------------------------------------
end LALR_TOOLS;
