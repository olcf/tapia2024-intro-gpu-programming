#----------------------------------------

CC    = cc
CFLAGS = -fopenmp

#----------------------------------------

vector_addition: vector_addition.o
	${CC} ${CFLAGS} vector_addition.o -o vector_addition

vector_addition.o: vector_addition.c
	${CC} ${CFLAGS} -c vector_addition.c

.PHONY: clean

clean:
	rm -f vector_addition *.o
