const express = require('express');
const { generateEdDSAInputs } = require('./generate_eddsa_input');
const ethers = require('ethers');
// Generate a random private key
const privateKey = ethers.hexlify(ethers.randomBytes(32));

class NFCDeviceSimulator {
    constructor() {
        this.currentNonce = 0;
        this.app = express();
        this.setupRoutes();
    }

    setupRoutes() {
        this.app.use(express.json());

        // Endpoint to simulate NFC device tap
        this.app.post('/tap', async (req, res) => {
            try {
                const { username } = req.body;
                if (!username) {
                    return res.status(400).json({ error: 'Username is required' });
                }
                
                // Current timestamp
                const timestamp = Math.round(+new Date()/1000);
                const signature1 = await this.generateNFCSignature(username, timestamp);
                
                // Sleep for 3 second
                await new Promise(resolve => setTimeout(resolve, 3000));
                console.log("assumed after whole day...\n");
                console.log("tap the NFC device again\n");
               
                // Current timestamp
                const timestamp2 = timestamp + 28800 + 3600;
                console.log("timestamp2: ", timestamp2);
                const signature2 = await this.generateNFCSignature(username, timestamp2);

                res.json({
                    "prove_time": 28800, // 8 hours 
                    "check_time": [signature1, signature2]
                });
            } catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }

    async generateNFCSignature(username, timestamp) {
        this.currentNonce += 1;
        const circuitInput = await generateEdDSAInputs(username, this.currentNonce, timestamp, privateKey);
        
        console.log(circuitInput);  
        return circuitInput;
    }

    start(port = 3000) {
        this.app.listen(port, () => {
            console.log(`NFC Device Simulator running on port ${port}`);
        });
    }
}

// Start the server
const nfcSimulator = new NFCDeviceSimulator();
nfcSimulator.start(); 