// Pragma directive specifying the Circom version
pragma circom 2.1.6;

// Include the necessary library for comparison components (assuming circomlib is installed)
// We will use GreaterThan or GreaterEqThan components.
// Note: This relies on the standard circomlib package.
include "../../node_modules/circomlib/circuits/comparators.circom";

/**
 * ZkAgeVerifier
 * Proves that (currentYear - birthYear) >= minAge
 * without revealing the actual birthYear.
 *
 * Params:
 * @param N_BITS: The number of bits required to represent the maximum possible age difference (e.g., 252).
 */
template ZkAgeVerifier(N_BITS) {
    // --- SIGNALS ---

    // Private Input: The user's birth year (e.g., 1995).
    signal input birthYear;
    
    // Public Input: The year the check is performed (e.g., 2025).
    signal input currentYear;
    
    // Public Input (Constant): The minimum required age (e.g., 18).
    signal input minAge;

    // Public Output: 1 if age >= minAge, 0 otherwise.
    signal output isAdult;
    
    // --- INTERMEDIATE CALCULATIONS ---

    // 1. Calculate the age (currentYear - birthYear).
    // The subtraction must be done manually via constraints to ensure it remains quadratic.
    // age + birthYear === currentYear
    signal age; 
    age + birthYear === currentYear;

    // 2. Check if the calculated 'age' is greater than or equal to 'minAge'.
    // We use the GreaterEqThan component from circomlib.
    // N_BITS is set to a sufficiently large number (e.g., 252) to handle field elements.
    component greaterThanOrEqual = GreaterEqThan(N_BITS);

    greaterThanOrEqual.in[0] <== age;
    greaterThanOrEqual.in[1] <== minAge;

    // 3. Set the public output to the result of the comparison.
    isAdult <== greaterThanOrEqual.out;
    
    // Constraint: The output must be either 0 or 1 (a boolean).
    isAdult * (isAdult - 1) === 0; 
}

// Instantiate the main component with a standard bit size for safety/flexibility.
// Note: 252 bits is standard for Groth16 field elements.
component main = ZkAgeVerifier(252);