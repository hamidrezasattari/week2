pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    signal treeTotalNodes<== 2**(n+1) - 1;
    signal treeNodesModel[treeTotalNodes];
    component hashComps[2**n-1];

    // populate data at deppest  layer which is leaves
    for (var i = 0; i < 2**n; i++) {
        treeNodesModel[i] <== leaves[i];
    }

    for (var j = 0; j < 2**n-1; j++) {
        hashComps[j] = Poseidon(2);
        hashComps[j].inputs[0] <== treeNodesModel[2*j];
        hashComps[j].inputs[1] <== treeNodesModel[2*j+1];
        treeNodesModel[j+2**n] = hashComps[j].out;
    }

    root <== hashComps[2**n-2].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon2[n];
    signal hash[n+1];
    hash[0] <== leaf;
    for (var i=0; i<n; i++) {
        poseidon2[i] = Poseidon(2);
        //0: Merkle proof element is in left and hash in the right -> hash(proof+hash), 1: Merkle proof element is in right and hash in the left-> out= hash(hash,proof)
        poseidon2[i].inputs[0] <== (hash[i] - path_elements[i]) * path_index[i] + path_elements[i];
        poseidon2[i].inputs[1] <== (path_elements[i] - hash[i]) * path_index[i] + hash[i];
        hash[i+1] <== poseidon2[i].out;
    }
    root <== hash[n];
}