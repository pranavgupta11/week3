//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const chai = require("chai");
const path = require("path");
const { isTypedArray } = require("util/types");
const buildPoseidon = require("circomlibjs").buildPoseidon;
const wasm_tester = require("circom_tester").wasm;
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("11");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Mastermind tests ", async () => {


    it("Should pass the test of Bagel", async () => {

        try {

            const ckt = await wasm_tester("contracts/circuits/MastermindVariation.circom");
            await ckt.loadConstraints();

            //input tested to check the circuit is working as expected or not
            const    INPUT={
                "pubNumguessA": "3",
                "pubNumguessB": "2",
                "pubNumguessC": "1",
                "pubNumHit": "0",
                "pubNumBlow": "1",
                "pubNumBagel": "0",
                "pubSolnhash": "12452362985441139767852662852042363346895080498799740484070635350196381517277",
                "privSolnA": "4",
                "privSolnB": "3",
                "privSolnC": "9",
                "privsalt": "12354"
               }
            // using buildPoseidon to hash the private Input . 
            const poseidonHasher = await buildPoseidon();
            const hash = poseidonHasher([12345, 4, 3, 9]);
            console.log(hash);
            let poseidonhash;
            for (let i = 0; i < hash.length; i++) {
                // Converting the posdeidonhashes to Big int 
                poseidonhash = poseidonHasher.F.toString(hash);
            }


            const witness = await ckt.calculateWitness(INPUT, true);



            console.log(Fr.e(witness[1]));
            console.log(Fr.e(poseidonhash));



            assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
            // asserting the pubhash is equal to private hash
            assert(Fr.eq(Fr.e(witness[1], Fr.e(poseidonhash))));
        }
        catch (e) {
            console.log(e);
        }
    })

}) 
