CFLAGS=-O
install:	cgyacc
	cp cgyacc /usr/bin/tud/cgyacc
	:

cgyacc: y1.o y2.o y3.o y4.o y5.o y6.o y7.o y8.o
	cc -i -s -o cgyacc y1.o y2.o y3.o y4.o y5.o y6.o y7.o y8.o

y1.o y2.o y3.o y4.o y5.o y6.o y7.o y8.o: dextern files
y2.o y5.o y6.o: prep.h
