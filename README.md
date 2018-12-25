To compile a C library and link it.
clang -c myFile.c -o output.o
clang -shared -o output.dylib output.o

To use a single header file, create a file the includes and #define the 
implementation and then compile that (e.g. stb libs)
