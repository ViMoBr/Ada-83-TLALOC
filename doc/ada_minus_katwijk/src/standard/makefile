SHELL	= /bin/sh
LIB	= /home/adacomp/lib
B	= /bin/cp
A	= /bin/cat
F	= ada_front
CG	= ada_cg

all:	std.a std_ps.t

std_ps.o:	std_ps.s
	cp std_ps.s std_ps.o

std_ps.s:	std_ps.p
	cat < std_ps.p > std_ps.s

std_ps.t std_ps.p:	std_ps.ada
	-${LIB}/${F}  -n std_ps.ada
	-${LIB}/${CG} std_ps.t std_ps.p 2 std_ps.f

std_pb.o:	std_pb.c
	cc -c std_pb.c

cleanup:
	rm -f std_ps.s std_ps.p std_ps.t std_ps.f std_ps.o std.a

install:	all
	cp std.a ${LIB}/std.a
	cp std_ps.t ${LIB}/std_ps.t
	cp std_ps.o ${LIB}/std_ps.o

std.a:	std_ps.o 
	ar r std.a std_ps.o
