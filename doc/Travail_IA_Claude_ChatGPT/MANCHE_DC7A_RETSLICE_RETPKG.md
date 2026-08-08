# MANCHE D-C7a, SUITE — le local passe, on juge maintenant ce qui diffère
# du site réel

RETMICRO1 PASSE : le modèle de retour C7 (doublet résultat + info copiée
par valeur) est sain pour une fonction LOCALE consommée en direct,
affectation et égalité. Trois différences séparent encore le témoin de
TOKEN_STRING, dans l'ordre du moins cher au plus cher :

## 1. REJOUER RETSLICE (zéro code nouveau)

RETSLICE (réordonné LRM 3.9) juge ce que RETMICRO1 n'a pas touché :
la consommation du résultat EN CONCATÉNATION — R3 (`"x" & TS`),
R4 (`"identifier" & "\" & TS`, la forme EXACTE de la trace tronquée),
R6 (longueur 2, l'analogue de IS), R7 (longueur mobile). Attendu :
« RESULTAT : 7 OK, 0 ECHECS / RETSLICE PASSE » des deux côtés.

## 2. RAFRAÎCHIR LA PREUVE — re-générer le bootstrappé (commits 1+2+3)
##    et rejouer la trace

Les listings null_prog_asG/asT datent du compilateur SANS commit 3.
Re-générer, ré-assembler, rejouer `./A83.sh ./ ./null_prog.adb S` avec
M-DBG (et M-TRACE si encore en place), et re-diff. Trois issues :
- NULL_PR persiste → la troncature est confirmée VIVANTE et le
  discriminant restant est le niveau/l'inter-unité → point 3 ;
- NULL_PROG revient entier mais l'erreur IS persiste → la troncature
  était un artefact d'un état corrompu par le trou littéral (commit 3
  l'a soigné en passant) et la chasse se recentre sur le walk de table
  (les lignes « @ » de M-TRACE tranchent) ;
- tout passe → PAR_PHASE est clos, et on file au chantier F3 (MAKE).

## 3. TÉMOIN RETPKG — la forme paquetage-de-bibliothèque (si NULL_PR
##    persiste)

Miroir structurel de LEX.TOKEN_STRING : statiques au niveau 0, fonction
au niveau paquetage, APPELÉE DEPUIS UNE AUTRE UNITÉ, et les quatre
consommations du site réel. Trois unités, à compiler par la chaîne
TLALOC comme lex (spec, corps, principal) et par gnat -gnat83.

### retpkg.ads
```
package RETPKG is

  procedure SETB	( S :STRING );
  function  TS		return STRING;
  procedure STORE	( S :STRING );			-- l'analogue de STORE_SYM
  function  STORED_LEN	return NATURAL;
  function  STORED_EQ	( S :STRING ) return BOOLEAN;	-- resultat interne vs formel

end RETPKG;
```

### retpkg.adb
```
package body RETPKG is

  BUF	: STRING( 1..255 );
  LEN	: NATURAL := 0;

  SBUF	: STRING( 1..255 );
  SLEN	: NATURAL := 0;

  procedure SETB( S :STRING )
  is
  begin
    BUF( 1..S'LENGTH ) := S;
    LEN := S'LENGTH;
  end SETB;

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );				-- la forme exacte de TOKEN_STRING
  end TS;

  procedure STORE( S :STRING )
  is
  begin
    SBUF( 1..S'LENGTH ) := S;
    SLEN := S'LENGTH;
  end STORE;

  function STORED_LEN return NATURAL
  is
  begin
    return SLEN;
  end STORED_LEN;

  function STORED_EQ( S :STRING ) return BOOLEAN
  is
  begin
    return SBUF( 1..SLEN ) = S;			-- tranche interne vs FORMEL (motif HASH)
  end STORED_EQ;

end RETPKG;
```

### retpkg1.adb
```
with TEXT_IO;			use TEXT_IO;
with RETPKG;

procedure RETPKG1
is
  OK_COUNT	: NATURAL := 0;
  KO_COUNT	: NATURAL := 0;

  procedure CHECK( LABEL :STRING; COND :BOOLEAN )
  is
  begin
    if  COND  then
      OK_COUNT := OK_COUNT + 1;
    else
      KO_COUNT := KO_COUNT + 1;
      PUT_LINE( "ECHEC " & LABEL );
    end if;
  end CHECK;

begin
  PUT_LINE( "=== RETPKG1 : retour tranche dynamique, niveau paquetage ===" );

  RETPKG.SETB( "NULL_PROG" );

  PUT( "P1 brut    [" );				-- consommation directe inter-unite
  PUT( RETPKG.TS );
  PUT_LINE( "]  attendu [NULL_PROG]" );

  CHECK( "P2 egalite directe", RETPKG.TS = "NULL_PROG" );

  CHECK( "P3 concat double (forme DEBUG_PRINT)",	-- la forme observee tronquee
	 ( "identifier" & "\" & RETPKG.TS ) = "identifier\NULL_PROG" );

  RETPKG.STORE( RETPKG.TS );				-- l'analogue de STORE_SYM( TOKEN_STRING )
  CHECK( "P4 longueur stockee", RETPKG.STORED_LEN = 9 );
  CHECK( "P5 contenu stocke",   RETPKG.STORED_EQ( "NULL_PROG" ) );

  RETPKG.SETB( "IS" );					-- l'analogue du token is
  CHECK( "P6 longueur 2 en concat", ( "x" & RETPKG.TS ) = "xIS" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "RETPKG1 PASSE" );
  else
    PUT_LINE( "RETPKG1 ECHOUE" );
  end if;

end RETPKG1;
```

Lecture des motifs :
- P1/P2 échouent → le modèle C7 casse à l'INTER-UNITÉ/niveau 0 (GFP,
  display, ou l'info copiée au mauvais frame) — le FINC de retpkg.adb
  (PRO TS) + celui de l'appel dans retpkg1 sont la table d'autopsie ;
- P1/P2 passent, P3/P6 échouent → la consommation concat au niveau
  inter-unité ;
- P4/P5 échouent seuls → le relais résultat→actuel (STORE_SYM) ;
- TOUT passe ET NULL_PR persiste au point 2 → le discriminant restant
  est fin (SETB vs affectations directes du lexeur, TEXT partagé
  scanner/consommateurs) : on passera alors à l'autopsie FINC directe
  de TOKEN_STRING + son site d'appel dans lex/par_phase, avec le
  modèle de macros complet désormais en main.

## INTENDANCE

- LVa : casse fasmg (`macro LVa?` = insensible à la casse) — mon
  exemplaire codi est À JOUR, demande close ; leçon : grep -i sur les
  macros de ce codi.
- Toujours en attente pour la manche F3 : source de MAKE (idl.adb) et
  fragment FINC de son remplissage des défauts.
