CXX = icc
CXXFLAGS = -O3 -Wall
CXXFLAGS3 = -O3 
TARGET1= dp_openmp

all : $(TARGET1)
    
$(TARGET1) : dp_openmp.c kernel_openmp.c kernel_openmp.h
	$(CXX) $(CXXFLAGS) -o $(TARGET1) dp_openmp.c kernel_openmp.c -lm -fopenmp
clean : 
	rm -f $(TARGET1)
