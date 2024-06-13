//
// Created by Dave Nash on 20/10/2017.
//
#include <algorithm>
#include <cstdio>
#include <ctime>
#include <cstring>
#include "Block.cuh"
#include "sha256.cuh"
#include "sha256host.cuh"

Block::Block(uint32_t nIndexIn, const std::string &sDataIn) : _nIndex(nIndexIn), _sData(sDataIn)
{
    _nNonce = 0;
    _tTime = time(nullptr);

    sHash = _CalculateHash();
}

__device__ int strcmp_cuda(const char *str1, const char *str2)
{
    while (*str1 && (*str1 == *str2))
    {
        str1++;
        str2++;
    }
    return *(unsigned char *)str1 - *(unsigned char *)str2;
}

__device__ char* uint32_to_string(uint32_t num, char* buffer)
{
    int i = 0;
    do
    {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    } while (num > 0);
    buffer[i] = '\0';
    
    // Reverse the string
    for (int j = 0; j < i / 2; j++)
    {
        char temp = buffer[j];
        buffer[j] = buffer[i - j - 1];
        buffer[i - j - 1] = temp;
    }
    return buffer;
}

__device__ char* int64_to_string(int64_t num, char* buffer)
{
    int i = 0;
    bool isNegative = num < 0;
    if (isNegative) num = -num;

    do
    {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    } while (num > 0);
    
    if (isNegative) buffer[i++] = '-';
    buffer[i] = '\0';

    for (int j = 0; j < i / 2; j++)
    {
        char temp = buffer[j];
        buffer[j] = buffer[i - j - 1];
        buffer[i - j - 1] = temp;
    }
    return buffer;
}

__device__ void strcpy_cuda(char* dest, const char* src)
{
    while ((*dest++ = *src++) != '\0');
}

__device__ void strcat_cuda(char* dest, const char* src)
{
    while (*dest) dest++;
    while ((*dest++ = *src++) != '\0');
}

__global__ void mineBlockKernel(Block *b, char *str, uint32_t nDifficulty, char *resp)
{
    b->_nNonce++;
    char *sHash = b->_CalculateHashCuda();

    for (int i = 0; i < nDifficulty; i++)
    {
        resp[i] = sHash[i];
    }
    resp[nDifficulty] = '\0';

    if (strcmp_cuda(resp, str) == 0)
    {
        printf("Block mined: %s\n", sHash);
    }
}

void Block::MineBlock(uint32_t nDifficulty)
{
    Block *b = this;
    char cstr[nDifficulty + 1];
    for (uint32_t i = 0; i < nDifficulty; ++i)
    {
        cstr[i] = '0';
    }
    cstr[nDifficulty] = '\0';

    char *d_str;
    char *d_resp;
    cudaMalloc(&d_str, sizeof(cstr));
    cudaMalloc(&d_resp, nDifficulty + 1);
    cudaMemcpy(d_str, cstr, sizeof(cstr), cudaMemcpyHostToDevice);

    mineBlockKernel<<<1, 1>>>(b, d_str, nDifficulty, d_resp);

    cudaFree(d_str);
    cudaFree(d_resp);
}

__device__ inline char* Block::_CalculateHashCuda()
{
    char result[1024]; // Supondo que o tamanho máximo do hash seja 1024 caracteres

    char _nIndex_str[12];
    uint32_to_string(_nIndex, _nIndex_str);

    char _tTime_str[20];
    int64_to_string(_tTime, _tTime_str);

    char _nNonce_str[12];
    uint32_to_string(_nNonce, _nNonce_str);

    strcpy_cuda(result, _nIndex_str);
    strcat_cuda(result, _tTime_str);
    strcat_cuda(result, _nNonce_str);

    return SHA256CUDA::sha256(result);
}

inline std::string Block::_CalculateHash()
{
    std::stringstream ss;
    ss << _nIndex << sPrevHash << _tTime << _sData << _nNonce;

    return sha256(ss.str());
}