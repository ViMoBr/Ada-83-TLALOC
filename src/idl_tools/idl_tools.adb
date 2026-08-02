------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO, IDL;
use  TEXT_IO;									--| LA VERSION ADAPTÉE À LA GESTION DES STRUCTURES DE GRAMMAIRE LALR
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE IDL_TOOLS
--|-------------------------------------------------------------------------------------------------
procedure IDL_TOOLS is

   C	: CHARACTER;
   L	: NATURAL;
   CMD	: STRING(1..64);
begin

  loop
    NEW_LINE;
    PUT_LINE ( "-----------------------------------------------" );
    PUT_LINE ( "                OUTILS IDL" );
    PUT_LINE ( "-----------------------------------------------" );
    NEW_LINE;
    PUT_LINE ( "LIRE/VERIF IDL (DONNE NODES_ CLASS_ .lar) ... R" );
    PUT_LINE ( "ECRIRE TBL (DONNE .lar NODES) ............... T" );
    PUT_LINE ( "ECRIRE NACN (.ads) .......................... N" );
    NEW_LINE;
    PUT_LINE ( "QUITTER ..................................... Q" );
    NEW_LINE;
    PUT	   ( "                 CHOIX : " );
    GET_LINE ( CMD, L );
    C := CMD( 1 );
    NEW_LINE;

    case C is
    when 'R' | 'T' | 'N' =>
      PUT ( "NOM DE FICHIER DESCRIPTION (SANS EXTENSION .idl) : " );
      GET_LINE ( CMD, L );
      NEW_LINE;

    when 'Q' =>
      exit;

    when others =>
      NEW_LINE;
    end case;

    if C = 'R' then
      IDL.IDL_READ ( CMD( 1..L ) );

    elsif C = 'T' then
      IDL.TBL_PUT ( CMD( 1..L ) );

    elsif C = 'N' then
      IDL.NAM_PUT ( CMD( 1..L ) );
    end if;

    NEW_LINE;

  end loop;

  PUT_LINE ( "AU REVOIR ..." );

--|------------------------------------------------------------------------------------------------
end IDL_TOOLS;
