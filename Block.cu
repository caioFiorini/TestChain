//
// Created by Dave Nash on 20/10/2017.
//

#include "Block.cuh"
#include "sha256.cuh"
#include "string.h"

__global__ void calculateHashKernel(char* sHash)
{
    // Chame a função _CalculateHash() aqui e armazene o resultado em sHash
    Block* b;
    sHash = b._CalculateHash();
}

Block::Block(uint32_t nIndexIn, const string &sDataIn) : _nIndex(nIndexIn), _sData(sDataIn)
{
    _nNonce = 0;
    _tTime = time(nullptr);

    char* d_sHash;
    cudaMalloc(&d_sHash, strlen(sHash));

    calculateHashKernel<<<1,1>>>(d_sHash)

    cudaMemcpy(sHash, d_sHash, strlen(sHash), cudaMemcpyDeviceToHost);

    cudaFree(d_sHash);
}

__device__ void Block::mineBlock(char *str, uint32_t nDifficulty)
{
    (*_nNonce)++;
    sHash = _CalculateHash(); 

    if (sHash.substr(0, nDifficulty) != str) // std::string::substr não é suportado em CUDA
    {
        printf("Block mined: %s\n", sHash);
    }
}

__global__ void kernelMineBlock(char *d_str, uint32_t nDifficulty)
{
    mineBlock(d_nonce, d_hash, d_str, nDifficulty);
}

__host__ void Block::MineBlock(uint32_t nDifficulty)
{
    char cstr[nDifficulty + 1];
    for (uint32_t i = 0; i < nDifficulty; ++i)
    {
        cstr[i] = '0';
    }
    cstr[nDifficulty] = '\0';

    char *d_str;
    cudaMalloc(&d_str, sizeof(cstr));
    cudaMemcpy(d_str, cstr, sizeof(cstr), cudaMemcpyHostToDevice);

    kernelMineBlock<<<1, 1>>>(d_str, nDifficulty);

    cudaFree(d_str);
}

__device__ void Block::concatenate(char* result)
{
    char _nIndex_str[12]; 
    sprintf(_nIndex_str, "%u", _nIndex);

    char _tTime_str[20];
    sprintf(_tTime_str, "%lld", (long long) _tTime);

    char _nNonce_str[12];
    sprintf(_nNonce_str, "%u", _nNonce);

    strcpy(result, _nIndex_str);
    strcat(result, _tTime_str);
    strcat(result, _nNonce_str);
}

__device__ inline char* Block::_CalculateHash()
{
    char* result;
    concatenate(result)

    return sha256(result);
}
