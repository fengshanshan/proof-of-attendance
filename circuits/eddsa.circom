// pragma circom 2.0.0;

// include "../node_modules/circomlib/circuits/eddsaposeidon.circom";
// include "../node_modules/circomlib/circuits/comparators.circom";


// // signature verification
// template EdDSAVerification() {
//     // EdDSA Verification Component
//     signal input enabled_eddsa;
//     signal input Ax;
//     signal input Ay;
//     signal input R8x;
//     signal input R8y;
//     signal input S;
//     signal input M; // Use root hash as message

//     component eddsaVerifier = EdDSAPoseidonVerifier();
//     eddsaVerifier.enabled <== enabled_eddsa;
//     eddsaVerifier.Ax <== Ax;
//     eddsaVerifier.Ay <== Ay;
//     eddsaVerifier.R8x <== R8x;
//     eddsaVerifier.R8y <== R8y;
//     eddsaVerifier.S <== S;
//     eddsaVerifier.M <== M;

//     signal output isValid;
//     isValid <== 1;
// }

// component main = EdDSAVerification();

/*INPUT={
  "enabled_eddsa": 1,
  "Ax": "2589160430548275447474233855085032883650209259899304356200528405275801560589",
  "Ay": "1900028202440560170469654102308827639326429496439626201816587820962905753027",
  "R8x": "7052948437658914912225188207167359617588752037841893839991547037867220015653",
  "R8y": "3029476046507579725384973828716912710314012505454297586282668717895593351512",
  "S": "969304058143593998056482591322356985008152752405891163368835498879129096126",
  "M": "1729767109"
}*/