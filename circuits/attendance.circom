pragma circom 2.0.0;

include "circomlib/eddsaposeidon.circom";
include "circomlib/comparators.circom";


// signature verification
template EdDSAVerification() {
    // EdDSA Verification Component
    signal input enabled_eddsa;
    signal input Ax;
    signal input Ay;
    signal input R8x;
    signal input R8y;
    signal input S;
    signal input M; // Use root hash as message

    component eddsaVerifier = EdDSAPoseidonVerifier();
    eddsaVerifier.enabled <== enabled_eddsa;
    eddsaVerifier.Ax <== Ax;
    eddsaVerifier.Ay <== Ay;
    eddsaVerifier.R8x <== R8x;
    eddsaVerifier.R8y <== R8y;
    eddsaVerifier.S <== S;
    eddsaVerifier.M <== M;

    signal output isValid;
    isValid <== 1;
}

// Calculate attendance
template AttendanceCheck() {
    // Input for two timestamps
    signal input check_time[2][7];

    // Verify signatures for both timestamps
    component verifier1 = EdDSAVerification();
    component verifier2 = EdDSAVerification();

    // Assign inputs to verifier1
    verifier1.enabled_eddsa <== check_time[0][0];
    verifier1.Ax <== check_time[0][1];
    verifier1.Ay <== check_time[0][2];
    verifier1.R8x <== check_time[0][3];
    verifier1.R8y <== check_time[0][4];
    verifier1.S <== check_time[0][5];
    verifier1.M <== check_time[0][6];

    // Assign inputs to verifier2
    verifier2.enabled_eddsa <== check_time[1][0];
    verifier2.Ax <== check_time[1][1];
    verifier2.Ay <== check_time[1][2];
    verifier2.R8x <== check_time[1][3];
    verifier2.R8y <== check_time[1][4];
    verifier2.S <== check_time[1][5];
    verifier2.M <== check_time[1][6];

    // Ensure both signatures are valid
    signal bothSignaturesValid;
    bothSignaturesValid <== verifier1.isValid * verifier2.isValid;

    // Calculate time difference
    signal timeDiff;
    timeDiff <== check_time[1][6] - check_time[0][6];

    // Check if time difference is greater than 8 hours (28800 seconds)
    component greaterThan = GreaterThan(32);
    greaterThan.in[0] <== timeDiff;
    greaterThan.in[1] <== 28800;

    // Output 1 if attendance check passes (both signatures valid and time difference > 8 hours), 0 otherwise
    signal output attendanceValid;
    attendanceValid <== bothSignaturesValid * greaterThan.out;
}

component main = AttendanceCheck();


