#!/bin/bash

# call to the server to verify the proof and record the attendance
echo "----- Call to the server to verify the proof and record the attendance -----"

response=$(curl -X POST http://localhost:8080/submit-proof \
-H "Content-Type: application/json" \
-d @request.json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify the proof by the server"
    exit 1
fi
echo "$response" | jq '.'

echo "verify the proof successfully"
