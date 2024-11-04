// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";
import "../contracts/verifier.sol";

contract Groth16VerifierTest is Test {
    Groth16Verifier public verifier;

    // Sample valid proof data (you'll need to replace these with actual proof values from your ZK circuit)
    uint[2] validProofA = [
        0x1234567890123456789012345678901234567890123456789012345678901234,
        0x1234567890123456789012345678901234567890123456789012345678901234
    ];

    uint[2][2] validProofB = [
        [
            0x1234567890123456789012345678901234567890123456789012345678901234,
            0x1234567890123456789012345678901234567890123456789012345678901234
        ],
        [
            0x1234567890123456789012345678901234567890123456789012345678901234,
            0x1234567890123456789012345678901234567890123456789012345678901234
        ]
    ];

    uint[2] validProofC = [
        0x1234567890123456789012345678901234567890123456789012345678901234,
        0x1234567890123456789012345678901234567890123456789012345678901234
    ];

    uint[2] validPubSignals = [
        0x1234567890123456789012345678901234567890123456789012345678901234,
        0x1234567890123456789012345678901234567890123456789012345678901234
    ];

    function setUp() public {
        verifier = new Groth16Verifier();
    }

    function testValidProof() public {
        bool result = verifier.verifyProof(
            validProofA,
            validProofB,
            validProofC,
            validPubSignals
        );
        assertTrue(result, "Valid proof should be verified successfully");
    }

    function testInvalidProof() public {
        // Modify one value to make the proof invalid
        uint[2] memory invalidProofA = validProofA;
        invalidProofA[
            0
        ] = 0x9999999999999999999999999999999999999999999999999999999999999999;

        bool result = verifier.verifyProof(
            invalidProofA,
            validProofB,
            validProofC,
            validPubSignals
        );
        assertFalse(result, "Invalid proof should be rejected");
    }

    function testInvalidPublicInputs() public {
        // Modify public inputs to make them invalid
        uint[2] memory invalidPubSignals = validPubSignals;
        invalidPubSignals[
            0
        ] = 0x9999999999999999999999999999999999999999999999999999999999999999;

        bool result = verifier.verifyProof(
            validProofA,
            validProofB,
            validProofC,
            invalidPubSignals
        );
        assertFalse(
            result,
            "Proof with invalid public inputs should be rejected"
        );
    }

    function testFieldBoundaryCheck() public {
        // Test with values larger than the field size
        uint[2] memory overflowPubSignals = validPubSignals;
        overflowPubSignals[
            0
        ] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

        bool result = verifier.verifyProof(
            validProofA,
            validProofB,
            validProofC,
            overflowPubSignals
        );
        assertFalse(result, "Proof with overflow values should be rejected");
    }
}
