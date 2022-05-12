set -e
rm -fr ceremony
mkdir -p ceremony

# Build app
circom source/app.circom --r1cs --wasm --sym --output ceremony

# Start ceremony
snarkjs powersoftau new bn128 12 ceremony/pot12_0000.ptau -v

# Iteration 1
snarkjs powersoftau contribute ceremony/pot12_0000.ptau ceremony/pot12_0001.ptau --name="First contribution" -v -e="Entropy 1"

# Iteration 2
snarkjs powersoftau contribute ceremony/pot12_0001.ptau ceremony/pot12_0002.ptau --name="Second contribution" -v -e="Entropy 2"

# Iteration 3
snarkjs powersoftau contribute ceremony/pot12_0002.ptau ceremony/pot12_0003.ptau --name="Third contribution" -v -e="Entropy 3"

# Random beacon
snarkjs powersoftau beacon ceremony/pot12_0003.ptau ceremony/pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

# Prepare for phase 2
snarkjs powersoftau prepare phase2 ceremony/pot12_beacon.ptau ceremony/pot12_final.ptau -v

# Verify
snarkjs powersoftau verify ceremony/pot12_final.ptau

# Phase 2
snarkjs groth16 setup ceremony/app.r1cs ceremony/pot12_final.ptau ceremony/app_0000.zkey

# Contribution 1
snarkjs zkey contribute ceremony/app_0000.zkey ceremony/app_0001.zkey --name="1st Contributor Name" -v -e="Entropy 4"

# Contribution 2
snarkjs zkey contribute ceremony/app_0001.zkey ceremony/app_0002.zkey --name="2nd Contributor Name" -v -e="Entropy 5"

# Contribution 3
snarkjs zkey contribute ceremony/app_0002.zkey ceremony/app_0003.zkey --name="3rd Contributor Name" -v -e="Entropy 6"

# Random beacon
snarkjs zkey beacon ceremony/app_0003.zkey ceremony/app_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"

# Verify
snarkjs zkey verify ceremony/app.r1cs ceremony/pot12_final.ptau ceremony/app_final.zkey

# Export key
snarkjs zkey export verificationkey ceremony/app_final.zkey ceremony/verification_key.json

# Export SOL verifier
snarkjs zkey export solidityverifier ceremony/app_final.zkey ceremony/verifier.sol