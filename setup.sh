#!/bin/bash

# Variable to store the name of the circuit
CIRCUIT=attendance

# In case there is a circuit name as an input
if [ "$1" ]; then
    CIRCUIT=$1
fi

# Check if build directory exists, if not create it
if [ ! -d "./build" ]; then
    echo "----- Creating build directory -----"
    mkdir -p ./build
fi

# Check if the necessary ptau file already exists. If it does not exist, it will be downloaded
if [ -f ./build/ptau/powersOfTau28_hez_final_14.ptau ]; then
    echo "----- powersOfTau28_hez_final_14.ptau already exists -----"
else
    echo "----- Download powersOfTau28_hez_final_14.ptau -----"
    wget -P ./build/ptau https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_14.ptau
fi

# Compile the circuit
circom circuits/${CIRCUIT}.circom --r1cs --wasm --sym --c -l node_modules -o build


# verification set up process   
echo "----- Generate .zkey file -----"
# Generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup ./build/${CIRCUIT}.r1cs ./build/ptau/powersOfTau28_hez_final_14.ptau ./build/${CIRCUIT}_0000.zkey

echo "----- Contribute to the phase 2 of the ceremony -----"
# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute ./build/${CIRCUIT}_0000.zkey ./build/${CIRCUIT}_final.zkey --name="1st Contributor Name" -v -e="attendance proof"

echo "----- Export the verification key -----"
# Export the verification key
snarkjs zkey export verificationkey ./build/${CIRCUIT}_final.zkey ./build/verification_key.json

