# makefile for formatting the symbolic debugger manual

PARTS =  p1 p2 p3 p4 p5

PAGES = after.nr all.nr break.nr calls.nr cat.nr cont.nr context.nr \
	controls.nr delete.nr exit.nr help.nr exception.nr kill.nr last.nr\
	lines.nr list.nr menu.nr print.nr quit.nr return.nr run.nr \
	show.nr stack.nr step.nr trace.nr use.nr with.nr 

all	:	manual pages

manual	:	 front $(PARTS) $(PAGES) eind
	nroff -rB1 -mm macros $(PARTS) $(PAGES) eind > /tmp/manual
	cat front /tmp/manual > manual

front	:	titlepg
	nroff -mm titlepg > front

pages	:	${PAGES}
	make_pages $?
	touch pages

