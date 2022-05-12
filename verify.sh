set -e
rm -fr proof
mkdir -p proof

# Create witness
node ./ceremony/app_js/generate_witness.js ./ceremony/app_js/app.wasm ./source/input.json ./proof/witness.wtns

# Create proof
snarkjs groth16 prove ./ceremony/app_final.zkey ./proof/witness.wtns ./proof/proof.json ./proof/public.json

# Verify
snarkjs groth16 verify ./ceremony/verification_key.json ./proof/public.json ./proof/proof.json
