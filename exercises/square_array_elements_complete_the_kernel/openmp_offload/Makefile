#----------------------------------------

CC    = cc
CFLAGS = -fopenmp

#----------------------------------------

square_array_elements: square_array_elements.o
	${CC} ${CFLAGS} square_array_elements.o -o square_array_elements

square_array_elements.o: square_array_elements.c
	${CC} ${CFLAGS} -c square_array_elements.c

.PHONY: clean

clean:
	rm -f square_array_elements *.o
