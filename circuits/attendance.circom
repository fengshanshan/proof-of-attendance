pragma circom 2.0.0;

include "circomlib/circuits/eddsaposeidon.circom";
include "circomlib/circuits/comparators.circom";

template EdDSAVerification() {
    // EdDSA Verification Component
    signal input enabled_eddsa;
    signal input Ax;
    signal input Ay;
    signal input R8x;
    signal input R8y;
    signal input S;
    signal input M;  // This will be the message hash from JS

    // Verify signature
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

template AttendanceCheck() {
    // Input for two timestamps with additional fields
    signal input check_time[2][9];  // [enabled, Ax, Ay, R8x, R8y, S, M, nonce, timestamp]
    signal input prove_time;

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

    // Verify nonces are sequential
    signal noncesSequential;
    noncesSequential <== IsEqual()([check_time[1][7], check_time[0][7] + 1]);

    // Ensure both signatures are valid
    signal bothSignaturesValid;
    bothSignaturesValid <== verifier1.isValid * verifier2.isValid;

    // Calculate time difference
    signal timeDiff;
    timeDiff <== check_time[1][8] - check_time[0][8];

    // Check if time difference is greater than prove_time
    component greaterThan = GreaterThan(32);
    greaterThan.in[0] <== timeDiff;
    greaterThan.in[1] <== prove_time;

    // Break down the multiple signal multiplication into pairs
    signal validityAndTime;
    validityAndTime <== bothSignaturesValid * greaterThan.out;

    // Output 1 if all conditions are met
    signal output attendanceValid;
    attendanceValid <== validityAndTime * noncesSequential;
}

component main {public [prove_time]} = AttendanceCheck();

/*
INPUT = {
  "prove_time": 28799,
  "check_time": [
    [
      1,
      "17782994823098191898709711761754756134786475892110514299914385327392635625753",
      "7303343176013926170794047982336061618512290881631879807339187439753332538716",
      "19338083758014811400261414688598908968663384838113230199661762601679331498176",
      "2044637877927458169964642093031142035782158115725005611329346630065455575184",
      "2275359842455349155808239481268287743644921020787500892295577655288745089838",
      "10805372539939940669052213902731223444966575612962158721367388891783011955132",
      1,
      1730108087
    ],
    [
      1,
      "17782994823098191898709711761754756134786475892110514299914385327392635625753",
      "7303343176013926170794047982336061618512290881631879807339187439753332538716",
      "15507672613561559225674694112484369869756292472012294063639144301470778748575",
      "17163607832041963877971391917339510278558098161094876787500527761940227965316",
      "500307222039899473796248097091522904002697021242591747768866575692874026237",
      "21750531532596298593358934091326231938331375780187371142987441029948399981977",
      2,
      1730136887
    ]
  ]
}
*/