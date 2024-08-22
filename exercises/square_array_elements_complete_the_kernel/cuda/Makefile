#----------------------------------------

HIPCC    = hipcc
HIPFLAGS = --offload-arch=gfx908

#----------------------------------------

square_array_elements: square_array_elements.o
	${HIPCC} ${HIPFLAGS} square_array_elements.o -o square_array_elements

square_array_elements.o: square_array_elements.cu
	${HIPCC} ${HIPFLAGS} -c square_array_elements.cu

.PHONY: clean

clean:
	rm -f square_array_elements *.o
