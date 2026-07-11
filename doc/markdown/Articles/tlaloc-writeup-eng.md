# TLALOC: Building an Ada 83 Compiler, Forty Years Later

*How a rediscovered listing, a 1990s DIANA front end, a modern assembler, and an unlikely collaborator produced a complete compiler for a language the world decided to move past.*

---

## A listing that would not die

In 2024 I found a paper listing in a box.

It was a laser printout from 1988 — the source code of Sybilin, a symbolic design tool for microwave integrated circuits that I had written as a doctoral student at the CNET in Bagneux. The program computed transfer functions using Mason and Coates signal-flow graphs, a technique that was already unfashionable then. It had originally been written in FORTRAN and was, to put it charitably, unreadable. I had asked for permission to rewrite it in Ada 83 on a MicroVAX, and I had gotten it.

I scanned the listing. I ran it through OCR. And then, mostly out of curiosity, I fed the result to GNAT with `-gnat83`.

It compiled. Almost without modification.

A program written in 1988, printed on paper, forgotten for thirty-six years, reconstructed from an optical scan — and it built and ran on a 2026 Linux machine. No dependency hell. No deprecated APIs. No framework churn. The language had simply stayed still, and everything I had written on top of it had stayed standing.

That is not nostalgia talking. That is a fact about Ada 83 that I think the software industry has never properly reckoned with, and it is a large part of why I spent the next two years building a compiler for it.

---

## The case for a dead standard

Ada 83 — formally MIL-STD-1815A-1983 — is remembered, when it is remembered at all, as a Pentagon procurement mandate. Heavy. Verbose. Imposed. The language you were forced to use.

I have used Ada continuously since 1985, through every revision, and I have come to a heterodox conclusion: **Ada 83 was the best version of Ada, and each subsequent revision made it worse as a design language.**

I did not arrive at this from theory. I arrived at it from failure.

For years I have been rebuilding, as a side obsession, an operating system in the spirit of the original Macintosh System — a project I call Kalinda. The original Mac OS remains, to my mind, one of the most coherent pieces of system software ever shipped, and I wanted to understand it by reconstructing it with better tools.

I have written Kalinda four times.

The first was in Pascal under CodeWarrior on a Macintosh LC III. It got remarkably far and then collapsed under its own weight — unmaintainable.

The second attempt was in C. I abandoned it quickly. From a software-engineering standpoint it was simply appalling; the language offered no help in holding a large architecture together.

The third was in Ada 95. This one is the interesting failure. Ada 95 is a *better language* than Ada 83 by most conventional measures — tagged types, child packages, protected objects, a richer type system. And the design went conceptually insane. Every additional feature was an additional axis along which the architecture could be decomposed, and with enough axes, there is no longer a right answer. I found myself designing the design instead of designing the system. The richness that was supposed to help me was drowning the structural clarity of what I was building.

The fourth attempt is in Ada 83. It is the most maintainable version I have ever had, and it is the one that lives.

This is the thing I want to say plainly, because it cuts against the entire direction of language evolution: **Ada 9X and Ada 2X are, in an important sense, a deviation.** They are richer. They are more expressive. And they are more expressive in ways that are not indispensable, and that blur the architectural conception of a system rather than sharpening it. Ada 83 has a *small* set of powerful structuring constructs — packages, strong typing, generics, tasking, exceptions — and precisely because the set is small, it forces the architecture to be right rather than clever.

Constraint is not a limitation of Ada 83. It is the feature.

And if that is true, then letting Ada 83 die — letting it become a standard with no living implementation, readable only as a PDF — would be a real loss. Not a sentimental one. A technical one.

That is what TLALOC exists to prevent.

---

## Finding the front end

Somewhere in my Ada practice, I stumbled across something in the Ada Software Repository — the Pine Creek CD-ROM distribution, an artifact of a time when software was archived on physical media by people who understood that archiving mattered.

Buried in it were fragments of an Ada 83 front end targeting DIANA, from a Peregrine Systems project led by Bill Easton that ran from 1988 to 1993. The phases had been built as separate executables. It appeared to have been compiled under DEC Ada. It was incomplete, it was a set of pieces rather than a working whole, and it was unmistakably the skeleton of something serious.

A word about DIANA, because it is the reason this skeleton was worth resurrecting.

**DIANA** — Descriptive Intermediate Attributed Notation for Ada — is a standardized graph-structured intermediate representation designed specifically for Ada in the early 1980s. It is not an AST in the modern sense. It is an attributed graph: nodes represent language constructs, attributes carry semantic information, and the structure captures the full dependency web of a program including its separate-compilation relationships. It was designed as a *shared* format, so that many Ada tools could interoperate on a common representation of a program.

DIANA has been almost entirely forgotten. Modern compilers build bespoke IRs, lower aggressively, and treat the intermediate form as an implementation detail. DIANA was the opposite bet: the intermediate form as a *published standard*, an interchange format, a first-class artifact.

For a compiler whose purpose is preservation and legibility, that bet turns out to be exactly right.

From 2005 onward, I undertook a complete rewrite and integration of that front end. I kept the strict phase separation — it is one of the best ideas in the original design — but I rationalized the architecture and rebuilt the internal data structures of the DIANA graphs from the ground up.

By around 2018 I had a complete Ada 83 front end producing DIANA. Parsing, library management, full semantic analysis. And I will say something immodest, because I believe it is true and because it is the single strongest reason for anyone else to care about this codebase: **I do not know of a modern compiler whose architecture is as clean and as readable as this one.** The phase boundaries are real. Each phase has an honest, stateable contract. You can read it.

And it could not produce a single executable.

---

## The wall every hobby compiler dies against

A front end that produces a beautiful intermediate representation and no machine code is a very elaborate way of confirming that your program parses.

The back end is where amateur compiler projects go to die, and I mean that with specificity: there was a Polish Ada compiler effort in which Michał Cierniak wrote the beginnings of an expander. It did not survive the gap between DIANA and running code. That gap has killed more Ada projects than any other single obstacle, and I had every reason to expect it would kill mine.

The idea that broke it open was **fasmg**.

fasmg — the macro-assembler engine of the Flat Assembler family — is a programmable assembly engine, which meant I did not need to construct an object-file writer, a relocation engine, and an ELF linker before I could see my first instruction execute. I could emit *text*, and let a mature, fast, well-tested tool turn it into an ELF binary.

Within weeks, this appeared:

```
$ ./DIS_BONJOUR
 Bonjour
```

A French "hello, world" — from Ada 83 source, through my parser, through my library phase, through my semantic analyzer, through DIANA, through my expander, into FASM assembly, into an ELF-64 executable, running on Linux.

That output is roughly the least impressive thing a computer can print. It was, for me, the moment the project stopped being a dream and became an engineering problem.

Between DIANA and the assembler sits **LLIR**, a low-level intermediate representation organized as a stack machine. This is the layer that makes portability tractable: the semantics of Ada are lowered onto an abstract stack machine once, and each new target architecture requires porting the stack machine rather than re-lowering the language.

To be precise about where this stands, because the distinction matters: **x86-64 is the reference target** — it is the one that is exercised, tested, and trusted. aarch64 has been ported and has run, once, some time ago. RISC-V 64 is ported but not yet validated. The stack-machine design is the bet that these ports are cheap; x86-64 is the evidence that the pipeline works.

---

## The part where I stop being alone

Here is the honest accounting.

At the beginning of 2024 I had: a complete, clean Ada 83 front end representing nearly two decades of work, a proof of concept that fasmg could close the back-end gap, and a realistic estimate of the remaining effort that made the whole thing hopeless. Full semantic analysis for Ada 83 is not a weekend. Generics. Tasking. Representation clauses. The separate compilation model, which in Ada 83 is genuinely intricate. Code generation for all of it. Multiple targets.

I am one person. I have a day job — I teach at the Université de Bretagne Occidentale in Brest, where I have been since finishing my thesis. This was never going to be finished.

Then the AI models became good enough.

TLALOC as it exists today — thirty-four thousand lines, a semantic analyzer in twenty-eight subunits, a working expander, a stack machine ported to three architectures — is the product of a two-year collaboration between one human being and a machine. First ChatGPT, then Claude. And I want to be precise about what that collaboration actually is, because the popular accounts get it wrong in both directions.

It is not the machine writing my compiler. An LLM asked to "write an Ada 83 compiler" produces confident garbage. Every architectural decision in TLALOC is mine. The choice of DIANA, the phase structure, the LLIR stack machine, the fasmg strategy, the judgment about what Ada 83 *is* — none of that came from a model, and none of it could have. The model does not know that Ada 95's richness is a design trap. It has not spent forty years finding out.

And it is not me merely using a tool, either. That description is too small. What actually happened is that a class of work that was *within my competence but beyond my capacity* — the vast, exacting, unglamorous labor of implementing a language standard completely and correctly — became achievable. I know what needs to be built and why. The machine can build a great deal of it, at speed, under my direction, with my review. It is the closest thing I have experienced to having a team.

TLALOC stands for **The Lonesome Ada Loving Ol'timer's Compiler**, and the name was a joke about solitude that has aged strangely. The Ada forums send me hearts. The community is warm and it is small and it is not, in any practical sense, writing this compiler with me. My only active collaborator is not human.

I do not think this is a sad story. I think it is a preview.

There is an entire category of software that ought to exist and does not: the compiler for the dead language, the emulator for the forgotten machine, the reimplementation of the system whose source was lost, the tool that would serve four hundred people. This work has always been technically possible and economically absurd — the effort is enormous and the audience is small, so it does not get done, and the artifacts vanish. What has changed is the arithmetic. A single motivated person who *knows what the artifact should be* can now build it.

The preservation of computing history has been, until now, largely a matter of archiving what someone else already built. It is becoming possible to *rebuild*. That is a different thing, and I think we have not begun to grasp what it means.

---

## What TLALOC is, concretely

A complete Ada 83 compiler for Linux, implementing MIL-STD-1815A-1983.

The pipeline is honest about its phases, and you can stop it at any of them:

```
Source (.ada)
     ↓
 PAR_PHASE     lexical and syntactic analysis
     ↓
 LIB_PHASE     library and dependency management
     ↓
 SEM_PHASE     semantic analysis  (28 subunits, ~65% of the compiler)
     ↓
 EXPANDER      lowering to LLIR, emission of FASM assembly
     ↓
 fasmg    →    ELF-64 executable
```

Roughly 34,000 lines across 82 files. Ada 83 in full: separate compilation, generics and instantiation, tasking, representation clauses. Nothing from Ada 95 or later — deliberately, permanently, and by design. The DIANA graph can be dumped and pretty-printed at any phase boundary, which is either a debugging convenience or the entire point, depending on why you are reading it.

It is built with GNAT. x86-64 is the reference and tested target; aarch64 and RISC-V 64 are ported via the LLIR stack machine but not yet validated.

It is GPL-3.0-or-later, and it is public:

- **Repository**: https://github.com/ViMoBr/Ada83_TLALOC
- **Mirror**: https://framagit.org/VMo/ada-83-compiler-tools
- **Ada 83 resources**: https://ada83.org

---

## Why you might care, depending on who you are

**If you teach compilers**: you have almost certainly been teaching from toy languages, because real compilers are unreadable and readable compilers are not real. TLALOC is a genuine, complete implementation of a substantial industrial language with clean phase separation and a standardized IR you can inspect at every boundary. I would be delighted to see it used in teaching, and I say that as someone who has spent his career in a university.

**If you care about language design**: the Ada 83 → Ada 95 transition is one of the best natural experiments we have in whether adding expressive power to a language improves the systems built with it. I have run that experiment on the same system four times, and my answer is no. Argue with me.

**If you work on compilers**: DIANA is a road not taken — a published, standardized, graph-structured attributed IR intended for tool interoperability. Whether it was a good idea is a live question, and there has not been a working implementation to argue about in a long time. Now there is one.

**If you care about what happens to software**: a language died and its implementations went with it, and the standard remained as a document describing something that no longer existed. That is the normal fate of computing artifacts. It did not have to be, and now, for this one, it is not.

---

## Coda

Forty years ago I wrote a program in a language I had to argue for permission to use. The paper it was printed on survived. The language survived, on paper, as a standard nobody implemented anymore.

Both of them run again.

TLALOC is a compiler for a dead language, written by one man and one machine, in a small city on the Atlantic coast of Brittany, for no reason at all except that it should exist and nobody else was going to build it.

That turns out to be reason enough.

---

*Vincent Morin — Université de Bretagne Occidentale, Brest*
*TLALOC — The Lonesome Ada Loving Ol'timer's Compiler*
