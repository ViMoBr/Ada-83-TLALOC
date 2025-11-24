#ms68
#19880715/wjvg

s68:	c.o d.o def68.o defs68.o hnode.o hsize.o i.o m.o o.o opz.o p.o \
	  s.o x68z.o extra.o \
	dupstr.o	\
	roct.o		\
	index.o		\
	rdec.o		\
	rdecl.o		\
	eopti.o		\
	eopen.o		\
	enuexp.o
	ld /lib/ldfile -e start \
	  c.o d.o def68.o defs68.o hnode.o hsize.o i.o m.o o.o opz.o p.o \
	  s.o x68z.o extra.o \
	dupstr.o	\
	roct.o		\
	index.o		\
	rdec.o		\
	rdecl.o		\
	eopti.o		\
	eopen.o		\
	enuexp.o	\
	   -lc -o s68
.c.o:
	cc -c -Df68000 -Don68000 $*.c

install:	s68
	cp s68 /usr/bin/tud

#end
