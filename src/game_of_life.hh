#pragma once

#include <cstddef>
#include <ostream>

class GameOfLife
{
public:
    GameOfLife(std::size_t size);
    ~GameOfLife();

    void reset();
    void step();
    void dump(std::ostream& os) const;

private:
    std::size_t size_;
    int* grid_;
};

std::ostream& operator<<(std::ostream& os, const GameOfLife& game);
