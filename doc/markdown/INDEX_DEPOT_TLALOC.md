# INDEX DU DÉPÔT TLALOC — Manifeste pour sessions de travail Claude

Ce document inventorie tous les fichiers significatifs du dépôt.
Il sert de carte pour savoir quoi uploader selon le sujet de travail.

Date de mise à jour : avril 2026
Dépôt : https://github.com/ViMoBr/Ada83_TLALOC


## 1. RACINE

| Fichier | Rôle |
|---------|------|
| `README.md` | Présentation du projet |
| `make_ada_comp.sh` | Script de recompilation du compilateur |
| `.gitignore` | Exclusions git |
| `.gitattributes` | Attributs git |
| `.gitlab-ci.yml` | CI Framagit |


## 2. CODE SOURCE — src/

### 2.1 Programme principal — src/ada_comp/

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `ada_comp.ads` | 6 | Spec du programme principal |
| `ada_comp.adb` | 173 | Body — orchestration des phases |
| `idl.ads` | 136 | **SPEC IDL** — type TREE, fonctions D/DI/DB, déclarations des phases |
| `idl.adb` | 622 | Body IDL — implémentation accès DIANA |
| `idl-lib_phase.adb` | 1230 | Subunit — phase bibliothèque |
| `idl-err_phase.adb` | 99 | Subunit — phase erreurs |
| `idl-write_lib.adb` | 264 | Subunit — écriture bibliothèque |

### 2.2 Modules IDL partagés — src/communs/

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `idl-page_man.adb` | 312 | Gestionnaire de pages virtuelles (DIRECT_IO) |
| `idl-idl_tbl.adb` | 141 | Tables IDL |
| `idl-idl_man.adb` | 556 | Gestionnaire IDL |
| `idl-print_nod.adb` | 356 | Impression des nœuds |

### 2.3 Analyse syntaxique — src/par_phase/

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `lex.ads` | 63 | Spec analyseur lexical |
| `lex.adb` | 672 | Body analyseur lexical |
| `grmr_ops.ads` | 30 | Spec opérations grammaticales |
| `grmr_ops.adb` | 120 | Body opérations grammaticales |
| `grmr_tbl.ads` | 42 | Spec tables de grammaire |
| `idl-par_phase.adb` | 813 | Subunit — parsing LALR(1) |
| `idl-par_phase-set_dflt.adb` | 104 | Subunit — valeurs par défaut |

### 2.4 Analyse sémantique — src/sem_phase/

| Fichier | Lignes | Thème |
|---------|--------|-------|
| `idl-sem_phase.adb` | 2667 | **Point d'entrée** — orchestration |
| `idl-sem_phase-make_nod.adb` | 2925 | Fabrication de nœuds (PLUS GROS FICHIER) |
| `idl-sem_phase-nod_walk.adb` | 1466 | Parcours de nœuds |
| `idl-sem_phase-red_subp.adb` | 1339 | Résolution de surcharge |
| `idl-sem_phase-def_walk.adb` | 1190 | Parcours de définitions |
| `idl-sem_phase-att_walk.adb` | 1033 | Parcours d'attributs |
| `idl-sem_phase-stm_walk.adb` | 1028 | Parcours de statements |
| `idl-sem_phase-vis_util.adb` | 905 | Utilitaires de visibilité |
| `idl-sem_phase-expreso.adb` | 874 | Résolution d'expressions |
| `idl-sem_phase-aggreso.adb` | 728 | Résolution d'agrégats |
| `idl-sem_phase-fix_pre.adb` | 712 | Fix prédéfinis |
| `idl-sem_phase-req_util.adb` | 638 | Utilitaires de require |
| `idl-sem_phase-fix_with.adb` | 627 | Résolution with |
| `idl-sem_phase-univ_ops.adb` | 576 | Opérateurs universels |
| `idl-sem_phase-instant.adb` | 531 | Instanciation de génériques |
| `idl-sem_phase-exp_type.adb` | 515 | Types d'expressions |
| `idl-sem_phase-uarith.adb` | 508 | Arithmétique universelle |
| `idl-sem_phase-pre_fcns.adb` | 430 | Fonctions prédéfinies |
| `idl-sem_phase-pra_walk.adb` | 381 | Parcours de pragmas |
| `idl-sem_phase-newsnam.adb` | 367 | Nouveaux noms |
| `idl-sem_phase-rep_clau.adb` | 359 | Clauses de représentation |
| `idl-sem_phase-gen_subs.adb` | 319 | Subprograms génériques |
| `idl-sem_phase-derived.adb` | 316 | Types dérivés |
| `idl-sem_phase-def_util.adb` | 604 | Utilitaires de définition |
| `idl-sem_phase-eval_num.adb` | 143 | Évaluation numérique |
| `idl-sem_phase-sem_glob.adb` | 106 | Variables globales sémantiques |
| `idl-sem_phase-hom_unit.adb` | 101 | Unités homonymes |
| `idl-sem_phase-chk_stat.adb` | 96 | Vérification de statut |
| `idl-sem_phase-set_util.adb` | 709 | Utilitaires de set |

### 2.5 Génération de code — src/expander/

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `expander.ads` | — | Spec de l'EXPANDER |
| `expander.adb` | 1415 | Procédure principale |
| `expander-utils.adb` | 420 | Utilitaires de génération |
| `expander-structures.adb` | 434 | Génération des structures |
| `expander-instructions.adb` | 945 | Génération des instructions |
| `expander-expressions.adb` | 1054 | Génération des expressions |
| `expander-declarations.adb` | 1703 | Génération des déclarations |
| `expander-declarations-types_decls.adb` | — | **NOUVEAU** — subunit types |

**Backend FASM :**
| `fasmg/codi_x86_64.finc` | — | Macros LLIR → x86-64 (CRUCIAL) |

### 2.6 Pretty-printer — src/pretty/

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `idl-pretty_diana.adb` | 441 | Affichage du réseau DIANA |

### 2.7 Outils IDL — src/idl_tools/

| Fichier | Rôle |
|---------|------|
| `idl_tools.adb` | Programme principal |
| `idl.ads` / `idl.adb` | IDL (version outils) |
| `idl-idl_read.adb` | Lecture IDL |
| `idl-nam_put.adb` | Génération de diana_node_attr_class_names.ads |
| `idl-nam_put-tbl.adb` | Tables pour nam_put |
| `idl-tbl_put.adb` | Génération de diana.tbl |
| `make.sh` | Script de compilation |

### 2.8 Outils LALR — src/lalr_tools/

| Fichier | Rôle |
|---------|------|
| `lalr_tools.adb` | Programme principal |
| `idl.ads` / `idl.adb` | IDL (version LALR) |
| `idl-check_grmr.adb` | Vérification grammaire |
| `idl-init_grmr.adb` | Initialisation grammaire |
| `idl-lalr_grmr.adb` | Génération tables LALR |
| `idl-load_grmr.adb` | Chargement grammaire |
| `idl-optr_grmr.adb` | Opérateurs grammaire |
| `idl-read_grmr.adb` | Lecture grammaire |
| `idl-stat_grmr.adb` | Statistiques grammaire |
| `idl-term_list.adb` | Liste des terminaux |
| `idl-print_stat.adb` | Impression statistiques |
| `make.sh` | Script de compilation |

### 2.9 Outils divers — src/tools/

| Fichier | Rôle |
|---------|------|
| `block_save.adb` | Outil de sauvegarde en blocs |
| `BLK_SRC/` | Copies de sauvegarde (extension .B*) — doublon |

### 2.10 Shell — src/ada_cli/

| Fichier | Rôle |
|---------|------|
| `shell_exec.adb` | Exécution shell (expérimental?) |


## 3. BINAIRES ET RUNTIME — bin/

### 3.1 Exécutables et scripts

| Fichier | Rôle |
|---------|------|
| `a83.sh` | Script de lancement du compilateur |
| `ada_comp` | Exécutable du compilateur |
| `comp_ada_comp.sh` | Script de compilation du compilateur |
| `comp_kalinda.sh` | Script de compilation (variante?) |
| `comp_predef_units.sh` | Compilation des unités prédéfinies |
| `test.sh` | Script de test |

### 3.2 Fichiers de données

| Fichier | Rôle |
|---------|------|
| `diana.bin` | Tables DIANA binaires (requis par ada_comp) |
| `diana.tbl` | Tables DIANA texte |
| `parse.bin` | Tables de parsing binaires |
| `$$$_TREE.TXT` | Dump DIANA lisible |

### 3.3 Packages Ada 83 prédéfinis (specs)

| Fichier | Rôle |
|---------|------|
| `_standrd.ads` | Package STANDARD |
| `text_io.ads` / `text_io.adb` | TEXT_IO (spec + body) |
| `sequential_io.ads` | SEQUENTIAL_IO |
| `direct_io.ads` | DIRECT_IO |
| `calendar.ads` | CALENDAR |
| `system.ads` | SYSTEM |
| `io_exceptions.ads` | IO_EXCEPTIONS |
| `machine_code.ads` | MACHINE_CODE |
| `unchecked_conversion.ads` | UNCHECKED_CONVERSION |
| `unchecked_deallocation.ads` | UNCHECKED_DEALLOCATION |

### 3.4 Programmes de test (sources)

| Fichier | Constructions testées |
|---------|----------------------|
| `dis_bonjour.adb/.ads` | Hello world, appel PUT |
| `hanoi_tower.adb/.ads` | Récursion, paramètres |
| `array_test.adb/.ads` | Tableaux |
| `record_test.adb` | Records |
| `string_test.adb/.ads` | Strings |
| `carpos_test.adb/.ads` | Character/position |
| `file_test.adb/.ads` | Fichiers I/O |
| `lis_caractere.adb/.ads` | Lecture caractère |
| `test.adb` | Test général |
| `test_1/2/3.adb` | Tests variés |
| `test_multi.adb` | Test multi-unité |
| `test_exceptions.adb` | Exceptions |
| `test_subunit.adb/.ads` | Subunits |
| `test_subunit-the_subpack.adb` | Sub-package |
| `test_subunit-the_subunit.adb` | Sub-unit |
| `test_vis_1.adb/.ads` | Visibilité |
| `test_vis_1-p3.adb` | Visibilité package |
| `test_vis_1-p3-impl.adb` | Visibilité imbriquée |

### 3.5 Bibliothèque ADA__LIB

Contient les `.DCL`, `.BDY`, `.SUB` pré-compilés de la bibliothèque
standard et des tests, les `.FINC` et `.fas` correspondants,
et l'exécutable `fasmg`.


## 4. SPÉCIFICATIONS IDL — idl/

| Fichier | Rôle |
|---------|------|
| `diana.idl` | **Spécification IDL de DIANA** (fichier source maître) |
| `idl.idl` | Spécification IDL de l'IDL lui-même |
| `lalridl.idl` | Spécification IDL pour le parseur LALR |


## 5. DOCUMENTATION — doc/

### 5.1 Documentation technique (doc/markdown/)

| Fichier | Langue | Contenu |
|---------|--------|---------|
| `ARCHITECTURE.md` | FR | Architecture interne détaillée |
| `go_ahead-eng.md` | EN | Motivation du projet, historique |
| `go_ahead-fra.md` | FR | Idem en français |
| `introduction-eng.md` | EN | Introduction technique, phases |
| `introduction-fra.md` | FR | Idem en français |
| `structure_complete-fra.md` | FR | Structure complète avec liens |
| `structure-fra.md` | FR | Structure résumée |
| `tlaloc-diana-idl.md` | EN | Documentation DIANA/IDL, type TREE |
| `patrons_de_types_Kruchten.md` | FR | Patterns de types (Kruchten) |
| `logo.txt` / `logo_simple.txt` | — | ASCII art du logo |
| `TLALOC_icone.png` | — | Icône du projet |

### 5.2 Spécifications DIANA

| Fichier | Contenu |
|---------|---------|
| `DIANA-Ref-Manual-1986-rev4.pdf` | Manuel de référence DIANA rev.4 |
| `DIANA-Ref-Manual-1983-rev3.pdf` | Manuel de référence DIANA rev.3 |
| `DIANA_NODES.pdf` | Nœuds DIANA navigables (cliquable) |
| `DIANA_NODES.odt` / `DIANA_NODES_2.odt` | Versions ODF |
| `DIANA_CLASS_.odt` | Classes DIANA |
| `diana_graph.pdf` / `diana_graph.svg` | Graphe DIANA |
| `diana.dot` / `diana_classes_v2.dot` | Sources Graphviz |
| `extraction_DIANA_idl.txt` | Extraction texte du fichier IDL |

### 5.3 Documentation de référence Ada 83

| Fichier | Contenu |
|---------|---------|
| `Ada-Ref-Manual-ANSI-MIL-STD-1815A.pdf` | LRM Ada 83 officiel |
| `cancellation_MIL-STD-1815_NOTICE-1.pdf` | Notice d'annulation |
| `DEC_ada_lrm.pdf` | LRM version DEC |
| `lrm-francais/` | LRM traduit en français (14 chapitres + annexes) |
| `lrm-2.odt` / `lrm-8.odt` / `lrm-10.odt` | Chapitres sélectionnés en ODF |
| `A83_wiki/alrm_9.*.md` | Chapitre 9 (tasking) en markdown |

### 5.4 Publications et références

| Fichier | Contenu |
|---------|---------|
| `Ada-DIANA-frontend-user-manual-1988-Bill-Easton.rtf` | Manuel Peregrine |
| `SDS_ADA209447_Easton.pdf` | Article Easton |
| `IDL_Lamb_1981.pdf` | Article IDL original (Lamb) |
| `IDL-intro-1988-237.ps` | Introduction IDL |
| `Interview_Ichbiah_1984.pdf` | Interview Jean Ichbiah |
| `thèse-JP-Rosen-ENST-1986.pdf` | Thèse Rosen (Ada/Ed-C) |
| `thèse-P-Kruchten-ENST-1986.pdf` | Thèse Kruchten (Ada/Ed-C) |
| `exp_ada_codegen-BG-Zorn-UC-Berkeley-1984.pdf` | Codegen Berkeley |
| `Schonberg...-1985-1.pdf` | NYU — prototype à implémentation |
| `thesis_J_Katwijk_AdaMinus_compiler_1987.pdf` | Thèse Ada-minus |
| `thesis_J_Rosenberg_1983.pdf` | Thèse Rosenberg |
| `G_Bray_Generics.pdf` | Génériques Ada |
| `T_D_Newton_generics.pdf` | Génériques Ada |
| `Rosen_Ada_Numerics_Model-AUJ43.pdf` | Modèle numérique Ada |
| `Karlsruhe_valid.pdf` / `Karsruhe_optim.pdf` | Validation/optimisation |
| `Rational_*.pdf` | Brevets Rational (3 fichiers) |
| `theGentleCompilerConstructionSystem.pdf` | Système Gentle |

### 5.5 Archives patrimoniales

| Répertoire | Contenu | Volume |
|------------|---------|--------|
| `Thèses_Pologne/Michal_Cierniak/` | Thèse + code DIANA→A-code | ~150 .tif |
| `Thèses_Pologne/Aldona_Wierzinska/` | Thèse A-code→386 | ~88 .tif |
| `Thèses_Pologne/Dariusz_Glowaki/` | Thèse runtime | ~92 .tif |
| `Thèses_Pologne/Miroslav_Chlopek/` | Thèse linker | ~82 .tif |
| `ada_minus_katwijk/` | Compilateur Ada-minus Delft (C) | ~500 fichiers |

### 5.6 Travail IA Claude (doc/Travail_IA_Claude/)

| Fichier | Contenu |
|---------|---------|
| `INDEX.txt` | Index des documents Claude |
| `doc_mise_en_place.md` | Document initial du projet |
| `structure_TLALOC_compiler.md` | Structure modulaire |
| `RESUME_ANALYSE_TLALOC.txt` | Analyse complète |
| `tlaloc_structure.dot` / `.svg` | Diagramme de structure |
| `diana.html` | Visualisation DIANA |
| `extrait_text_io_patrons.md` | Patterns TEXT_IO |
| `README_analyse_TLALOC.md` | Guide des documents |
| `travail_DIANA_1/` | Session EXPANDER (skeletons, plan d'action) |
| `travail_Delft_Ada/` | Notes Ada-minus Delft |


## 6. GUIDE D'UPLOAD PAR SESSION DE TRAVAIL

### Session EXPANDER (génération de code)
Uploader :
- `src/expander/expander.adb`
- `src/expander/expander-declarations.adb` (ou le subunit visé)
- `src/expander/fasmg/codi_x86_64.finc`
- `src/ada_comp/idl.ads` (pour les fonctions D/DI/DB)
- Un programme test `.adb` + son `.FINC` généré
- Le dump DIANA correspondant (option P ou U)

### Session SEM_PHASE (analyse sémantique)
Uploader :
- `src/sem_phase/idl-sem_phase.adb` (point d'entrée)
- Le subunit spécifique visé
- `src/ada_comp/idl.ads`
- `bin/idl_tools/diana_node_attr_class_names.ads`

### Session IDL / DIANA
Uploader :
- `src/ada_comp/idl.ads` + `idl.adb`
- `idl/diana.idl`
- `bin/idl_tools/diana_node_attr_class_names.ads`

### Session PAR_PHASE (parsing)
Uploader :
- `src/par_phase/` (tous les fichiers)
- `src/ada_comp/idl.ads`

### Session documentation / architecture
Uploader :
- Les fichiers `doc/markdown/` concernés
- Ce document d'index

### Session outils (idl_tools, lalr_tools)
Uploader :
- Le répertoire `src/idl_tools/` ou `src/lalr_tools/` concerné
- `idl/diana.idl` (ou `idl.idl`, `lalridl.idl`)
