#!/bin/bash


# call to the server to verify the proof and record the attendance
echo "----- Build up the request parameters and save to request-call.json file -----"
cd build && snarkjs generatecall | node -e "
const input = require('fs').readFileSync(0, 'utf-8');
// 将输入转换为有效的 JSON 数组格式
const jsonStr = '[' + input + ']';
const data = JSON.parse(jsonStr);
const result = {
    user_name: 'user123',
    proof_data: {
        proof: {
            pi_a: data[0],
            pi_b: [data[1][0], data[1][1]],
            pi_c: data[2]
        },
        public_signals: data[3]
    }
};
require('fs').writeFileSync('../request-call.json', JSON.stringify(result, null, 4));
"
cd ../

# call to the server to verify the proof and record the attendance
echo "----- Call to the server to verify the proof and record the attendance -----"

response=$(curl -X POST http://localhost:8080/submit-proof \
-H "Content-Type: application/json" \
-d @request-call.json 2>/dev/null)

echo "Response:"
echo "$response"

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify the proof by the server"
    exit 1
fi
echo "$response" | jq '.'

echo "verify the proof successfully"
