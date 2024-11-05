const { ethers } = require("ethers");
const circomlibjs = require("circomlibjs");
const buildBabyjub = require("circomlibjs").buildBabyjub;

// Helper function to convert BigInt to string
const bigIntToString = (value) => {
    if (typeof value === 'bigint') {
        return value.toString();
    }
    return value;
};

async function generateEdDSAInputs(username = "user_123", nonce = 1, timestamp = null, privateKey = null) {
    // Validate username (only allows alphanumeric and underscore)
    if (!/^[a-zA-Z0-9_]+$/.test(username)) {
        throw new Error("Username can only contain letters, numbers, and underscores");
    }

    const eddsa = await circomlibjs.buildEddsa();
    const babyJub = await buildBabyjub();
    const F = babyJub.F;
    const poseidon = await circomlibjs.buildPoseidon();
 
    // Generate public key using eddsa
    const pubKey = eddsa.prv2pub(privateKey);

    // Convert username to array of ASCII codes
    const usernameArray = Array.from(username).map(char => char.charCodeAt(0));


    // Create message by hashing username, nonce, and timestamp
    const msgHashRaw = poseidon([
        ...usernameArray,
        nonce,
        timestamp
    ]);
    
    // Convert the hash to the proper format for signing
    const msgHash = poseidon.F.toString(msgHashRaw);
    
    // Sign the raw hash
    const signature = eddsa.signPoseidon(privateKey, msgHashRaw);

    const inputArr = [
        1,
        bigIntToString(F.toObject(pubKey[0])),
        bigIntToString(F.toObject(pubKey[1])),
        bigIntToString(F.toObject(signature.R8[0])),
        bigIntToString(F.toObject(signature.R8[1])),
        bigIntToString(signature.S),
        msgHash,
        nonce,
        timestamp
    ];

    return inputArr;
}


module.exports = {
    generateEdDSAInputs,
};

