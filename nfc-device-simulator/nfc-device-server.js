const express = require('express');
const { generateEdDSAInputs } = require('./generate_eddsa_input');

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

                const signature = await this.generateNFCSignature(username);
                res.json(signature);
            } catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }

    async generateNFCSignature(username) {
        this.currentNonce += 1;

        const circuitInput = await generateEdDSAInputs(username, this.currentNonce);
        
        return {
            username,
            nonce: this.currentNonce,
            signature: circuitInput
        };
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