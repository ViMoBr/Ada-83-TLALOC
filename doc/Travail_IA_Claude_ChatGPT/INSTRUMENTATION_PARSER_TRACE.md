# INSTRUMENTATION — erreur de syntaxe parasite sur « is » (parse.bin innocenté)

Le triangle a innocenté parse.bin, le layout, SEQUENTIAL_IO et les accès
élémentaires. Restent trois familles d'hypothèses TLALOC-side, et la pièce
« OG » les départage MAL : on instrumente, on ne bénit pas.


## 1. LECTURE FORENSIQUE DE « OG » — ce qui est prouvé, ce qui bifurque

Acquis :
- Le texte « ERREUR DE SYNTAXE - OG » a été FIGÉ AU MOMENT DU PARSE dans
  le nœud erreur (le crash n° 1 l'a prouvé : ERR_PHASE ne fait qu'imprimer
  le txtrep stocké). Donc la tranche SLINE.BDY( F_COL..E_COL ) valait
  « OG » — deux caractères — à l'instant de l'appel ERROR.
- « OG » = les deux derniers caractères de NULL_PROG. Longueur 2 = celle
  de « is ». Position affichée : ligne 2, col 1.
- ERR_PHASE a affiché la VRAIE ligne 2 (« is ») : sa propre relecture du
  fichier fonctionne — ce qui AFFAIBLIT (sans l'éliminer, chemins de
  lecture possiblement distincts) l'hypothèse d'un GET_LINE globalement
  cassé.

Les trois familles survivantes :

**H1 — couche d'entrée** (TEXT_IO TLALOC : GET_LINE / END_OF_FILE, la
mécanique de look-ahead du piège n° 35). Si GET_LINE re-livre « OG »
comme pseudo-ligne 2, le parseur voit « procedure / NULL_PR.. / OG » et
son erreur est CORRECTE pour ce qu'il a vu : ligne 2, col 1, tranche
« OG » — TOUTES les valeurs observées collent d'un coup. Contre-indice :
l'affichage correct d'ERR_PHASE.

**H2 — classification lexicale de « is »**. HASH_SEARCH/HASH_POS
cumulent des constructions à risque ('LENGTH et 'LAST d'un FORMEL non
contraint recevant une TRANCHE en actual ; « /= » de STRING composé
dans une condition de boucle avec and then ; sondage linéaire avec
repli). « is » rendu LT_IDENTIFIER → « procedure IDENT IDENT » = erreur
légitime du parseur. MAIS alors la tranche du message devrait donner
« is », pas « OG » : H2 exige un DEUXIÈME défaut (affichage) pour tout
expliquer.

**H3 — première réduction**. Entre NULL_PROG et « is » s'exécute pour
la PREMIÈRE fois de tout le bootstrap la chaîne réduction → BUILD_TREE
(grmr_ops) → balayage goto ARRIÈRE (AP := AP-1) → nouvel état. Un état
faux → « is » inacceptable → ACTION = 0. Même remarque qu'H2 sur « OG ».

Sous H2/H3, le « OG » d'affichage a d'ailleurs son propre dossier : la
tranche du message passe par le chemin concat-à-opérande-tranche
(commit 2) avec un préfixe DN_SELECTED — branche de CODE_SLICE qui ne
fait PAS le calcul d'offset (data = base de BDY). Avec F_COL = 1 cela
donnerait « is », pas « OG » : l'affichage est donc lui-même un témoin
à charge encore illisible. Raison de plus pour instrumenter.


## 2. M-DBG — activer la trace intégrée (les deux drapeaux)

Modification TEMPORAIRE (à reverser après la manche), à appliquer sur
idl-par_phase.adb pour LES DEUX compilations (gnat -gnat83 ET TLALOC).
Protocole ancré habituel, blocs au caractère près (rejeu fait).

ANCRE (unique, inchangée) :
```
  TOKENSYM		: LEX_TYPE;								--| BYTE WITH TER/NONTER REP
```

BLOC À SUPPRIMER (ligne vide + les deux drapeaux) :
```

  DEBUG_PARSE		: BOOLEAN		:= FALSE;							--| PRINT PARSE TREE WHILE PARSING
  DEBUG_SEM		: BOOLEAN		:= FALSE;							--| PRINT SEMANTICS WHILE PARSING
```

BLOC DE REMPLACEMENT :
```

  DEBUG_PARSE		: BOOLEAN		:= TRUE;							--| PRINT PARSE TREE WHILE PARSING
  DEBUG_SEM		: BOOLEAN		:= TRUE;							--| PRINT SEMANTICS WHILE PARSING
```

DEBUG_PARSE imprime CHAQUE token décalé (son texte) ; DEBUG_SEM imprime
chaque MAKE sémantique de BUILD_TREE (NODE_NAME'IMAGE). Les deux traces
ensemble couvrent H1, H2 et H3.

Caveat assumé : le chemin de trace lui-même (TOKEN_STRING = retour de
tranche, DEBUG_PRINT à concat, LEX_IMAGE) traverse des chantiers
récents — une trace TLALOC GARBLÉE ou qui plante est AUSSI une
information (elle désigne le chemin d'affichage, et rejoint le dossier
« OG »).


## 3. TÉMOIN LEX_ECHO — juger la couche d'entrée isolément

Reproduit EXACTEMENT le motif de GET_SOURCE_LINE (END_OF_FILE puis
GET_LINE dans une boucle) sur le vrai null_prog.adb, sans un gramme de
parseur. À compiler DEUX fois (gnat -gnat83 et TLALOC), exécuter dans
le répertoire de null_prog.adb, et diff des sorties.

```
with TEXT_IO;			use TEXT_IO;

procedure LEX_ECHO
is
  F	: FILE_TYPE;
  BDY	: STRING( 1..255 );
  LEN	: NATURAL;
  N	: NATURAL := 0;
begin
  OPEN( F, IN_FILE, "null_prog.adb" );
  while  not END_OF_FILE( F )  loop			-- meme motif que GET_SOURCE_LINE
    N := N + 1;
    GET_LINE( F, BDY, LEN );
    PUT( "LIGNE" & NATURAL'IMAGE( N ) & " LEN" & NATURAL'IMAGE( LEN ) & " [" );
    if  LEN > 0  then
      PUT( BDY( 1..LEN ) );
    end if;
    PUT_LINE( "]" );
  end loop;
  CLOSE( F );
  PUT_LINE( "LEX_ECHO FIN" );
end LEX_ECHO;
```

Attendu (les deux compilations, octets identiques) :
```
LIGNE 1 LEN 19 [procedure NULL_PROG]
LIGNE 2 LEN 2 [is]
LIGNE 3 LEN 5 [begin]
LIGNE 4 LEN 7 [  null;]
LIGNE 5 LEN 14 [end NULL_PROG;]
LEX_ECHO FIN
```
(longueurs à ±1 selon blancs du fichier réel ; seul compte le DIFF
gnat/TLALOC).


## 4. PROTOCOLE ET TABLE DE DÉCISION

1. LEX_ECHO (les deux builds) → diff.
2. Compilateurs re-générés avec M-DBG (les deux) →
   `./A83.sh ./ ./null_prog.adb S` de chaque côté → diff des traces.

| LEX_ECHO | Trace | Verdict et chantier |
|---|---|---|
| DIVERGE | — | **H1** : couche d'entrée. Chantier text_io.adb TLALOC (GET_LINE / END_OF_FILE / look-ahead, piège n° 35) — PAS l'expander. Le motif de divergence (ligne coupée, ligne fantôme « OG », décalage) désigne la routine. |
| identique | TLALOC décale un token « OG » ou un identifiant là où gnat décale IS | **H2** : classification lexicale. Zoom FINC sur HASH_POS/LEX_SCAN : 'LENGTH/'LAST du formel non contraint, « /= » STRING de la boucle de sondage, le scanner à GOTO Ada (les goto/étiquettes sont-ils DÉJÀ exercés par le corpus ? sinon premier passage ici), l'exit-when mixte l. 82 (piège n° 33 : `CHR /= ' ' and then CHR not in HT..CR`). |
| identique | tokens identiques, mais les MAKE de DEBUG_SEM divergent (ou s'arrêtent) au premier train de réductions | **H3** : première réduction. Zoom FINC sur la boucle reduce d'idl-par_phase (arithmétique -ACTION-10000, /1000, mod 1000), BUILD_TREE/grmr_ops, et le balayage goto ARRIÈRE (AP := AP - 1 ; comparaison INTEGER(ASYM) = ACTION). |
| identique | trace TLALOC garblée/plante dans l'affichage même | Le chemin d'affichage (TOKEN_STRING retour-de-tranche, concat, LEX_IMAGE) est en cause — et c'est probablement le MÊME défaut qui a fabriqué « OG ». Zoom FINC sur ces trois-là. |

Dans tous les cas, la manche suivante se joue sur un FINC ciblé : joindre
alors le fragment FINC de la zone désignée (HASH_POS/LEX_SCAN, ou la
boucle reduce, ou TOKEN_STRING/DEBUG_PRINT) et, si H2/H3, le dump des
premiers tokens tracés des deux côtés.

Après la manche : reverser M-DBG (les drapeaux reviennent à FALSE par la
modification inverse).
