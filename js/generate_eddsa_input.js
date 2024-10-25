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

async function generateEdDSAInputs() {
    // Initialize Poseidon and eddsa
    //const poseidon = await circomlibjs.buildPoseidon();
    const eddsa = await circomlibjs.buildEddsa();

    const babyJub = await buildBabyjub();
    const F = babyJub.F;

    // Generate a random private key
    const privateKey = ethers.hexlify(ethers.randomBytes(32));
    
    // Generate public key using eddsa
    const pubKey = eddsa.prv2pub(privateKey);

    //msg
    unixTimestamp = Math.round(+new Date()/1000);
    const msg = F.e(unixTimestamp);

    // Sign the message using eddsa
    const signature = eddsa.signPoseidon(privateKey, msg);

    // Format the input for circom
    const input = {
        enabled_eddsa: 1,
        Ax: bigIntToString(F.toObject(pubKey[0])),
        Ay: bigIntToString(F.toObject(pubKey[1])),
        R8x: bigIntToString(F.toObject(signature.R8[0])),
        R8y: bigIntToString(F.toObject(signature.R8[1])),
        S: bigIntToString(signature.S),
        M: bigIntToString(F.toObject(msg))
    };

    console.log(JSON.stringify(input, null, 2));
}

generateEdDSAInputs().catch(console.error);
