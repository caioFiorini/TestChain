#include "Block.cuh"
#include "sha256.h"

Block::Block(uint32_t nIndexIn, const string &sDataIn) : _nIndex(nIndexIn), _sData(sDataIn)
{
    _nNonce = 0;
    _tTime = time(nullptr);

    sHash = _CalculateHash();
}

__device__ void Block::MineBlock(uint32_t nDifficulty)
{
    char cstr[nDifficulty + 1];
    for (uint32_t i = 0; i < nDifficulty; ++i)
    {
        cstr[i] = '0';
    }
    cstr[nDifficulty] = '\0';

    string str(cstr);

    do
    {
        _nNonce++;
        sHash = _CalculateHash();
    }while (sHash.substr(0, nDifficulty) != str);

    cout << "Block mined: " << sHash << endl;
}

//posso paralelizar essa parte do código.
void Block::MineBlock(uint32_t nDifficulty)
{
    cudaMallocManaged(&_nNonce, sizeof(uint32_t));
    // nDifficulty + 1 -> seria adicionar espaço para o /0
    cudaMallocManaged(&sHash, (nDifficulty+1) * sizeof(char));

    *_nNonce = 0;
    for(uint32_t i = 0; i < nDifficulty; i++){
        sHash[i] = '0';
    }

    sHash[nDifficulty] = '\0';

    mineblock<<<2,2>>>(nDifficulty, _nNonce, sHash)
    cudaDeviceSynchronize();
    
    cout << "Block mined: " << sHash << endl;
}

__device__ char* Block::_CalculateHash() const
{
    stringstream ss;
    ss << _nIndex << sPrevHash << _tTime << _sData << _nNonce;

    return sha256(ss.str());
}