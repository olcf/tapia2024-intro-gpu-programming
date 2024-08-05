#----------------------------------------

HIPCC    = hipcc
HIPFLAGS = --amdgpu-target=gfx908

#----------------------------------------

square_array_elements_solution: square_array_elements_solution.o
	${HIPCC} ${HIPFLAGS} square_array_elements_solution.o -o square_array_elements_solution 

square_array_elements_solution.o: square_array_elements_solution.cu
	${HIPCC} ${HIPFLAGS} -c square_array_elements_solution.cu

.PHONY: clean

clean:
	rm -f square_array_elements_solution *.o
