#pragma once

#include <cstddef>

class GameOfLife
{
public:
    GameOfLife(std::size_t size);
    ~GameOfLife();

    void reset();
    void step();

private:
    std::size_t size_;
    int* grid_;
};
