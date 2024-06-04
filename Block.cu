#include "Block.cuh"
#include "sha256.h"

Block::Block(uint32_t nIndexIn, const string &sDataIn) : _nIndex(nIndexIn), _sData(sDataIn)
{
    _nNonce = 0;
    _tTime = time(nullptr);

    sHash = _CalculateHash();
}

__global__ void mineblock(uint32_t nDifficulty, uint32_t* _nNonce, char* sHash)
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
        _nNonce++; // variável da CPU.
        sHash = _CalculateHash(); //variável compartilhada com a CPU.
    } while (sHash.substr(0, nDifficulty) != str);
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

inline string Block::_CalculateHash() const
{
    stringstream ss;
    ss << _nIndex << sPrevHash << _tTime << _sData << _nNonce;

    return sha256(ss.str());
}