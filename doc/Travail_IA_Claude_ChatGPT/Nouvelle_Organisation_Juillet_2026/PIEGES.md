# PIÈGES — registre numéroté (append-only, numéros stables)

Règle d'usage : tout nouveau piège reçoit le numéro suivant et ne réécrit jamais
les précédents (les renvois « piège n X » figurent dans le code et le journal).
Dernière entrée : n° 66 (5 juillet 2026).


1. Double déréférencement paramètre : `LVa` (pas `La`) pour le doublet.
2. Syntaxe virgules vides : `LIa , , ofs` pas `LIa -1, ofs`.
3. PRM result__ofs toujours en dernier dans PRMS.
4. SD après chaque SYS_FILE_* dans les fonctions MACHINE_CODE.
5. NOT booléen = `LI 1` + `OUX`, pas `NON`.
6. While = `BF`, pas `BRZ`.
7. REGIONS_PATH : condition `>= CUR_LEVEL`.
8. Opérateurs en MAJUSCULES.
9. Ada 83 strict (`-gnat83`).
10. STATOFS arrondi : BOOLEAN 1 bit → 1 octet.
11. DN_RANGE_ATTRIBUTE non géré : contournement FIRST..LAST.
12. Versions sans FILE : déléguer, pas de MACHINE_CODE inline.
13. Fichiers uploadés : toujours post-commit github.
14. **fasmg `dq` hex 64 bits** : tronqué, écrire les octets en `db` LE.
15. **fasmg `movq xmm,[mem]`** : peut être interprété comme movd 32 bits,
    utiliser `movsd` (F2 0F 10/11) pour pile↔xmm.
16. **FCLT/FCLE encodage** : ucomisd xmm1,xmm0 = ModRM 0xC8 pas 0xC9.
17. **CODE_CONVERSION statique** : un LI suivi de CVTIF si cible DN_FLOAT.
18. **OPER_SIZ_CHAR DN_FLOAT** : forcer 'q' (CD_IMPL_SIZE=32 dans STANDARD
    mais on stocke toujours en double 64 bits).
19. **CODE_SHORT_CIRCUIT** : était un stub `null`, causait des BF/BT sans
    condition évaluée. Corrigé session 12 avril.
20. **Wrapper générique paramètres** : `Lq` pour tous → `La` pour
    composites et out/in_out. Corrigé session 13 avril.
21. **CODE_BLOCK sans UNLINK** : un bloc `declare` faisait LINK N sans
    UNLINK N correspondant → corruption du display au retour.
    Corrigé session 13 avril.
22. **Propagation out/in_out** : `INVERSE_RECURSE_ON_PARAMETERS` ne
    traitait pas DN_OUT_ID / DN_IN_OUT_ID → message d'erreur au lieu
    de code. Corrigé session 13 avril.
23. **GET_LINE console** : SYS_GET_CHAR en boucle → pas d'écho.
    Remplacé par SYS_GET_STR pour la console. Corrigé session 13 avril.
24. **postpone LIFO** : les CST émises en premier se retrouvent en
    dernier en mémoire. Ordre d'émission inverse requis pour obtenir
    un layout mémoire séquentiel.
25. **XD_REGION des procédures de générique** : pointe vers `DN_GENERIC_ID`,
    pas `DN_PACKAGE_ID`. Ne pas utiliser `SM_FIRST` pour tester.
    (session 15 avril)
26. **Level du wrapper générique** : `CUR_LEVEL - 1` pour accéder aux
    variables de l'instance (GFP_disp, __u_ofs), pas `CUR_LEVEL`.
    (session 15 avril)
27. **Ada 83 strict** : pas de déclarations d'objets après un
    sous-programme imbriqué — utiliser `begin declare ... end`.
    (session 15 avril)
28. **LIVa pour double déréférencement** : quand il faut suivre deux
    niveaux de pointeurs (GFP → patron → champ), utiliser LIVa avec
    DISP et OFS, pas deux `La` séparés. (session 15 avril)
29. **Offset IMAGES dans le patron** : depuis TYPE.SIZ, l'offset vers
    IMAGES.data_ptr est 16 (SIZ:dd=0, FST:dd=4, LST:dd=8, puis
    alignement qword → data_ptr à 16). (session 15 avril)
30. **DN_ITERATION_ID dans INVERSE_RECURSE_ON_PARAMETERS** : les
    variables de boucle `for` ne sont ni DN_VARIABLE_ID ni DN_IN_ID.
    Reconstruire le nom FASM via `LABEL_STR(CD_OFFSET)` + `"_disp"`.
    Corrigé session 25 avril.
31. **Offset GFP hard-codé dans MACHINE_CODE** : chaque procédure du
    modèle a un nombre différent de PRM, donc GFP_ofs est à un offset
    différent (-40 pour PUT/4 params, -24 pour GET/2 params). Ne pas
    copier-coller les offsets entre procédures. (session 25 avril)
32. **CODE_ASSIGN et types formels génériques** : `SM_EXP_TYPE` d'un
    type formel peut être `DN_ENUMERATION` mais avec un `CD_IMPL_SIZE`
    différent du type actuel. Le `else` catch-all avec STORE_OR_CALLI
    couvre les cas non reconnus. (session 25 avril)
33. **`exit when not(A and then B or C)`** : le mélange `and then`/`or`
    dans une même expression est mal compilé par l'expander. Réécrire
    en `if/elsif/else/exit`. (session 25 avril)
34. **`return` dans un bloc `declare`** : CODE_RETURN doit émettre les
    UNLINK intermédiaires avant `BRA ret_lbl` pour chaque niveau entre
    CUR_LEVEL et le niveau de la procédure englobante.
    Corrigé session 25 avril.
35. **Réutilisation de FILE_TYPE après CLOSE/OPEN** : les champs internes
    (AT_END_OF_FILE, HAS_LOOK_AHEAD) doivent être réinitialisés dans
    CREATE et OPEN. Corrigé session 25 avril dans text_io.adb.
36. **Mismatch taille store indirect / variable** : un `SId` (dword)
    sur une variable d'un octet (petite énumération) écrase 3 octets
    adjacents. Résolu par le mécanisme LD/ST via CALLI qui utilise la
    taille correcte du type actuel. (session 25 avril)
37. **Micro-procédures LD/ST dans l'elab_spec** : le code des
    micro-procédures doit être contourné par `BRA post_LD/ST` pendant
    l'élaboration, sinon il corrompt la pile. (session 25 avril)
38. **La vs LIa pour charger l'adresse de ST** : `La , -ENUM__st_ofs`
    (simple) et non `LIa , -ENUM__st_ofs, 0` (indirect). Le contenu
    de __st_ofs est déjà l'adresse de saut. (session 25 avril)
39. **Correspondance miroir PRM/VAR** : les VAR de l'instance doivent
    être dans l'ordre **inverse** des PRM du modèle. Le premier PRM
    (offset 8) correspond à la dernière VAR avant GFP_disp (offset -8).
    (session 25 avril)

40. **`LVa` sur `in` composite dans syscall** : donne l'adresse du doublet
    descripteur, pas des données brutes. Pour les I/O fichier, utiliser
    `ITEM'ADDRESS` comme paramètre explicite `SYSTEM.ADDRESS` et `La 2, -OFS`
    dans la macro LLIR. (session 10 mai (1))
41. **`ITEM'ADDRESS` sur composite écrivait des pointeurs de pile** → **résolu
    (session 10 mai (2))**. Voir section 2.2 : mécanisme `__in_adr_ofs` /
    `__out_adr_ofs` via CALLI dans `CODE_ADDRESS`.
42. **Hexdump cohérent ≠ fichier correct** : READ/WRITE symétriques sur le
    même doublet donnent des résultats corrects en intra-processus mais
    écrivent des pointeurs de pile dans le fichier. Un second processus
    segfaulterait. Toujours vérifier avec hexdump que le fichier contient
    les valeurs attendues, pas des adresses `0x7ffc...`. (session 10 mai (1))
43. **`ITEM'ADDRESS` ne déréférence pas automatiquement le doublet** : dans
    un body générique, `X'ADDRESS` où `X` est un composite passe par
    `CODE_ADDRESS` qui émet `LVa` + CALLI via `__in_adr_ofs` ou
    `__out_adr_ofs` selon le mode du paramètre. (session 10 mai (2))
44. **Asymétrie `in` scalaire vs `out` scalaire pour ADDRESS** : un `in`
    scalaire est passé par valeur (copie locale), `LVa` donne directement
    l'adresse correcte → `__in_adr` = no-op (`RTD 0`). Un `out` scalaire
    est passé par référence (adresse de la destination), `LVa` donne
    l'adresse du slot → `__out_adr` doit déréférencer (`La -1, 0`).
    Ne pas confondre les deux micro-procédures. (session 10 mai (3))
45. **`OPEN` sur fichier inexistant échoue silencieusement** : si
    `ERR_OR_ID < 0`, le FILE_TYPE n'est pas mis à jour et conserve ses
    valeurs par défaut (IS_OPENED=FALSE, MODE=IN_FILE). Toujours utiliser
    CREATE pour créer un nouveau fichier, OPEN uniquement pour un fichier
    existant. (session 10 mai (3))



46. **Sous-type tableau anonyme partagé + `CD_COMPILED`** : deux objets de contrainte identique (p. ex. deux `STRING(1..6)`) peuvent partager le **même** nœud `DN_CONSTRAINED_ARRAY` en DIANA (vérifiable par le dump : `SM_OBJ_TYPE` identique). Le drapeau `CD_COMPILED` posé par `PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC` fait alors sauter la génération du descripteur local pour le second objet, qui retombe sur le type de base non contraint (`STANDARD._STRING`) via `XD_SOURCE_NAME` → `use__info` invalide → segfault au déréférencement. Matérialiser un type-info local par objet dès qu’il existe une contrainte anonyme, sans dépendre de `CD_COMPILED`. (session 4 juillet)

47. **Niveau d’émission de la table de thunks générique** : `CODE_GENERIC_ACTUALS` est appelé **après** `INC_LEVEL` sur le chemin d’instanciation de sous-programme ; émettre les `Sa` des thunks et de `GFP_disp` à `CUR_LEVEL` écrit dans le frame du corps de l’instance (niveau N), alors que la relecture se fait à `CUR_LEVEL − 1` (le bloc, niveau N−1) et que le frame N n’existe pas encore / plus au moment de l’élaboration du bloc → écriture dans un frame mort → segfault. Passer un niveau cible explicite : `CUR_LEVEL − 1` pour l’instanciation de sous-programme, `CUR_LEVEL` (défaut historique) pour l’instanciation de package, dont le site d’appel n’est pas précédé d’`INC_LEVEL`. (session 4 juillet)

48. **`endPRO` pour un bloc `declare`** : réutiliser `endPRO` (qui définit `post:` et `loc_siz`, symboles globaux au namespace) pour clore un bloc imbriqué crée une seconde définition de `post:` et casse la résolution du `BRA post` de la procédure englobante → saut au milieu du corps → sortie de frame sur pile non initialisée. Rendre `post`/`elab`/`loc_siz` uniques par routine, ou utiliser une macro de fin de bloc distincte ne définissant pas `post:`. (session 4 juillet)



49. CODE_LENGTH / attributs dimensionnés : tout chemin d'attribut tableau doit lire AS_EXP.
50. Affectation composite : LEN depuis le descripteur DESTINATION ([__u].SIZ/8),
    jamais XD_SOURCE_NAME→_TYPE.size (sous-types anonymes → type de base).
    `LCA name.data_ptr` d'une constante STR = @doublet, pas @data : `La` requis.
51. ACVC classe A = oracle compilation+exécution, PAS de valeurs. La sémantique
    n'est protégée que par les programmes-témoins à sortie attendue et les séries C.
    (Démontré deux fois : A21001A vs affectation muette ; VEC3'RANGE vs boucle vide.)
52. Tout compte d'éléments dynamique → CLAMP0. AMENDEMENT : le motif à traquer est
    « tout calcul de compte », pas la paire textuelle SUB/INC (14e site en ordre
    inversé) — une règle de revue formulée comme un grep hérite des angles morts du grep.
53. Opérateur/nœud non reconnu ne doit JAMAIS ne rien émettre (pile déséquilibrée →
    segfault lointain, symptôme BLKMOV avec pointeur en compteur). Stub équilibré + commentaire.
54. AND/OR/XOR scalaires : macros ET/OU/OUX existaient, dispatch absent. NOT booléen reste LI 1+OUX.
55. Un stub doit respecter le CONTRAT DE NATURE du résultat (scalaire vs @doublet),
    pas seulement l'équilibre de pile — la nature dépend de l'opérateur, pas de l'opérande.
56. CD_IMPL_SIZE porte des bits MINIMAUX (1 pour BOOLEAN, 3 pour 7 littéraux), pas
    la taille de stockage : toute consommation composant arrondit au STORAGE_UNIT.
    (OPER_SIZ_CHAR consomme le brut à bon droit : ≤8 → 'b'.)
57. Les deux COMP_SIZE_BITS homonymes (expressions / types_decls) doivent évoluer
    ensemble — candidates à fusion dans UTILS.
58. CD_LEVEL / CD_COMPILED des types vivent sur le TYPE_SPEC, pas sur le *_ID de
    XD_SOURCE_NAME (qui sert au chemin REGIONS_PATH et au libellé, rien d'autre).


59. **Levée de stub : le stub mort ment.** Remplacer un stub par le code réel en
    LAISSANT le stub en place derrière (copier-coller additif) empile le résultat
    forcé PAR-DESSUS le résultat correct — le consommateur lit le stub, le vrai
    résultat devient un orphelin de pile (violation transitoire du n° 53).
    Symptôme vécu (lot D2) : sept FAUX avec un LEXCMP parfaitement fonctionnel
    en dessous. Règle de revue : après chaque levée de stub, (1) supprimer le
    commentaire-sentinelle du stub dans la source, (2) grepper ce commentaire
    dans le .FASM généré — s'il apparaît encore, le stub est vivant. Corollaire :
    tout stub désormais inatteignable (p. ex. après re-routage amont) se SUPPRIME,
    il ne se commente pas. (session 5 juillet)

60. **Vue contrainte ≠ type de base. Tout test X.TY = DN_RECORD (ou DN_ARRAY) dans l’expander doit se demander où passe la vue DN_CONSTRAINED_RECORD : quatre exemplaires du motif dans ce seul lot (CODE_ASSIGN ×3 branches, CODE_RETURN, CODE_FUNCTION_CALL, tailles statiques). Normaliser vers SM_BASE_TYPE dès l’entrée ; les symboles .size/.SIZ/offsets de la vue anonyme N’EXISTENT PAS, ceux de la base oui.
61. SM_VALUE : deux encodages. Valeur courte : PT = HI et le genre est dans le champ NOTY (= DN_NUM_VAL) ; valeur longue : PT /= HI et le genre est dans TY. Confondre NOTY et TY fait rater la staticité (idiome de référence : expander-expressions lignes ~4563/4689).
62. return "littéral" : SM_EXP_TYPE = DN_VOID. Le type ne vient pas de l’expression ; router sur EXP.TY. La macro STR pose une constante dont le champ data_ptr ouvre un doublet complet : LCA nom.data_ptr = @doublet.
63. Convention résultat composite. L’APPELANT fabrique le doublet anonyme (data+use__info) et empile son adresse comme slot résultat ; la fonction BLKMOV à travers [result__ofs].data_ptr. Un LI 0 de placeholder pour un retour composite = écriture à l’adresse nulle chez l’appelé.
64. **« Pas géré » ≠ « pas connaissable ICI ».** Le refus bruyant (n° 53)
    sanctionne un cas non traité ; il ne doit PAS sanctionner une valeur
    simplement indisponible à ce point du flux mais que l'assembleur, lui,
    résoudra. Cas vécu (C11, ACVC A7) : un tableau à composant record dont
    la vue complète (type privé) n'est pas encore compilée n'a pas de
    CD_IMPL_SIZE — mais le symbole <rec>.size existera plus loin dans le
    même FINC, et fasm est multi-passes. Sortie correcte : émettre le
    symbole (report), pas lever. Même partage expander/fasm que STATOFS,
    size=$, les références avant définition. Test mental : « si je mets ce
    calcul entre les mains de fasm, sait-il finir ? » Si oui, report ;
    sinon seulement, refus. (session 5 juillet)

65. **Chaîne de `if` sans `else` final = trou silencieux latent.** Une
    cascade `if COND_1 … end if; if COND_2 … end if;` qui épuise les cas
    connus SANS clause terminale attrape un cas nouveau en NE FAISANT RIEN
    — la variante dégénérée du n° 53, d'autant plus vicieuse qu'aucun stub
    n'est visible à supprimer. Deux occurrences dans la même campagne :
    CODE_RETURN (trois types non gérés, C7-C8, cf. n° 62-63) et <<UNARY>>
    (le NOT, cf. n° 66). Règle : toute cascade de `if` disjoints sur un
    NODE_NAME ou un OP_STR se termine par une garde `if <aucun des cas>
    then … PROGRAM_ERROR`. Un `case … when others` est structurellement
    préférable quand la langue le permet. (session 5 juillet)

66. **Livraison de fichier COMPLET + copie projet en retard = écrasement
    silencieux des correctifs locaux.** Régression vécue : le NOT scalaire,
    restauré localement par le mainteneur, réécrasé à CHAQUE intégration
    d'un fichier entier bâti sur une copie projet datée (elle-même sans
    C12/C13 en début de session — le décalage était mesurable). Symptôme
    différé de deux semaines, invisible tant qu'aucun témoin n'exerçait le
    NOT sous auto-jugement. Parades, par ordre de préférence : (1) livrer
    des INSTRUCTIONS de patch (emplacement, ancre, bloc, motif) que le
    mainteneur applique et RELIT — il est l'élément lent qui voit ;
    (2) à défaut, diff-er tout fichier complet contre la version locale
    AVANT écrasement ; jamais d'intégration en aveugle. Corollaire :
    rafraîchir les sources projet juste avant chaque lot. (session 5 juillet)
