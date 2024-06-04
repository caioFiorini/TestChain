#ifndef BLOCKCHAIN_CUH
#define BLOCKCHAIN_CUH

#include <cstdint>
#include <vector>
#include "Block.cuh"

using namespace std;

class Blockchain{
    public:
        Blockchain();

        void AddBlock(Block bNew);
    
    private:
        uint32_t _nDifficulty;
        vector<Block> _vChain;

        Block _GetLastBlock() const;
};

#endif //BLOCKCHAIN_CUH