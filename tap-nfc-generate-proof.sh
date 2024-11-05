#!/bin/bash

# Variable to store the name of the circuit
CIRCUIT=attendance

# In case there is a circuit name as an input
if [ "$1" ]; then
    CIRCUIT=$1
fi

# tap the NFC device 
echo "----- Tap the NFC device -----"
# Fetch data from NFC simulation server
response=$(curl -X POST http://localhost:3000/tap \
-H "Content-Type: application/json" \
-d '{"username": "user123"}' 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to NFC simulation server"
    exit 1
fi

echo "$response" | jq '.' > ./build/test-input.json || {
    echo "Error: Failed to process NFC response"
    exit 1
}

echo "NFC data received successfully"


#Generate the witness.wtns
echo "----- Generate the witness.wtns -----"
node ./build/${CIRCUIT}_js/generate_witness.js ./build/${CIRCUIT}_js/${CIRCUIT}.wasm ./build/test-input.json ./build/witness.wtns

echo "----- Generate zk-proof -----"
# Generate a zk-proof associated to the circuit and the witness. This generates proof.json and public.json
snarkjs groth16 prove ./build/${CIRCUIT}_final.zkey ./build/witness.wtns ./build/proof.json ./build/public.json

echo "----- Verify the proof -----"
# Verify the proof
snarkjs groth16 verify ./build/verification_key.json ./build/public.json ./build/proof.json