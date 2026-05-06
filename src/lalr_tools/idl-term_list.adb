------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate(	IDL )
--|-------------------------------------------------------------------------------------------------
--|		PACKAGE TERM_LIST
--|-------------------------------------------------------------------------------------------------
package body TERM_LIST is

  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION SAME
  function SAME ( L1, L2 :SEQ_TYPE ) return BOOLEAN is
  begin
    return L1.FIRST	= L2.FIRST;
  end;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION UNION
  function UNION ( L1 :SEQ_TYPE; V :TREE ) return	SEQ_TYPE is
  begin
    if IS_EMPTY( L1	) then								--| LA LISTE EST VIDE
      return INSERT( L1, V );								--| RETOURNER UNE LISTE AVEC L'ÉLÉMENT INSÉRÉ
    else
      declare
        H1	: TREE	:= HEAD( L1 );						--| TÊTE DE LA LISTE
        N1	: INTEGER	:= DI( XD_TER_NBR, H1 );					--| N° DE	TERMINAL DE LA TÊTE
        NV	: INTEGER	:= DI( XD_TER_NBR, V );					--| N° DE	TERMINAL DE L'ÉLÉMENT
      begin
        if N1 = NV then								--| SI MÊME N°
	return L1;								--| RETOURNER LA LISTE INCHANGÉE
        elsif N1 < NV then								--| N° DIFFÉRENTS, CELUI DE LA LISTE STRICTEMENT INFÉRIEUR
	declare
	  T1	: SEQ_TYPE	:= TAIL( L1 );					--| PRENDRE LA SUITE DE LISTE
	  L	: SEQ_TYPE	:= UNION(	T1, V );					--| RETENTER L'UNION AVEC LE RESTE DE LISTE
	begin
	  if SAME( T1, L ) then							--| LA LISTE EST INCHANGÉE PAR UNION SUR LE RESTE	(ÉLÉMENT REPÉRÉ DANS LE RESTE)
	    return L1;								--| RETOURNER LA LISTE INITIALE INCHANGÉE
	  else									--| LE RESTE A ÉTÉ CHANGÉ
	    return INSERT( L, H1 );							--| METTRE LA TÊTE DEVANT LA NOUVELLE LISTE RESTE
	  end if;
	end;
        else									--| N° DIFFÉRENTS CELUI DE LA	LISTE STRICTEMENT SUPÉRIEUR
	return INSERT( L1, V );							--| INSÉRER L'ÉLÉMENT EN TÊTE	(PLUS PETITS N° EN TÊTE)
        end if;
      end;
    end if;
  end UNION;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION UNION
  function UNION ( L1 :SEQ_TYPE; L2 :SEQ_TYPE ) return SEQ_TYPE is
  begin
    if IS_EMPTY( L1	) then
      return L2;
    elsif	IS_EMPTY(	L2 ) or else SAME( L1, L2 ) then
      return L1;
    else
      declare
        H1	: TREE		:= HEAD( L1 );
        H2	: TREE		:= HEAD( L2 );
        N1	: INTEGER		:= DI( XD_TER_NBR, H1 );				--| N° DE	TERMINAL DE LA TÊTE	1
        N2	: INTEGER		:= DI( XD_TER_NBR, H2 );				--| N° DE	TERMINAL DE LA TÊTE	2
        T1, T2, L	: SEQ_TYPE;
      begin
        if N1 = N2 then								--| MÊMES	N° DE TÊTES
	T1 := TAIL( L1 );								--| PRENDRE LE RESTE 1
	T2 := TAIL( L2 );								--| LE RESTE 2
	L := UNION( T1, T2 );							--| RETENTER L'OPÉRATION SUR LES RESTES
	if SAME( L, T1 ) then							--| L'UNION DES RESTES EST LE	RESTE 1 (LE RESTE 1	CONTIENT LE RESTE 2)
	  return L1;								--| RENDRE LA LISTE	1
	elsif SAME( L, T2 )	then							--| L'UNION DES RESTES EST LE	RESTE 2 (LE RESTE 2	CONTIENT LE RESTE 1)
	  return L2;								--| RENDRE LA LISTE	2
	else									--| L'UNION DES RESTES DIFFÈRE DES DEUX	RESTES (CHAQUE RESTE A DES ÉLÉMENTS NON	CONTENUS DANS L'AUTRE)
	  return INSERT( L,	H1 );							--| PRÉFIXER LA TÊTE COMMUNE À LA LISTE	UNION DES	RESTES
	end if;

        elsif N1 > N2 then								--| LA TÊTE 1 EST APRÈS LA TÊTE 2
	return UNION( L2, L1 );							--| RETENTER L'UNION EN PERMUTANT LES LISTES (POUR VENIR AU	CAS SUIVANT)
        else									--| LA TÊTE 2 EST APRÈS LA TÊTE 1
	T1 := TAIL( L1 );								--| PRENDRE LE RESTE DE LA LISTE À TÊTE	ANTÉRIEURE
	L := UNION( T1, L2 );							--| RETENTER L'UNION SUR LE RESTE ET LA	LISTE 2 INITIALE
	if SAME( L, T1 ) then							--| SI L'UNION EST LE RESTE INCHANGÉ (LE RESTE DE	1 CONTENAIT LA LISTE 2)
	  return L1;								--| RENDRE LA LISTE	1
	else									--| L'UNION DU RESTE 1 ET DE LA LISTE 2	EST ORIGINAL
	  return INSERT( L,	H1 );							--| PRÉFIXER LA TÊTE 1 À LA NOUVELLE LISTE UNION
	end if;
        end if;
      end;
    end if;
  end UNION;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION MEMBER
  function MEMBER (	L1 :SEQ_TYPE; V :TREE ) return BOOLEAN is
  begin
    if IS_EMPTY( L1	) then								--| SI LA	LISTE EST	VIDE
      return FALSE;									--| L'ÉLÉMENT N'Y EST PAS (!)
    else
      declare
        H1	: TREE		:= HEAD( L1 );					--| TÊTE DE LISTE
        N1	: INTEGER		:= DI( XD_TER_NBR, H1 );				--| N° DE	LA TÊTE
        NV	: INTEGER		:= DI( XD_TER_NBR, V );				--| N° DE	L'ÉLÉMENT
      begin
        if N1 = NV then								--| N° IDENTIQUES
	return TRUE;								--| L'ÉLÉMENT EST DANS LA LISTE
        elsif NV < N1 then								--| N° D'ÉLÉMENT INFÉRIEUR
	return FALSE;								--| L'ÉLÉMENT N'EST	PAS DANS LA LISTE (ORDONNÉE CROISSANTE)
        else									--| LE N°	D'ÉLÉMENT	EST POSTÉRIEUR
	return MEMBER( TAIL( L1 ), V );						--| REFAIRE L'OPÉRATION SUR LE RESTE DE	LA LISTE
        end if;
      end;
    end if;
  end MEMBER;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION R_UNION
  function R_UNION ( L1 :SEQ_TYPE; V :TREE ) return SEQ_TYPE is
  begin
    if IS_EMPTY( L1	) then								--| LISTE	VIDE
      return INSERT( L1, V );								--| RETOURNER LA LISTE AVEC L'ÉLÉMENT EN TÊTE
    else										--| LISTE	NON VIDE
      declare
        H1	: TREE	:= HEAD( L1 );						--| LIRE LA TÊTE DE	LISTE
      begin
        if H1 = V then								--| SI C'EST L'ÉLÉMENT
	return L1;								--| RETOURNER LA LISTE
        end if;
        declare
	N1 : INTEGER	:= DI( XD_RULE_NBR,	D( XD_RULEINFO, H1 ) );			--| PRENDRE LE N° DE RÈGLE TÊTE DE LISTE
	NV : INTEGER	:= DI( XD_RULE_NBR,	D( XD_RULEINFO, V )	);			--| PRENDRE LE N° DE RÈGLE ÉLÉMENT
        begin
	if N1 < NV then								--| LA TÊTE EST ANTÉRIEURE
	  declare
	    T1 : SEQ_TYPE	:= TAIL( L1 );						--| PRENDRE LE RESTE DE LISTE
	    L  : SEQ_TYPE	:= R_UNION( T1, V );					--| RETENTER L'OPÉRATION
	  begin
	    if SAME( T1, L ) then							--| LE RESTE DE LISTE EST INCHANGÉ (CONTENAIT L'ÉLÉMENT)
	      return L1;								--| RETOURNER LA LISTE
	    else									--| L'UNION EST ORIGINALE
	      return INSERT( L, H1 );							--| RETOURNER UNE LISTE AVEC LA TÊTE 1 PRÉFIXÉE
	    end if;
	  end;
	else									--| L'ÉLÉMENT EST ANTÉRIEUR
	  return INSERT( L1, V );							--| RETOURNER UNE LISTE AVEC L'ÉLÉMENT PRÉFIXÉ
	end if;
        end;
      end;
    end if;
  end R_UNION;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION R_UNION
  function R_UNION ( L1 :SEQ_TYPE; L2 :SEQ_TYPE )	return SEQ_TYPE is
  begin
    if IS_EMPTY( L1	) then								--| LISTE	1 VIDE
      return L2;									--| RETOURNER LA LISTE 2 COMME UNION
    elsif	IS_EMPTY(	L2 ) or else SAME( L1, L2 ) then					--| LISTE	2 VIDE OU	IDENTIQUE	À LA LISTE 1
      return L1;									--| RETOURNER LA LISTE 1 COMME UNION
    else
      declare									--| CAS GÉNÉRAL
        H1	: TREE	:= HEAD( L1 );						--| PRENDRE LA TÊTE	DE LISTE 1
        H2	: TREE	:= HEAD( L2 );						--| ET LA	TÊTE DE LISTE 1
        T1, T2: SEQ_TYPE;
      begin
        if H1 = H2 then								--| SI TÊTES IDENTIQUES
	T1 := TAIL( L1 );								--| PRENDRE LE RESTE 1
	T2 := TAIL( L2 );								--| ET LE	RESTE 2
	declare
	  L : SEQ_TYPE	:= R_UNION( T1, T2 );					--| FAIRE	L'UNION DES RESTES
	begin
	  if SAME( L, T1 ) then							--| UNION	CORRESPONDANT AU RESTE 1 (QUI	CONTIENT LE RESTE 2)
	    return L1;								--| RETOURNER LA LISTE 1
	  elsif SAME( L, T2	) then							--| UNION	CORRESPONDANT AU RESTE 2 (QUI	CONTIENT LE RESTE 1)
	    return L2;								--| RETOURNER LA LISTE 2
	  else
	    return INSERT( L, H1 );							--| PRÉFIXER LA TÊTE COMMUNE À L'UNION ORIGINALE DES RESTES
	  end if;
	end;
        else									--| LES TÊTES DIFFÈRENT
	if DI( XD_RULE_NBR,	D( XD_RULEINFO, H1 ) )					--| LE N°	DE TÊTE 1
			> DI( XD_RULE_NBR, D( XD_RULEINFO,H2 ) ) then			--| EST POSTÉRIEUR AU N° DE TÊTE 2
	  return R_UNION( L2, L1 );							--| RETENTER L'UNION EN PERMUTANT LES LISTES (POUR TOMBER AU CAS SUIVANT)
	else									--| LE N°	DE TÊTE 1	EST ANTÉRIEUR AU N°	DE TÊTE 2
	  T1 := TAIL( L1 );								--| PRENDRE LE RESTE 1
	  declare
	    L	: SEQ_TYPE	:= R_UNION( T1, L2 );				--| UNIR LE RESTE 1	À LA LISTE 2
	  begin
	    if SAME( L, T1 ) then							--| SI UNION CORRESPONDANT AU	RESTE 1 (QUI CONTIENT LA LISTE 2)
	      return L1;								--| RETOURNER LA LISTE 1
	    else									--| UNION	ORIGINALE
	      return INSERT( L, H1 );							--| RETOURNER UNE LISTE AVEC LA TÊTE 1 PRÉFIXÉE À	L'UNION ORIGINALE
	    end if;
	  end;
	end if;
        end if;
      end;
    end if;
  end R_UNION;

--|--------------------------------------------------------------------------------------------------
end TERM_LIST;
