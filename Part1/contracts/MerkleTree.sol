//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        uint leaves=8;
        for (uint i = 0; i < leaves; i++) {
            hashes.push();
        }
        uint count = leaves;
        uint offset = 0;
        while(count > 0) {
            for(uint i = 0; i < count - 1; i += 2) {
                hashes.push(PoseidonT3.poseidon([hashes[offset + i], hashes[offset + i + 1]]));
            }
            offset += count;
            count = count / 2;
        }

    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        // there are only 8 leaves, starting from 0 index
        require(index < 8, "Max index is 7");
        // update the leaf node (level=3)
        hashes[index] = hashedLeaf;
        uint256 currentLevelHash = hashedLeaf;
        uint256 currentIndex=index;
        uint8 depth=3;


        for(uint8 n = 0; n <depth; n ++) {
            if (currentIndex % 2 == 0) {
                uint256 hash = PoseidonT3.poseidon([currentLevelHash, hashes[currentIndex+1]]);
                currentIndex = currentIndex/2 +8;
                hashes[currentIndex] = hash;
                currentLevelHash=hash;
            } else {
                uint256 hash = PoseidonT3.poseidon([hashes[currentIndex - 1], currentLevelHash]);
                currentIndex = currentIndex/2 +8;
                hashes[currentIndex] = hash;
                currentLevelHash=hash;
            }
        }


        return currentLevelHash;

        }



    function verify(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        //inherited from super contract
        return Verifier.verifyProof(a, b, c, input);
    }
}