# TLALOC — Textes d'annonce par plateforme

**Principe général** : ne pas tout poster le même jour. Commencer par la communauté Ada (accueil garanti, retours utiles, premiers témoins), puis élargir. Chaque annonce pointe vers le write-up, qui est la pièce durable ; les posts sont jetables, le write-up ne l'est pas.

**Ordre recommandé** :
1. Publier le write-up quelque part de stable (ada83.org, ou une page du dépôt)
2. J+0 : comp.lang.ada et forum.ada-lang.io
3. J+3 à J+7 : Hacker News (un mardi/mercredi matin heure US), puis r/compilers et r/programminglanguages
4. En parallèle : Software Heritage + Zenodo (préservation, indépendant du buzz)

---

## 1. comp.lang.ada

*Registre : technique, direct, sans emphase. Ce public connaît Ada 83 et n'a pas besoin qu'on lui vende le langage. Il veut savoir ce qui est implémenté et ce qui ne l'est pas.*

**Sujet** : `TLALOC: a complete Ada 83 compiler (DIANA front end + FASM back end)`

---

I have been working on an Ada 83 compiler and it now produces working ELF-64 executables. I am posting it here first because this group is where it will mean something.

**TLALOC** — The Lonesome Ada Loving Ol'timer's Compiler — implements MIL-STD-1815A-1983. Not a subset, and deliberately nothing from Ada 95 or later.

Origins: the front end began as fragments I found in the Ada Software Repository (Pine Creek CD-ROM), from a Peregrine Systems project led by Bill Easton that ran 1988-1993, targeting DIANA with phases as separate executables. From 2005 I rewrote and integrated it, keeping the strict phase separation but rationalizing the architecture and rebuilding the internal DIANA graph structures. By 2018 the front end was complete — and had no back end, which is where Ada projects traditionally die.

The unlock was fasmg. Emitting text assembly and letting the Flat Assembler engine produce the ELF meant I did not have to write an object writer and linker before seeing an instruction run. Between DIANA and the assembler sits LLIR, a stack-machine IR that makes retargeting a matter of porting the machine rather than re-lowering the language.

Current state, precisely:

- Full Ada 83: separate compilation, generics and instantiation, tasking, representation clauses
- ~34,000 lines, 82 files; SEM_PHASE is 28 subunits and ~65% of the compiler
- **x86-64 is the reference and tested target**
- aarch64: ported, ran once, not currently exercised
- RISC-V 64: ported, not yet validated
- Built with GNAT 13.3; runs on Linux
- GPL-3.0-or-later

The DIANA graph can be dumped and pretty-printed at every phase boundary, which makes the compiler unusually inspectable — I think it is more readable than most modern compilers, and that is by design rather than by accident.

Repository: https://github.com/ViMoBr/Ada83_TLALOC
Mirror: https://framagit.org/VMo/ada-83-compiler-tools
Longer write-up (including why I think Ada 83 is a better design language than Ada 95, which I expect some of you will want to argue about): [LIEN]

I should be transparent about one thing: this was built by one person working with AI assistance, which is the only reason a project of this size was achievable alongside a university job. Every architectural decision is mine; a great deal of the implementation labor was not done alone.

Bug reports welcome. Ada 83 test programs especially welcome — validation is where I most need help.

Vincent Morin
Université de Bretagne Occidentale, Brest

---

## 2. forum.ada-lang.io

*Registre : plus chaleureux, plus narratif. Ce forum vous connaît déjà et vous envoie des cœurs. On peut assumer le récit.*

**Titre** : `TLALOC — an Ada 83 compiler that produces real executables`

---

Some of you have seen me mention this. It works now, so here it is properly.

**TLALOC** (The Lonesome Ada Loving Ol'timer's Compiler) is a complete Ada 83 compiler — MIL-STD-1815A-1983, nothing later — that takes Ada source through a DIANA front end, an LLIR stack machine, and FASM assembly, and produces ELF-64 executables on Linux.

The story is a long one and I have written it up properly here: [LIEN]

The short version:

In 2024 I found a paper listing of a program I wrote in Ada 83 in 1988, during my thesis. I scanned it, ran OCR on it, and fed it to GNAT with `-gnat83`. It compiled. Almost unmodified. A program from thirty-six years ago, reconstructed from a photograph of paper, built and ran.

That is not a thing you can say about very many languages, and it is a large part of why I think letting Ada 83 become a standard with no living implementation would be a genuine loss rather than a sentimental one.

The front end has been in progress since 2005 — a rewrite and integration of DIANA-targeting fragments I found in the old Ada Software Repository, from a Peregrine Systems project (Bill Easton, 1988-1993). By 2018 it was complete and could not emit a single instruction. Back ends are where hobby compilers die; there was a Polish Ada effort with an expander by Michał Cierniak that did not survive that gap.

fasmg broke it open, and then AI assistance made the remaining mountain of semantic analysis and code generation actually achievable for one person with a day job. I want to be honest about that rather than quiet about it.

Where it stands:
- Full Ada 83 including generics, tasking, representation clauses, separate compilation
- x86-64 is the tested reference target; aarch64 and RISC-V 64 are ported but not validated
- ~34,000 lines, GPL-3.0-or-later

https://github.com/ViMoBr/Ada83_TLALOC

If anyone has Ada 83 code lying around — especially anything old and gnarly — I would love to try compiling it. Validation is the thing I need most.

---

## 3. Hacker News

*Registre : le titre fait 80 % du travail. Factuel, technique, aucune emphase, aucun adjectif. Le texte du commentaire d'accompagnement (à poster vous-même immédiatement après la soumission) porte le récit.*

**Titre de soumission** (choisir UN) :

- `TLALOC: A complete Ada 83 compiler built with a DIANA intermediate representation`
- `I rebuilt an Ada 83 compiler from a 1990s front end I found on a CD-ROM`
- `Show HN: TLALOC – an Ada 83 compiler (DIANA IR, FASM back end)`

*Le deuxième est le plus fort en potentiel de front page mais engage sur le récit ; le premier est le plus sûr. "Show HN" est approprié puisque c'est votre travail.*

**URL** : le write-up (pas le dépôt — le write-up renvoie au dépôt, et il donne à HN quelque chose à lire et à commenter).

**Premier commentaire, à poster immédiatement après la soumission** :

---

Author here.

Short version of how this happened: in 2024 I found a paper listing of a program I wrote in Ada 83 in 1988. Scanned it, OCR'd it, fed it to GNAT with `-gnat83`. It compiled almost unmodified and ran. Thirty-six years, reconstructed from a photograph of paper, no dependency archaeology required.

That got me thinking about the fact that Ada 83 was becoming a standard with no living implementation — a document describing something that no longer existed.

The front end has a strange provenance. I found fragments of a DIANA-targeting Ada 83 front end in the old Ada Software Repository CD-ROMs, from a Peregrine Systems project that ran 1988-1993. I rewrote and integrated it starting in 2005, and by 2018 had a complete front end that could not emit a single instruction. Back ends are where these projects die.

Two things unlocked it. First, fasmg — emitting text assembly and letting the Flat Assembler engine make the ELF, rather than writing an object emitter and linker first. Second, and I would rather say this plainly than have people guess: AI assistance. I am one person with a university teaching job, and the remaining work — full Ada 83 semantic analysis, generics, tasking, representation clauses, code generation — was within my competence but far beyond my capacity. Every architectural decision is mine. A large fraction of the implementation labor was not done by me alone.

I think that combination is going to matter well beyond this project. There is a whole category of software that *should* exist and doesn't — the compiler for the dead language, the emulator for the forgotten machine — because the effort is enormous and the audience is four hundred people. The economics of that just changed.

Happy to go deep on DIANA, which is genuinely a road not taken in IR design: a *published, standardized* attributed graph IR intended for tool interoperability, rather than a bespoke internal representation. Also happy to argue about my claim that Ada 83 is a better design language than Ada 95, which I arrived at by writing the same operating system four times.

x86-64 is the tested target. aarch64 and RISC-V 64 are ported through the LLIR stack machine but not validated — I would rather say that than overclaim.

---

## 4. r/compilers et r/programminglanguages

*Registre : technique, curieux, pas de marketing. Ce public veut les choix d'architecture. Poster dans les deux, en adaptant légèrement — r/programminglanguages est plus réceptif à la thèse Ada 83 vs Ada 95, r/compilers à DIANA et au backend.*

**Titre (r/compilers)** : `TLALOC: a complete Ada 83 compiler using DIANA (a standardized graph IR from 1983) and a stack-machine backend`

**Titre (r/programminglanguages)** : `I wrote the same OS four times in four languages, concluded Ada 83 beats Ada 95, and then built a compiler for it`

**Corps (adapter l'accroche selon le sub)** :

---

TLALOC is a complete Ada 83 compiler — MIL-STD-1815A-1983, deliberately nothing from Ada 95 or later. It produces ELF-64 executables on Linux.

The architecturally interesting part is **DIANA**.

DIANA (Descriptive Intermediate Attributed Notation for Ada) is a standardized, graph-structured, attributed IR designed for Ada in the early 1980s. It is not an AST. Nodes are language constructs, attributes carry semantic information, and the graph captures the full dependency structure including separate-compilation relationships. Crucially it was designed as a *published standard* — an interchange format so that multiple Ada tools could operate on a shared program representation.

That is the opposite of the modern bet. Contemporary compilers build bespoke IRs, lower aggressively, and treat the intermediate form as an implementation detail. DIANA treated it as a first-class, standardized artifact.

For a compiler where legibility is a goal rather than an afterthought, this turns out extremely well. The DIANA graph can be dumped and pretty-printed at every phase boundary. The phases are real — separate, with honest contracts:

```
Source → PAR_PHASE → LIB_PHASE → SEM_PHASE → EXPANDER → fasmg → ELF
                                  (28 subunits,
                                   ~65% of compiler)
```

Below DIANA sits LLIR, a stack-machine IR. Ada semantics are lowered onto the abstract stack machine once; retargeting means porting the machine rather than re-lowering the language. x86-64 is the tested reference; aarch64 and RISC-V 64 are ported but not yet validated.

The back end uses **fasmg** (the Flat Assembler macro engine) rather than emitting objects directly. This is a pragmatic choice I would recommend to anyone building a compiler alone: emitting text assembly and letting a mature assembler produce the ELF removes an enormous amount of work between "I have an IR" and "I have a running program." The gap between a finished front end and a first executable is where solo compiler projects go to die.

Provenance is unusual: the front end started from fragments I found in the old Ada Software Repository CD-ROMs, from a Peregrine Systems project (1988-1993) that targeted DIANA with phases as separate executables. I rewrote and integrated it from 2005 onward. ~34,000 lines now.

Two claims I am happy to defend in the comments:

1. **DIANA deserves reconsideration.** A standardized graph IR for tool interoperability is a design point nobody occupies anymore, and there has not been a working implementation to argue about in decades.

2. **Ada 83 is a better design language than Ada 95.** I did not get here from theory. I have written the same operating system (a Macintosh-System-alike) four times — Pascal, C, Ada 95, Ada 83. The Ada 95 version went conceptually insane: every additional feature is an additional axis of possible decomposition, and with enough axes there is no longer a right answer. The Ada 83 version is the maintainable one. Constraint is the feature.

Built by one person with substantial AI assistance, which I mention because it is the only reason the semantic analysis got finished. Architecture is mine; a lot of the implementation labor was not solo.

Full write-up: [LIEN]
Code: https://github.com/ViMoBr/Ada83_TLALOC (GPL-3.0-or-later)

---

## 5. Préservation (à faire indépendamment du buzz)

Ces trois gestes sont ce qui garantit réellement que le projet ne se perd pas. Ils ne dépendent d'aucune audience.

**Software Heritage** — https://archive.softwareheritage.org
Utiliser « Save code now » avec l'URL du dépôt GitHub. Archivage permanent, mission explicitement patrimoniale. C'est probablement le geste le plus important de toute cette liste.

**Zenodo** — https://zenodo.org
Activer l'intégration GitHub, puis créer une release. Chaque release obtient un DOI citable. C'est le pont vers la reconnaissance académique : un DOI rend TLALOC citable dans un article ou un support de cours.

**Ada Information Clearinghouse** — http://www.adaic.org/
Signaler le projet ; c'est l'organe de référence historique d'Ada.

---

## Notes de diffusion

- **Ne pas poster sur HN un vendredi ou un week-end.** Mardi ou mercredi, entre 8h et 10h heure de la côte est US (14h-16h en France), est le créneau habituel.
- **Rester disponible dans les 2-3 heures suivant un post HN.** La présence de l'auteur en commentaires est ce qui fait vivre un fil. C'est aussi ce qui distingue un projet vivant d'un lien mort.
- **Ne pas être défensif sur la question de l'IA.** Elle viendra, et votre position est solide : l'architecture est vôtre, la capacité est venue d'ailleurs, et vous le dites d'emblée. Les gens respectent ça ; ce qu'ils détectent et punissent, c'est la dissimulation.
- **La thèse Ada 83 > Ada 95 attirera des contradicteurs.** C'est souhaitable. Un fil de commentaires actif est ce qui pousse un post vers le haut, et vous avez l'argument le plus rare qui soit dans ce débat : des données expérimentales, quatre fois.
