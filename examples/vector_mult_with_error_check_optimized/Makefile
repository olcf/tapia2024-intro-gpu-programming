#----------------------------------------

CC    = cc
CFLAGS = -fopenmp

#----------------------------------------

vector_mult: vector_mult.o
	${CC}  ${CFLAGS} vector_mult.o -o vector_mult

vector_mult.o: vector_mult.c
	${CC}  ${CFLAGS} -c vector_mult.c

.PHONY: clean

clean:
	rm -f vector_mult *.o
