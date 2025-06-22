#include <cstdio>

#include "game_of_life.hh"

GameOfLife::GameOfLife(std::size_t size)
    : size_(size)
    , grid_(nullptr)
{
    cudaMallocManaged(&grid_, size * size * sizeof(int));
    reset();
}

GameOfLife::~GameOfLife()
{
    cudaFree(grid_);
}

static __global__ void _device_reset(int* grid, std::size_t size)
{
    std::size_t i = threadIdx.x + blockIdx.x * blockDim.x;
    std::size_t j = threadIdx.y + blockIdx.y * blockDim.y;
    if (i < size && j < size)
    {
        grid[j + i * size] = 0;
    }
}

void GameOfLife::reset()
{
    dim3 block_size(8, 8);
    dim3 grid_size = ({
        int gx = (size_ + block_size.x) / block_size.x;
        int gy = (size_ + block_size.y) / block_size.y;
        dim3(gx, gy);
    });

    _device_reset<<<grid_size, block_size>>>(grid_, size_);
}
