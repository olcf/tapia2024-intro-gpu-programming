#----------------------------------------

FC    = ftn
FFLAGS = -hacc

#----------------------------------------

vector_addition: vector_addition.o
	${FC} ${FFLAGS} vector_addition.o -o vector_addition

vector_addition.o: vector_addition.f90
	${FC} ${FFLAGS} -c vector_addition.f90

.PHONY: clean

clean:
	rm -f vector_addition *.o
