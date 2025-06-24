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

static __device__ unsigned char _device_alive_neighbours(int* grid,
                                                         std::size_t x,
                                                         std::size_t y,
                                                         std::size_t size)
{
    std::size_t lx = (x ?: size) - 1;
    std::size_t ly = (y ?: size) - 1;
    std::size_t hx = size == x + 1 ? 0 : x + 1;
    std::size_t hy = size == y + 1 ? 0 : y + 1;
    return grid[ly + lx * size] + grid[ly + x * size] + grid[ly + hx * size]
        + grid[y + lx * size] + grid[y + hx * size] + grid[hy + lx * size]
        + grid[hy + x * size] + grid[hy + hx * size];
}

static __global__ void _device_step(int* grid, std::size_t size)
{
    std::size_t i = threadIdx.x + blockIdx.x * blockDim.x;
    std::size_t j = threadIdx.y + blockIdx.y * blockDim.y;
    bool alive = 0;
    if (i < size && j < size)
    {
        unsigned char alive_neighbours =
            _device_alive_neighbours(grid, i, j, size);
        if (alive_neighbours == 3)
        {
            alive = 1;
        }
        else if (alive_neighbours < 2 || alive_neighbours > 3)
        {
            alive = 0;
        }
        else
        {
            alive = grid[j + i * size];
        }
    }

    __syncthreads();

    if (i < size && j < size)
    {
        grid[j + i * size] = alive;
    }
}

void GameOfLife::step()
{
    dim3 block_size(8, 8);
    dim3 grid_size = ({
        int gx = (size_ + block_size.x) / block_size.x;
        int gy = (size_ + block_size.y) / block_size.y;
        dim3(gx, gy);
    });

    _device_step<<<grid_size, block_size>>>(grid_, size_);
}
