#----------------------------------------

CC    = cc
CFLAGS = -fopenmp

#----------------------------------------

average_array_elements: average_array_elements.o
	${CC} ${CFLAGS} average_array_elements.o -o average_array_elements

average_array_elements.o: average_array_elements.c
	${CC} ${CFLAGS} -c average_array_elements.c

.PHONY: clean

clean:
	rm -f average_array_elements *.o
