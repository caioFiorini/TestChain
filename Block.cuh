//
// Created by Dave Nash on 20/10/2017.
//

#ifndef TESTCHAIN_BLOCK_CUH
#define TESTCHAIN_BLOCK_CUH

#include <cstdint>
#include <iostream>
#include <sstream>

using namespace std;

class Block {
public:
    string sHash;
    string sPrevHash;

    Block(uint32_t nIndexIn, const string &sDataIn);

    __host__ void MineBlock(uint32_t nDifficulty);
    __device__ mineBlock(char* str,uint32_t nDifficulty);

private:
    uint32_t _nIndex;
    uint32_t _nNonce;
    string _sData;
    time_t _tTime;

    __device__ char* _CalculateHash();
    __device__ void concatenate(char* result)
};

#endif //TESTCHAIN_BLOCK_CUH
