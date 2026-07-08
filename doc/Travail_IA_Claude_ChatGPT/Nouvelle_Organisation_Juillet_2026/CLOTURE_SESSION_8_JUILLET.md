# CLÔTURE SESSION 8 JUILLET 2026 — ajouts aux fichiers de contexte

Quatre blocs à copier, un par fichier, puis la liste courte de ce qui reste.

═══════════════════════════════════════════════════════════════════════
## 1. JOURNAL_SESSIONS.md — à AJOUTER en fin de fichier
═══════════════════════════════════════════════════════════════════════

## Session 8 juillet 2026 — TEXT_IO conforme LRM 14 ; fossile expandeur « actual out composé »

Refonte de conformité du package TEXT_IO, préparée par un arbitrage à deux
avis (Claude + second expert) dont la clé d'architecture est la séparation
stricte de deux niveaux. Le niveau RAW (GET_RAW, PUT_RAW caractère et
chaîne, hors spec, corps ASM inchangés relocalisés avant leurs appelants)
est un flux d'octets pur : pas de mise en page, pas d'exceptions, GET_RAW
arme AT_END_OF_FILE et rend NUL à EOF. Le niveau public conforme LRM est
construit au-dessus : GET saute les terminateurs LF/FF (CR ignoré comme
moitié muette du CR LF), tient LINE/COL/PAGE et lève END_ERROR ; PUT tient
COL et fait la coupure implicite à LINE_LENGTH bornée (14.3.6(4)). Règles
de circulation : les scanners tokenisants (INTEGER/FLOAT/FIXED/
ENUMERATION_IO) et les lecteurs de structure (SKIP_*, END_OF_*, GET_LINE)
restent intégralement sur GET_RAW (visibilité des terminateurs, droit au
unget) ; NEW_LINE/NEW_PAGE/SET_COL émettent leurs caractères physiques via
PUT_RAW (sinon double comptabilité de COL) ; aucun niveau n'appelle
l'autre à contre-sens. GET(STRING) est réécrit en boucle sur le GET
public — l'ancien chemin READ en bloc, qui contournait le look-ahead, a
disparu ; PUT(STRING) garde un chemin rapide en bloc quand la ligne n'est
pas bornée.

Contenu du lot, dans l'ordre du patch : champs de longueur passés de
POSITIVE_COUNT à COUNT := UNBOUNDED (le 0 hors sous-type était une bombe
pour le futur pilier checks) et défauts non bornés partout (LRM 14.3.3) ;
élaboration explicite complète des fichiers standard (ID, IS_DEFAULT_IO,
LOOK_AHEAD, HAS_LOOK_AHEAD, AT_END_OF_FILE — VARzone non zéroée) ; gardes
LRM 14.2.1 (CREATE/OPEN sur fichier déjà ouvert → STATUS_ERROR, CLOSE/
DELETE sur fichier fermé → STATUS_ERROR) ; échec d'OPEN → NAME_ERROR
(piège n° 45 désamorcé) et de CREATE → USE_ERROR ; END_ERROR à l'entrée de
SKIP_LINE/SKIP_PAGE/GET_LINE et après le saut de blancs des scanners
fichier ; DATA_ERROR armé partout (énumérés, image sans chiffre, chiffre
incompatible avec la base des based literals — variantes chaîne ET
fichier) ; LAYOUT_ERROR dans les quatre PUT(TO : STRING) à la place du
remplissage d'étoiles, et dans SET_COL/SET_LINE contre les longueurs
bornées ; SET_COL/SET_LINE sortie complets (espaces, NEW_LINE/NEW_PAGE
implicites en arrière) ; cadrage énuméré PUT(FILE) avec WIDTH corrigé en
blancs de QUEUE (RM 14.3.9(10), la déviation console consignée disparaît) ;
FF reconnu comme séparateur par les scanners numériques et comme
terminateur de ligne par END_OF_LINE (un FF seul porte ligne+page dans
notre encodage).

Le lot a réveillé un fossile de l'expandeur, vieux comme
CODE_PROCEDURE_CALL : un actual DN_INDEXED tombait dans le fallback
CODE_EXP (rvalue) quel que soit le mode du formel — pour un out/in out
scalaire (convention par référence), le Lb final remplaçait l'adresse
calculée du composant par sa valeur, que l'appelé utilisait comme adresse
de dépôt : écriture sauvage. Le seul appel de cette forme dans tout le
corpus était la branche console de l'ancien GET(STRING), jamais exercée ;
la boucle du GET(STRING) public en a fait le chemin unique. Chaîne de
diagnostic exemplaire à retenir : segfault TEXT14/U5 → sonde à marqueurs
séquentiels TEXT14P (une exécution localise : P14) → lecture du FINC
(séquence LIa/…/ADD/Lb avant le CALL) → correctif d'une branche dans
INVERSE_RECURSE_ON_PARAMETERS, calquée sur le test de mode existant de
DN_VARIABLE_ID (in → CODE_EXP ; out/in out → CODE_OBJECT_ADDRESS).
Le témoin OUTARG1 verrouille la classe entière : indexé (U1), sélectionné
— le jumeau du même fallback — (U2), et le motif exact du GET(STRING)
(boucle sur composant indexé d'un formel non contraint, U3). Pièges
n° 77-78.

L'extension U8 du témoin (utilisateur) a trouvé trois trous dans l'angle
mort du lot — les scanners fichier n'étaient nourris qu'en entrées
valides sans terminateur de page : DATA_ERROR absent des variantes
fichier, FF non séparateur, END_OF_LINE aveugle au FF. Les trois corrigés
le jour même (TEXT14 42/42).

Filet final : modules du compilateur, TEXT14, OUTARG1, IO_TEST, EXC_TEST*,
ENUM_TEST, A2–A8, auto-compilation — tout vert SAUF DIRECT_IO_TEST et
SEQ_IO_TEST qui tombent en END_ERROR : témoins datant de l'ancien contrat
(« GET rend NUL à EOF » / idiome END_OF_FILE + lecture caractère,
déviation mono-anticipation consignée au piège n° 79), les packages
eux-mêmes n'ont pas bougé. Remise d'aplomb dans une session dédiée.

Restrictions consignées de la session : SET_COL/SET_LINE en ENTRÉE
restent des affectations directes du compteur (placeholder commenté) ;
END_OF_FILE/END_OF_PAGE à un caractère d'anticipation ne voient pas à
travers les terminateurs (remède commun avec l'aliasing des copies
FILE_TYPE : futur chantier « descripteur partagé à tampon », non
planifié).

═══════════════════════════════════════════════════════════════════════
## 2. ETAT_PILIERS.md — lignes à REMPLACER / AJOUTER
═══════════════════════════════════════════════════════════════════════

En-tête : **Dernière mise à jour : 8 juillet 2026 (clôture pilier 14.3
TEXT_IO ; correctif expandeur actuals out composés).**

Ligne 14.3 du tableau des piliers clos, à REMPLACER par :

| **14.3 TEXT_IO** | **CLOS** (conforme LRM sous restrictions consignées) : architecture deux niveaux RAW/public (GET_RAW/PUT_RAW hors spec ; scanners et lecteurs de structure sur RAW, NEW_LINE/NEW_PAGE émettent en RAW) ; GET public saute les terminateurs et tient LINE/COL/PAGE ; PUT tient COL, coupure implicite à LINE_LENGTH bornée ; SET_COL/SET_LINE sortie ; longueurs COUNT := UNBOUNDED (bombe POSITIVE_COUNT := 0 désamorcée) ; exceptions toutes armées (STATUS/MODE/NAME/USE/END/DATA/LAYOUT, 14.2.1 complet, piège n° 45 désamorcé) ; cadrage énuméré WIDTH en blancs de queue (RM 14.3.9, déviation supprimée) ; FF séparateur des scanners et terminateur de ligne. Restrictions consignées : SET_COL/SET_LINE en entrée différés ; END_OF_FILE/END_OF_PAGE mono-anticipation (piège n° 79) ; copies FILE_TYPE non partagées (état COL/look-ahead divergent entre handles) | **8 juillet 2026** — oracles TEXT14 (42), OUTARG1, IO_TEST |

Ligne 14.2.3/14.2.5, à REMPLACER par :

| 14.2.3 / 14.2.5 SEQUENTIAL_IO, DIRECT_IO | validés tous types ; **témoins DIRECT_IO_TEST et SEQ_IO_TEST à reprendre** (END_ERROR : ancien contrat de lecture à EOF, piège n° 79 — packages inchangés) | 10 mai ; reprise à planifier |

Ligne 6 (sous-programmes) du tableau, COMPLÉTER la mention par :
« + actuals out/in out composants indexés/sélectionnés (piège n° 77,
correctif CODE_PROCEDURE_CALL, témoin OUTARG1, 8 juillet) ».

Section « prochaine étape » (ou équivalent), à REMPLACER par l'ordre
convenu :
1. Session courte dédiée : remise d'aplomb des témoins DIRECT_IO_TEST /
   SEQ_IO_TEST (tri idiome-de-témoin vs défaut réel ; les packages n'ont
   pas changé).
2. Tri des 4 échecs ACVC A8 (dump DIANA par test, classement défaut local
   vs pilier absent) — AVANT d'ouvrir le pilier désigné (présomption :
   8.x portée/visibilité/use/renommage).
3. Ouverture du pilier désigné par le tri.

═══════════════════════════════════════════════════════════════════════
## 3. PIEGES.md — entrées à AJOUTER (+ deux mises à jour)
═══════════════════════════════════════════════════════════════════════

77. **Actual out/in out qui est un composant indexé (ou sélectionné) :
    le fallback de CODE_PROCEDURE_CALL l'émettait en rvalue.** Le Lb
    final de CODE_EXP remplace l'adresse calculée du composant par sa
    valeur ; l'appelé (convention scalaire out = par référence) écrit à
    travers cette pseudo-adresse — écriture sauvage, segfault à
    retardement ou corruption silencieuse d'une variable voisine. La
    branche DN_INDEXED doit tester le mode du formel comme le fait déjà
    DN_VARIABLE_ID : in → CODE_EXP (correct pour scalaire chargé ET
    composite qui laisse @), out/in out → CODE_OBJECT_ADDRESS (adresse
    seule). Jumeau DN_SELECTED scalaire dans le même dispatch
    (IS_SOURCE => FALSE). Témoin de verrouillage OUTARG1 (indexé,
    sélectionné, indice calculé, boucle sur composant d'un formel non
    contraint). Détecté par TEXT14P/P14 sur le GET(STRING) public de
    TEXT_IO. (session 8 juillet)

78. **« Validé » ne veut pas dire « exercé » : recenser les chemins que
    personne n'emprunte.** Le chemin de lecture sur fichier réel de
    TEXT_IO (OPEN + GET par descripteur, FILE.ID >= 0) n'avait JAMAIS
    tourné depuis l'origine : tous les témoins de lecture passaient par
    la console redirigée (`< fichier`, chemin ID = -1). Le fossile n° 77
    dormait dans le seul appel de cette forme du corpus, sur ce chemin
    mort. À l'ouverture d'un chemin neuf, une sonde à marqueurs
    séquentiels (modèle TEXT14P : un marqueur APRÈS chaque étape, le
    dernier affiché = dernière étape réussie) localise le point de chute
    en une exécution, avant toute spéculation. (session 8 juillet)

79. **END_OF_FILE et END_OF_PAGE ne voient pas à travers les
    terminateurs (un seul caractère d'anticipation).** Depuis que le GET
    public lève END_ERROR au terminateur de fichier, l'idiome
    `while not END_OF_FILE loop GET(char)` lève END_ERROR sur les
    terminateurs de queue d'un fichier fini par PUT_LINE (END_OF_FILE
    peek le CR → FALSE, le GET suivant traverse CR LF et tombe sur la
    fin). Idiomes sûrs : ligne à ligne (GET_LINE + END_OF_FILE), ou
    boucle GET protégée par un handler END_ERROR. Même limite pour
    END_OF_PAGE derrière un CR LF non consommé. Remède complet =
    FILE_TYPE descripteur partagé à tampon (chantier non planifié).
    Premier suspect des échecs DIRECT_IO_TEST/SEQ_IO_TEST du filet du
    8 juillet. (session 8 juillet)

Mise à jour n° 45 : ajouter en fin d'entrée « — DÉSAMORCÉ le 8 juillet
2026 : OPEN → NAME_ERROR, CREATE → USE_ERROR (TEXT14/U6.4). »

Mise à jour n° 74 : dans « Précédents », remplacer « END_ERROR DIRECT_IO
(en cours) » par « END_ERROR DIRECT_IO/SEQUENTIAL_IO (témoins à l'ancien
contrat, cf. piège n° 79 — reprise planifiée). »

═══════════════════════════════════════════════════════════════════════
## 4. ORACLES_TESTS.md — sections à AJOUTER (+ une mise à jour)
═══════════════════════════════════════════════════════════════════════

### TEXT14 (pilier 14.3, 8 juillet 2026, 42 assertions)

Témoin auto-jugeant de la conformité LRM chapitre 14 de TEXT_IO.
U1 comptabilité COL/LINE en sortie ; U2 SET_COL avant/arrière ;
U3 coupure implicite à LINE_LENGTH bornée + LAYOUT_ERROR ; U4 SET_LINE et
longueur de page ; U5 relecture sur fichier réel (GET à travers les
terminateurs, look-ahead END_OF_LINE traversé par GET(STRING), scanner
entier, GET_LINE, END_ERROR) ; U6 gardes MODE/STATUS/NAME_ERROR ;
U7 DATA_ERROR et LAYOUT_ERROR des variantes chaîne ; U8 cas résiduels
(chaîne nulle, DATA_ERROR fichier, FF devant un entier, END_OF_LINE sur
FF). Crée et supprime ses fichiers TEXT14_*.TXT.
RESULTAT :  42 OK,   0 ECHECS
TEXT14 PASSE
Oracle du filet = la ligne `TEXT14 PASSE`.

### OUTARG1 (correctif expandeur piège n° 77, 8 juillet 2026, 8 assertions)

Verrou de la classe « actual out/in out composé » : composant indexé en
out et in out (indice littéral et calculé), composant sélectionné en out
et in out, boucle sur composant indexé d'un formel non contraint (motif
exact du GET(STRING) public). Indépendant du chemin fichier.
OUTARG1 PASSE
Oracle du filet = la ligne `OUTARG1 PASSE`.

### TEXT14P (sonde, hors filet)

Sonde de bisection à marqueurs séquentiels P00..P20 sur la séquence
écriture → CLOSE → OPEN → relecture. Pas d'oracle : outil de diagnostic à
ressortir quand un chemin d'E/S neuf s'ouvre (piège n° 78).

Mise à jour ENUM_TEST : la note « Sections visuelles résiduelles
(déviation RM 14.3.9 consignée — cadrage à DROITE, blancs de tête) » est
caduque depuis le 8 juillet : le cadrage console est désormais conforme
(blancs de QUEUE). Les sections visuelles montrent le comportement
conforme ; re-vérification visuelle faite au filet du 8 juillet.

═══════════════════════════════════════════════════════════════════════
## RESTE À TERMINER (périmètre réduit, par priorité)
═══════════════════════════════════════════════════════════════════════

1. **Témoins DIRECT_IO_TEST / SEQ_IO_TEST** (END_ERROR) — session courte
   dédiée. Tri attendu : idiome de témoin à l'ancien contrat (piège
   n° 79) vs défaut réel ; les packages DIRECT_IO/SEQUENTIAL_IO n'ont pas
   été modifiés. → PROCHAINE SESSION.
2. **Tag git de clôture** de la session TEXT_IO (si pas déjà posé).
3. **SET_COL / SET_LINE en ENTRÉE** : placeholders silencieux
   (affectation directe du compteur), commentés dans le corps — à
   implémenter le jour où un témoin ou l'ACVC B/C les exercera.
4. **Chantier « descripteur partagé »** (non planifié, à garder visible) :
   remède commun à la mono-anticipation d'END_OF_FILE/END_OF_PAGE (piège
   n° 79) et à l'aliasing des copies FILE_TYPE (état COL/look-ahead
   divergent entre STANDARD_OUTPUT/CURRENT_OUTPUT/handle utilisateur).
5. Pré-existant, hors session : mul/div générales sur FIXED ;
   12.1.3 défauts de formels génériques.

Puis, comme convenu : tri des 4 échecs A8 avant d'ouvrir le pilier 8.x.
