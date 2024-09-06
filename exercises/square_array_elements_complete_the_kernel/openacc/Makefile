#----------------------------------------

FC    = ftn
FFLAGS = -fopenmp -hacc

#----------------------------------------

square_array_elements: square_array_elements.o
	${FC} ${FFLAGS} square_array_elements.o -o square_array_elements

square_array_elements.o: square_array_elements.f90
	${FC} ${FFLAGS} -c square_array_elements.f90

.PHONY: clean

clean:
	rm -f square_array_elements *.o
