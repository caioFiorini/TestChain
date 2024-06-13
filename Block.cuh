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
    uint32_t _nNonce;
    uint32_t _nIndex;
    string _sData;
    time_t _tTime;

    Block(uint32_t nIndexIn, const string &sDataIn);
    void MineBlock(uint32_t nDifficulty);
    __device__ inline char* _CalculateHashCuda();
	inline string _CalculateHash();
    __device__ int strcmp_cuda(const char *str1, const char *str2);
    __device__ void strcat_cuda(char* dest, const char* src);
    __device__ void strcpy_cuda(char* dest, const char* src);
    __device__ char* int64_to_string(int64_t num, char* buffer);
    __device__ char* uint32_to_string(uint32_t num, char* buffer);
    
};

