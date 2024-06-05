#ifndef BLOCK_CUH
#define BLOCK_CUH

#include <cstdint>
#include <iostream>
#include <sstream>
#include <cuda_runtime.h>

using namespace std;

class Block {
    public:
        string sHash;
        string sPrevHash;

        Block (uint32_t nIndexIn, const string &sDataIn);
        __device__ void MineBlock(uint32_t nDifficulty);

    private:
        uint32_t _nIndex;
        uint32_t _nNonce;
        string _sData;
        time_t _tTime;

        __device__ string _CalculateHash() const;
};

#endif //BLOCK_CUH