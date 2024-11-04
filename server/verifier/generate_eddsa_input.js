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

async function generateEdDSAInputs(username = "user_123", nonce = 1) {
    // Validate username (only allows alphanumeric and underscore)
    if (!/^[a-zA-Z0-9_]+$/.test(username)) {
        throw new Error("Username can only contain letters, numbers, and underscores");
    }

    const eddsa = await circomlibjs.buildEddsa();
    const babyJub = await buildBabyjub();
    const F = babyJub.F;
    const poseidon = await circomlibjs.buildPoseidon();

    // Generate a random private key
    const privateKey = ethers.hexlify(ethers.randomBytes(32));
    
    // Generate public key using eddsa
    const pubKey = eddsa.prv2pub(privateKey);

    // Convert username to array of ASCII codes
    const usernameArray = Array.from(username).map(char => char.charCodeAt(0));
    
    // Current timestamp
    const timestamp = Math.round(+new Date()/1000);

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

    // Ax, Ay => pubKey
    // R8x, R8y, S, (R,S) signature
    // M, nonce, timestamp M = message hash, (username, nonce, timestamp) = message
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

    // Generate second signature
    const secondTimestamp = await generateSecondSignature(
        privateKey, 
        username, 
        nonce + 1, 
        timestamp + 28801  // 8 hours later + 1 second
    );

    const circuitInput = {
        "prove_time": 28800,  // 8 hours in seconds
        "check_time": [inputArr, secondTimestamp]
    };

    console.log(JSON.stringify(circuitInput, null, 2));
}

async function generateSecondSignature(privateKey, username, nonce, timestamp) {
    const eddsa = await circomlibjs.buildEddsa();
    const babyJub = await buildBabyjub();
    const F = babyJub.F;
    const poseidon = await circomlibjs.buildPoseidon();

    const pubKey = eddsa.prv2pub(privateKey);
    
    const usernameArray = Array.from(username).map(char => char.charCodeAt(0));
    const msgHashRaw = poseidon([
        ...usernameArray,
        nonce,
        timestamp
    ]);
    
    const msgHash = poseidon.F.toString(msgHashRaw);
    const signature = eddsa.signPoseidon(privateKey, msgHashRaw);

    return [
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
}

generateEdDSAInputs().catch(console.error);
