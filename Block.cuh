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
        void MineBlock(uint32_t nDifficulty);

    private:
        uint32_t _nIndex;
        uint32_t* _nNonce;
        string _sData;
        time_t _tTime;

        __device__ char* _CalculateHash() const;
        __device__ bool _IsValidHash(const char* hash, uint32_t nDifficulty) const;
};

__global__ void mineblock(uint32_t nDifficulty, uint32_t* nNonce, char* sHash, uint32_t index, time_t tTime, const char* sPrevHash, const char* sData);

#endif //BLOCK_CUH