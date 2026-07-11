# TLALOC : écrire un compilateur Ada 83, quarante ans plus tard

*Comment un listing retrouvé, un frontal DIANA des années 1990, un assembleur moderne et un collaborateur improbable ont produit un compilateur complet pour un langage que le monde avait décidé de laisser derrière lui.*

---

## Un listing qui refusait de mourir

En 2024, j'ai retrouvé un listing papier dans un carton.

C'était un tirage laser de 1988 : le code source de Sybilin, un logiciel de conception symbolique pour circuits intégrés micro-ondes que j'avais écrit comme doctorant au CNET de Bagneux. Le programme calculait des fonctions de transfert par graphes de fluence de Mason et Coates, une technique déjà peu à la mode à l'époque. Il avait d'abord été écrit en FORTRAN et était, disons-le poliment, illisible. J'avais demandé l'autorisation de le réécrire en Ada 83 sur MicroVAX. Je l'avais obtenue.

J'ai scanné le listing. Je l'ai passé à l'OCR. Puis, plus par curiosité qu'autre chose, j'ai donné le résultat à GNAT avec `-gnat83`.

Il a compilé. Presque sans modification.

Un programme écrit en 1988, imprimé sur papier, oublié pendant trente-six ans, reconstruit à partir d'un scan optique — et il se construit et s'exécute sur une machine Linux de 2026. Pas d'enfer des dépendances. Pas d'API obsolètes. Pas de framework à réapprendre. Le langage était simplement resté immobile, et tout ce que j'avais bâti dessus était resté debout.

Ce n'est pas de la nostalgie. C'est un fait concernant Ada 83 dont je crois que l'industrie du logiciel n'a jamais tiré les conséquences, et c'est une grande part de la raison pour laquelle j'ai passé les deux années suivantes à lui écrire un compilateur.

---

## Plaidoyer pour une norme morte

Ada 83 — formellement MIL-STD-1815A-1983 — est resté dans les mémoires, quand il y est resté, comme un mandat d'achat du Pentagone. Lourd. Verbeux. Imposé. Le langage qu'on vous forçait à utiliser.

J'utilise Ada sans interruption depuis 1985, à travers toutes ses révisions, et j'en suis arrivé à une conclusion hétérodoxe : **Ada 83 était la meilleure version d'Ada, et chaque révision ultérieure l'a dégradé en tant que langage de conception.**

Je n'y suis pas venu par la théorie. J'y suis venu par l'échec.

Depuis des années, je reconstruis — obsession parallèle — un système d'exploitation dans l'esprit du Macintosh System d'origine ; un projet que j'appelle Kalinda. Le Mac OS des débuts reste à mes yeux l'un des logiciels systèmes les plus cohérents jamais livrés, et je voulais le comprendre en le reconstruisant avec de meilleurs outils.

J'ai écrit Kalinda quatre fois.

La première en Pascal sous CodeWarrior, sur un Macintosh LC III. Elle est allée remarquablement loin, puis s'est effondrée sous son propre poids : impossible à maintenir.

La deuxième tentative était en C. Je l'ai abandonnée rapidement. Du point de vue du génie logiciel, c'était affreux : le langage n'offrait aucune aide pour tenir ensemble une architecture de cette taille.

La troisième était en Ada 95. C'est l'échec intéressant. Ada 95 est un *meilleur langage* qu'Ada 83 selon la plupart des critères habituels — types étiquetés, paquetages enfants, objets protégés, système de types plus riche. Et la conception est devenue conceptuellement folle. Chaque fonctionnalité supplémentaire était un axe supplémentaire de décomposition possible de l'architecture, et avec assez d'axes, il n'y a plus de bonne réponse. Je me suis retrouvé à concevoir la conception au lieu de concevoir le système. La richesse censée m'aider noyait la clarté structurelle de ce que je bâtissais.

La quatrième tentative est en Ada 83. C'est la version la plus maintenable que j'aie jamais eue, et c'est celle qui vit.

Voici ce que je veux dire clairement, parce que cela va à rebours de toute la direction prise par l'évolution des langages : **Ada 9X et Ada 2X sont, en un sens important, une déviance.** Ils sont plus riches. Ils sont plus expressifs. Et ils le sont selon des dimensions qui ne sont pas indispensables, et qui brouillent la conception architecturale d'un système au lieu de l'affûter. Ada 83 dispose d'un *petit* ensemble de constructions structurantes puissantes — paquetages, typage fort, généricité, tâches, exceptions — et c'est précisément parce que cet ensemble est petit qu'il force l'architecture à être juste plutôt qu'astucieuse.

La contrainte n'est pas une limite d'Ada 83. C'est sa qualité.

Et si cela est vrai, alors laisser mourir Ada 83 — le laisser devenir une norme sans implémentation vivante, lisible seulement sous forme de PDF — serait une perte réelle. Pas une perte sentimentale. Une perte technique.

C'est ce que TLALOC existe pour empêcher.

---

## Retrouver le frontal

Au cours de ma pratique d'Ada, je suis tombé par hasard sur quelque chose dans l'Ada Software Repository — le CD-ROM Pine Creek, vestige d'une époque où le logiciel était archivé sur support physique par des gens qui comprenaient que l'archivage importait.

Y étaient enfouies des pièces d'un frontal Ada 83 vers DIANA, issues d'un projet Peregrine Systems dirigé par Bill Easton, qui s'est déroulé de 1988 à 1993. Les phases avaient été construites comme des exécutables distincts. Le tout semblait avoir été compilé sous DEC Ada. C'était incomplet, c'était un ensemble de morceaux plutôt qu'un tout fonctionnel, et c'était indubitablement le squelette de quelque chose de sérieux.

Un mot sur DIANA, car c'est la raison pour laquelle ce squelette méritait d'être exhumé.

**DIANA** — *Descriptive Intermediate Attributed Notation for Ada* — est une représentation intermédiaire normalisée, structurée en graphe, conçue spécifiquement pour Ada au début des années 1980. Ce n'est pas un AST au sens moderne. C'est un graphe attribué : les nœuds représentent les constructions du langage, les attributs portent l'information sémantique, et la structure capture toute la toile des dépendances d'un programme, y compris ses relations de compilation séparée. DIANA a été conçu comme un format *partagé*, pour que de multiples outils Ada puissent interopérer sur une représentation commune des programmes.

DIANA a été presque entièrement oublié. Les compilateurs modernes construisent des RI sur mesure, abaissent agressivement, et traitent la forme intermédiaire comme un détail d'implémentation. DIANA faisait le pari inverse : la forme intermédiaire comme *norme publiée*, format d'échange, artefact de premier rang.

Pour un compilateur dont la finalité est la préservation et la lisibilité, ce pari se révèle exactement le bon.

À partir de 2005, j'ai entrepris la réécriture et l'intégration complètes de ce frontal. J'ai conservé la séparation stricte des phases — c'est l'une des meilleures idées de la conception d'origine — mais j'ai rationalisé l'architecture et entièrement reconstruit les structures de données internes des graphes DIANA.

Vers 2018, j'avais un frontal Ada 83 complet produisant du DIANA. Analyse lexicale et syntaxique, gestion de bibliothèque, analyse sémantique complète. Et je vais dire une chose immodeste, parce que je la crois vraie et parce que c'est la raison la plus forte pour qui que ce soit d'autre de s'intéresser à ce code : **je ne connais pas de compilateur moderne dont l'architecture soit aussi propre et aussi lisible que celle-ci.** Les frontières de phases sont réelles. Chaque phase a un contrat honnête, énonçable. On peut le lire.

Et il était incapable de produire le moindre exécutable.

---

## Le mur contre lequel meurent les compilateurs amateurs

Un frontal qui produit une belle représentation intermédiaire et aucun code machine est une façon très élaborée de confirmer que votre programme se parse.

C'est dans le backend que meurent les projets de compilateurs amateurs, et je le dis avec précision : il y eut un projet polonais de compilateur Ada pour lequel Michał Cierniak avait écrit une amorce d'expander. Il n'a pas survécu à l'écart entre DIANA et le code exécutable. Cet écart a tué plus de projets Ada que n'importe quel autre obstacle, et j'avais toutes les raisons de croire qu'il tuerait le mien.

L'idée qui a fait sauter le verrou, c'est **fasmg**.

fasmg — le moteur macro-assembleur de la famille Flat Assembler — est un moteur d'assemblage programmable. Ce qui signifiait que je n'avais pas besoin de construire un générateur de fichiers objets, un moteur de relocation et un éditeur de liens ELF avant de voir ma première instruction s'exécuter. Je pouvais émettre du *texte*, et laisser un outil mûr, rapide et éprouvé le transformer en binaire ELF.

En quelques semaines, ceci est apparu :

```
$ ./DIS_BONJOUR
 Bonjour
```

Un « hello, world » français — depuis du source Ada 83, à travers mon analyseur syntaxique, ma phase de bibliothèque, mon analyseur sémantique, DIANA, mon expander, vers de l'assembleur FASM, vers un exécutable ELF-64, s'exécutant sous Linux.

C'est à peu près la chose la moins impressionnante qu'un ordinateur puisse afficher. Ce fut, pour moi, le moment où le projet a cessé d'être un rêve pour devenir un problème d'ingénierie.

Entre DIANA et l'assembleur se trouve **LLIR**, une représentation intermédiaire de bas niveau organisée en machine à pile. C'est la couche qui rend la portabilité traitable : la sémantique d'Ada est abaissée une seule fois sur une machine à pile abstraite, et chaque nouvelle architecture cible demande de porter la machine à pile plutôt que de réabaisser le langage.

Pour être précis sur l'état réel, car la distinction compte : **x86-64 est la cible de référence** — celle qui est exercée, testée, éprouvée. aarch64 a été porté et a tourné, une fois, il y a quelque temps. RISC-V 64 est porté mais pas encore validé. La conception en machine à pile est le pari que ces portages sont bon marché ; x86-64 est la preuve que la chaîne fonctionne.

---

## Le moment où je cesse d'être seul

Voici le bilan honnête.

Début 2024, j'avais : un frontal Ada 83 complet et propre, représentant près de deux décennies de travail ; une preuve de concept que fasmg pouvait combler le fossé du backend ; et une estimation réaliste de l'effort restant qui rendait l'ensemble désespéré. L'analyse sémantique complète d'Ada 83, ce n'est pas un week-end. La généricité. Les tâches. Les clauses de représentation. Le modèle de compilation séparée, qui en Ada 83 est véritablement subtil. La génération de code pour tout cela. Plusieurs cibles.

Je suis une personne. J'ai un métier : j'enseigne à l'Université de Bretagne Occidentale, à Brest, où je suis depuis ma thèse. Cela n'allait jamais être terminé.

Puis les modèles d'IA sont devenus assez bons.

TLALOC tel qu'il existe aujourd'hui — trente-quatre mille lignes, un analyseur sémantique en vingt-huit sous-unités, un expander fonctionnel, une machine à pile portée sur trois architectures — est le produit de deux années de collaboration entre un être humain et une machine. D'abord ChatGPT, puis Claude. Et je veux être précis sur ce qu'est réellement cette collaboration, parce que les récits populaires se trompent dans les deux sens.

Ce n'est pas la machine qui écrit mon compilateur. Un LLM à qui l'on demande « écris un compilateur Ada 83 » produit des âneries assurées. Chaque décision architecturale de TLALOC est la mienne. Le choix de DIANA, la structure en phases, la machine à pile LLIR, la stratégie fasmg, le jugement sur ce qu'Ada 83 *est* — rien de tout cela ne vient d'un modèle, et rien de tout cela ne le pouvait. Le modèle ne sait pas que la richesse d'Ada 95 est un piège de conception. Il n'a pas passé quarante ans à le découvrir.

Et ce n'est pas non plus moi utilisant simplement un outil. Cette description est trop petite. Ce qui s'est réellement produit, c'est qu'une classe de travail *dans ma compétence mais au-delà de ma capacité* — le labeur vaste, exigeant et ingrat consistant à implémenter une norme de langage complètement et correctement — est devenue atteignable. Je sais ce qu'il faut construire et pourquoi. La machine peut en construire une grande partie, vite, sous ma direction, sous ma relecture. C'est ce qui ressemble le plus, dans mon expérience, au fait d'avoir une équipe.

TLALOC signifie **The Lonesome Ada Loving Ol'timer's Compiler**, et le nom était une plaisanterie sur la solitude qui a étrangement vieilli. Les forums Ada m'envoient des petits cœurs. La communauté est chaleureuse, elle est petite, et elle n'écrit pas, en pratique, ce compilateur avec moi. Mon seul associé actif n'est pas humain.

Je ne crois pas que ce soit une histoire triste. Je crois que c'est un avant-goût.

Il existe toute une catégorie de logiciels qui devraient exister et n'existent pas : le compilateur du langage mort, l'émulateur de la machine oubliée, la réimplémentation du système dont les sources sont perdues, l'outil qui servirait quatre cents personnes. Ce travail a toujours été techniquement possible et économiquement absurde — l'effort est énorme, l'audience minuscule, donc cela ne se fait pas, et les artefacts disparaissent. Ce qui a changé, c'est l'arithmétique. Une seule personne motivée qui *sait ce que l'artefact doit être* peut désormais le construire.

La préservation de l'histoire informatique a été, jusqu'ici, largement une affaire d'archivage de ce qu'un autre avait déjà bâti. Il devient possible de *rebâtir*. C'est autre chose, et je crois que nous n'avons pas commencé à en mesurer la portée.

---

## Ce qu'est TLALOC, concrètement

Un compilateur Ada 83 complet pour Linux, implémentant MIL-STD-1815A-1983.

La chaîne est honnête quant à ses phases, et l'on peut l'arrêter à chacune d'elles :

```
Source (.ada)
     ↓
 PAR_PHASE     analyse lexicale et syntaxique
     ↓
 LIB_PHASE     gestion de bibliothèque et dépendances
     ↓
 SEM_PHASE     analyse sémantique  (28 sous-unités, ~65 % du compilateur)
     ↓
 EXPANDER      abaissement vers LLIR, émission d'assembleur FASM
     ↓
 fasmg    →    exécutable ELF-64
```

Environ 34 000 lignes réparties sur 82 fichiers. Ada 83 dans son intégralité : compilation séparée, généricité et instanciation, tâches, clauses de représentation. Rien d'Ada 95 ou postérieur — délibérément, définitivement, par conception. Le graphe DIANA peut être vidangé et affiché lisiblement à chaque frontière de phase, ce qui est soit une commodité de débogage, soit le cœur du sujet, selon la raison pour laquelle vous le lisez.

Il se construit avec GNAT. x86-64 est la cible de référence et testée ; aarch64 et RISC-V 64 sont portés via la machine à pile LLIR mais pas encore validés.

Sous licence GPL-3.0-or-later, et public :

- **Dépôt** : https://github.com/ViMoBr/Ada83_TLALOC
- **Miroir** : https://framagit.org/VMo/ada-83-compiler-tools
- **Ressources Ada 83** : https://ada83.org

---

## Pourquoi cela pourrait vous concerner

**Si vous enseignez la compilation** : vous enseignez très probablement à partir de langages jouets, parce que les vrais compilateurs sont illisibles et que les compilateurs lisibles ne sont pas de vrais compilateurs. TLALOC est une implémentation authentique et complète d'un langage industriel substantiel, avec une séparation nette des phases et une RI normalisée inspectable à chaque frontière. Je serais heureux de le voir servir dans l'enseignement, et je le dis en tant que quelqu'un qui a passé sa carrière à l'université.

**Si la conception des langages vous intéresse** : la transition Ada 83 → Ada 95 est l'une des meilleures expériences naturelles dont nous disposions pour savoir si ajouter de la puissance expressive à un langage améliore les systèmes qu'on bâtit avec. J'ai mené cette expérience quatre fois sur le même système, et ma réponse est non. Contredisez-moi.

**Si vous travaillez sur les compilateurs** : DIANA est un chemin non emprunté — une RI attribuée, publiée, normalisée, structurée en graphe, pensée pour l'interopérabilité entre outils. Savoir si c'était une bonne idée est une question vivante, et il n'y avait plus, depuis longtemps, d'implémentation fonctionnelle pour en débattre. Il y en a une.

**Si le sort du logiciel vous importe** : un langage est mort et ses implémentations avec lui, et la norme est restée, document décrivant une chose qui n'existait plus. C'est le destin ordinaire des artefacts informatiques. Ce n'était pas une fatalité, et pour celui-ci, désormais, ce n'en est plus une.

---

## Coda

Il y a quarante ans, j'ai écrit un programme dans un langage pour lequel il m'a fallu plaider afin d'avoir le droit de m'en servir. Le papier sur lequel il fut imprimé a survécu. Le langage a survécu, sur papier, comme une norme que plus personne n'implémentait.

Tous les deux tournent à nouveau.

TLALOC est un compilateur pour un langage mort, écrit par un homme et une machine, dans une petite ville de la côte atlantique bretonne, sans autre raison que le fait qu'il devrait exister et que personne d'autre n'allait le construire.

Cela se révèle une raison suffisante.

---

*Vincent Morin — Université de Bretagne Occidentale, Brest*
*TLALOC — The Lonesome Ada Loving Ol'timer's Compiler*
