#----------------------------------------

FC    = ftn
FFLAGS = -fopenmp -hacc

#----------------------------------------

average_array_elements: average_array_elements.o
	${FC} ${FFLAGS} average_array_elements.o -o average_array_elements

average_array_elements.o: average_array_elements.f90
	${FC} ${FFLAGS} -c average_array_elements.f90

.PHONY: clean

clean:
	rm -f average_array_elements *.o
