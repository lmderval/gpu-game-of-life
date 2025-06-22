#include <cstdio>

#include "game_of_life.hh"

static __global__ void _device_hello()
{
    printf("Hello CUDA!\n");
}

void hello()
{
    _device_hello<<<1, 1>>>();
    cudaDeviceSynchronize();
}
