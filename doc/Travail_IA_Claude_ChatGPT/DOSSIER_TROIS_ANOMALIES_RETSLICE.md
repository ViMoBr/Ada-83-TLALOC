# DOSSIER — trois anomalies, un témoin, une trace fine
# (diff null_prog_asG / null_prog_asT)

Le diff des deux traces est la meilleure pièce depuis le début de la
chasse. Il établit des FAITS (recoupés par les positions), sépare TROIS
anomalies distinctes, et l'une des trois tombe sur une dette que vos
propres registres avaient prédite mot pour mot.


## 1. LES FAITS ÉTABLIS PAR LE DIFF

**F1 — la géométrie du lexeur est INNOCENTE.** Le token NULL_PR* est
estampillé (1,11) — colonne de départ correcte — et le token courant de
toute la chaîne de réductions est estampillé (2,1) des DEUX côtés : le
scanner a consommé la ligne 1 en entier et est passé à la ligne 2
correctement. (Une troncature du SCAN aurait produit un token « OG » en
(1,18), ce que les estampilles excluent.) TOKEN_LENGTH, W_COL, COL
étaient donc justes.

**F2 — la troncature vit dans la CONSOMMATION du résultat de
TOKEN_STRING.** Les deux consommateurs — la concaténation de trace
(`LEX_IMAGE(LTYPE) & "\" & TOKEN_STRING` → « identifier\NULL_PR », 18
au lieu de 20) et STORE_SYM (XD_TEXT = TXTREP « NULL_PR », nœud L55 ≠
L54 : réellement STOCKÉ court) — perdent 2 caractères. Or TOKEN_STRING
est :
```
function TOKEN_STRING return STRING is
begin
  return TEXT( 1..TOKEN_LENGTH );
end;
```
— très exactement la dette **D-C7a** de vos registres : « Fonction
ORDINAIRE retournant tableau à bornes dynamiques : témoin du modèle
unique C7 ; dette D6 (bloc info anonyme 1-dim) susceptible de mordre —
à exercer AVANT le premier site ». L'oracle est listé MANQUANT
(ETAT_PILIERS : « le n° 111 ne fut vu que via UC »). TOKEN_STRING est
le premier site, et il mord comme prédit.

**F3 — les défauts de MAKE sont corrompus.** Sur le DN_PROCEDURE_ID
frais : chaque attribut ÉCRIT explicitement (SM_FIRST, SM_ADDRESS,
SM_IS_INLINE, SM_INTERFACE, XD_STUB, XD_BODY, CD_COMPILED, CD_LABEL —
la liste EXACTE de SET_DFLT — plus LX_SRCPOS via MAKE_AUXA_NODE) est
correct ; chaque attribut laissé au DÉFAUT DE MAKE vaut la MÊME valeur
poubelle [DN_ARGUMENT_ID,P9873,L100] au lieu de [DN_VIRGIN,P0,L0]
(LX_SYMREP avant lx_symrep, SM_SPEC, SM_UNIT_DESC, XD_REGION, CD_LEVEL,
CD_PARAM_SIZE). Le remplissage initial de MAKE (idl.adb) écrit une
constante fausse — UNE seule valeur, constante : signature d'un défaut
de chargement/emballage de TREE_VIRGIN (constante record représenté 32
bits), pas d'une corruption aléatoire. Chantier séparé de F2.

**F4 — l'échec est le shift de IS après la réduction PROCEDURE_SPEC.**
Côté gnat : `s 70~IS` immédiatement après le $1. Côté TLALOC : ACTION=0.
Entre les deux : le balayage goto ARRIÈRE du non-terminal, puis le
balayage AVANT de IS dans le nouvel état. Deux acquittements réduisent
le champ : (a) la classification est probablement JUSTE — PROCEDURE fut
reconnu, et la table de hachage est AUTO-COHÉRENTE (insertion et
recherche passent par la même mécanique : un défaut uniforme casserait
PROCEDURE au token 1) ; (b) le message « NONTER GOTO NOT FOUND » n'est
PAS apparu : le goto a trouvé quelque chose. Reste : goto trouvé au
MAUVAIS slot, ou balayage de IS défaillant dans le bon état, ou
ACTION/NBR_OF_SYLS de la réduction faux. La trace fine (§3) départage
en une exécution.

**Sur « OG » enfin :** avec F2 acquis, « OG » = les 2 caractères que
TOKEN_STRING perd — et le message d'erreur est fabriqué par la MÊME
famille de constructions (concat + tranche + résultats de fonctions).
Le message est un SYMPTÔME de F2, pas une piste indépendante. On cesse
de l'interroger : le témoin ci-dessous le remplace.


## 2. TÉMOIN RETSLICE — l'oracle D-C7a manquant, devenu urgent

Ada 83 strict, auto-jugeant, à compiler DEUX fois (gnat -gnat83 et
TLALOC). Il reproduit la forme exacte de TOKEN_STRING et ses deux
consommations observées, du plus simple au plus composé — le PREMIER
échec désigne la couche. Son FINC est petit : c'est la surface de
travail de la manche correctionnelle.

```
with TEXT_IO;			use TEXT_IO;

procedure RETSLICE
is
  OK_COUNT	: NATURAL := 0;
  KO_COUNT	: NATURAL := 0;

  BUF	: STRING( 1..255 );
  LEN	: NATURAL := 0;

  function TS return STRING
  is
  begin
    return BUF( 1..LEN );				-- la forme exacte de TOKEN_STRING (D-C7a)
  end TS;

  R9	: STRING( 1..9 );

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
  PUT_LINE( "=== RETSLICE : fonction ordinaire, retour tranche dynamique ===" );

  BUF( 1..9 ) := "NULL_PROG";
  LEN := 9;

  PUT( "R0 affiche [" );				-- consommation directe (visuelle)
  PUT( TS );
  PUT_LINE( "]  attendu [NULL_PROG]" );

  CHECK( "R1 egalite directe", TS = "NULL_PROG" );

  R9 := TS;						-- affectation depuis le resultat
  CHECK( "R2 affectation", R9 = "NULL_PROG" );

  CHECK( "R3 concat simple", ( "x" & TS ) = "xNULL_PROG" );

  CHECK( "R4 concat double (forme DEBUG_PRINT)",	-- la forme observee tronquee
	 ( "identifier" & "\" & TS ) = "identifier\NULL_PROG" );

  LEN := 2;						-- l'analogue de IS
  BUF( 1..2 ) := "IS";
  CHECK( "R5 longueur 2 directe", TS = "IS" );
  CHECK( "R6 longueur 2 en concat", ( "x" & TS ) = "xIS" );

  LEN := 7;						-- longueur mobile
  BUF( 1..7 ) := "NULL_PR";
  CHECK( "R7 longueur mobile", TS = "NULL_PR" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
	  & NATURAL'IMAGE( KO_COUNT ) & " ECHECS" );
  if  KO_COUNT = 0  then
    PUT_LINE( "RETSLICE PASSE" );
  else
    PUT_LINE( "RETSLICE ECHOUE" );
  end if;

end RETSLICE;
```

Lecture des motifs :
- R1/R2 échouent aussi → le défaut est dans le MODÈLE DE RETOUR C7
  lui-même (doublet résultat : bornes/longueur, ou info fantôme lue
  dans la frame UNLINKée du callee — la dette D6 « susceptible de
  mordre ») ;
- R1/R2 passent, R3/R4 échouent → le défaut est côté CONSOMMATEUR
  concat (extraction du doublet résultat, D6 côté appelant) ;
- tout passe → le site réel diffère du témoin par le NIVEAU
  (TOKEN_STRING est au niveau paquetage, BUF/LEN statiques niveau 0) :
  variante à re-jouer avec un paquetage imbriqué — me le dire, je la
  fournis ancrée.
- R5/R6 : si la perte est « −2 », une longueur 2 donne un résultat
  VIDE — c'est le rameau qui relierait F2 à la classification de IS
  s'il échoue différemment des autres.

NB : le témoin garde ses concat de trace (`& NATURAL'IMAGE(...)`) dans
le TRAILER seulement — si le trailer lui-même sort garblé, c'est une
information de plus, et les CHECK individuels (une ligne par échec)
restent lisibles.


## 3. M-TRACE — trace fine du walk de table (pour F4)

Modification TEMPORAIRE ancrée d'idl-par_phase.adb (rejouée sur votre
source, octets exacts), à appliquer aux DEUX builds par-dessus M-DBG.
Elle imprime, à CHAQUE itération de la boucle principale, le quintuplet
(SP, STATE, POS(TOKENSYM), AP, ACTION) — volontairement en PUT séparés,
sans concaténation, pour ne pas traverser la famille de constructions
suspectée par F2.

ANCRE (unique, inchangée) :
```
        ACTION := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
```

BLOC À SUPPRIMER :
```
      end if;

      if  ACTION > 0  then										-- CAN'T BE SEMANTICS SINCE DIDN'T INDIRECT
```

BLOC DE REMPLACEMENT :
```
      end if;

      if  DEBUG_PARSE  then										--| TRACE FINE TEMPORAIRE (chasse IS)
        PUT( "@" );
        PUT( INTEGER'IMAGE( SP ) );
        PUT( INTEGER'IMAGE( STATE ) );
        PUT( INTEGER'IMAGE( LEX_TYPE'POS( TOKENSYM ) ) );
        PUT( INTEGER'IMAGE( AP ) );
        PUT( INTEGER'IMAGE( ACTION ) );
        NEW_LINE;
      end if;

      if  ACTION > 0  then										-- CAN'T BE SEMANTICS SINCE DIDN'T INDIRECT
```

Protocole : `./A83.sh ./ ./null_prog.adb S` des deux côtés, diff des
lignes « @ ». La PREMIÈRE ligne divergente désigne l'opération exacte :
- STATE diverge d'abord → le goto de la réduction précédente (balayage
  arrière, `INTEGER( ASYM ) = ACTION`) a trouvé le mauvais slot ;
- AP diverge à STATE égal → le balayage AVANT (recherche de
  POS(TOKENSYM) dans AC_SYM) s'arrête au mauvais endroit ;
- ACTION diverge à AP égal → la lecture AC_TBL(AP) — improbable, la
  sonde l'a innocentée ;
- POS(TOKENSYM) diverge → la classification, malgré l'acquittement —
  et alors le suspect redevient la chaîne HASH/LEX_IMAGE.

Après la manche : reverser M-TRACE et M-DBG (modifications inverses).


## 4. POUR LA MANCHE SUIVANTE (avec les verdicts)

1. Sortie complète de RETSLICE des deux côtés (et son FINC TLALOC si un
   R* échoue — c'est petit).
2. Le diff des lignes « @ » de M-TRACE.
3. Pour F3 (chantier séparé) : le source de MAKE dans idl.adb (la
   boucle/le remplissage des attributs par défaut TREE_VIRGIN) et le
   fragment FINC correspondant d'idl.finc — la valeur poubelle étant
   CONSTANTE, le défaut devrait s'y lire directement (soupçon :
   chargement de la constante TREE_VIRGIN — adresse au lieu de valeur,
   ou emballage du record représenté 32 bits).

Les trois chantiers sont indépendants et chacun a maintenant son
instrument. F2 (D-C7a) est le plus mûr : le témoin EST l'oracle
manquant de vos registres — quel que soit son verdict, il rejoint le
filet permanent.
