#include "Block.cuh"
#include "sha256.cuh"


__device__ bool _IsValidHash(const char* hash, uint32_t nDifficulty) const {
    for (uint32_t i = 0; i < nDifficulty; ++i) {
        if (hash[i] != '0') {
            return false;
        }
    }
    return true;
}

__global__ void mineblock(uint32_t nDifficulty, uint32_t* nNonce, char* sHash, uint32_t index, time_t tTime, const char* sPrevHash, const char* sData) {
    uint32_t nonce = blockIdx.x * blockDim.x + threadIdx.x;

    char buffer_ss[1000];

    char hash[65];
    while (true) {
        // Calculate hash
        sprintf(buffer_ss, "%d%s%ld%s%d", index, sPrevHash, tTime, sData, nonce);
        
        sha256(buffer_ss, hash);

        for (int i = 0; i < 64; i++)
        {
            sHash[i] = hash[i];
        }

        hash[64] = '\0';

        if (_IsValidHash(hash, nDifficulty)) {
            strncpy(sHash, hash, 64);
            *nNonce = nonce;
            return;
        }
        nonce += gridDim.x * blockDim.x;
    }
}

Block::Block(uint32_t nIndexIn, const string &sDataIn) : _nIndex(nIndexIn), _sData(sDataIn) {
    cudaMallocManaged(&_nNonce, sizeof(uint32_t));
    *_nNonce = 0;
    _tTime = time(nullptr);

    sHash = _CalculateHash();
}

void Block::MineBlock(uint32_t nDifficulty) {
    char* d_sHash;
    cudaMallocManaged(&d_sHash, 65 * sizeof(char));
    
    char* d_sPrevHash;
    cudaMallocManaged(&d_sPrevHash, sPrevHash.size() + 1);
    strcpy(d_sPrevHash, sPrevHash.c_str());

    char* d_sData;
    cudaMallocManaged(&d_sData, _sData.size() + 1);
    strcpy(d_sData, _sData.c_str());

    mineblock<<<2, 2>>>(nDifficulty, _nNonce, d_sHash, _nIndex, _tTime, d_sPrevHash, d_sData);
    cudaDeviceSynchronize();

    sHash = string(d_sHash);

    cudaFree(d_sHash);
    cudaFree(d_sPrevHash);
    cudaFree(d_sData);

    cout << "Block mined: " << sHash << endl;
}

__device__ char* Block::_CalculateHash() const {
    stringstream ss;
    ss << _nIndex << sPrevHash << _tTime << _sData << *_nNonce;
    string hashString = sha256(ss.str());
    char* hash = new char[65];
    strncpy(hash, hashString.c_str(), 64);
    hash[64] = '\0';
    return hash;
}
