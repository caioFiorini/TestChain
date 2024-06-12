//
// Created by Dave Nash on 20/10/2017.
//
#pragma once

#include <cstdint>
#include <sstream>
#include <iostream>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

using namespace std;

class Block {
public:
    string sHash;
    string sPrevHash;

    Block(uint32_t nIndexIn, const string &sDataIn);
    void MineBlock(uint32_t nDifficulty);
    
    private:
    uint32_t _nIndex;
    uint32_t _nNonce;
    string _sData;
    time_t _tTime;

    inline char* _CalculateHash();
};

#endif //TESTCHAIN_BLOCK_CUH
