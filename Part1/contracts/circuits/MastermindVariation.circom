pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

/// @notice: This implementation is variation of mastermind 
/// @notice:  This is bagel variation
/// 3 guesses per round
/// colors 10
/// if guess is not correct and position is also not correct, then bagel is shown

template MastermindVariation() {


    signal input pubNumguessA;
    signal input pubNumguessB;
    signal input pubNumguessC;
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubNumBagel;
    signal input pubSolnhash;

    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    signal input privsalt;

    signal output SolnhashOut;

    var guess[3] = [pubNumguessA,pubNumguessB,pubNumguessC];
    var soln[3] = [privSolnA,privSolnB,privSolnC];
    var j=0;
    var k = 0;

    component LessThan[30];
    component EqGuess[3];
    component EqSoln[3];
    var Eqidx = 0;

    for(j =0;j<3;j++){
        LessThan[j] = LessThan(5);
        LessThan[j].in[0] <== guess[j];
        LessThan[j].in[1] <== 10;
        LessThan[j].out ===1;

        LessThan[j+3] = LessThan(5);
        LessThan[j+3].in[0] <== soln[j];
        LessThan[j+3].in[1] <== 10;
        LessThan[j+3].out ===1;

        for(k=j+1;k<3;k++){
            EqGuess[Eqidx] = IsEqual();
            EqGuess[Eqidx].in[0] <== guess[j];
            EqGuess[Eqidx].in[1] <== guess[k];
            EqGuess[Eqidx].out === 0;

            EqSoln[Eqidx] = IsEqual();
            EqSoln[Eqidx].in[0] <== soln[j];
            EqSoln[Eqidx].in[1] <== soln[k];

            Eqidx +=1;
        }

    }


    var hit =0;
    var blow = 0;
    var bagel = 0;
    component EqualHB[10];
    var num=0;

    for(j =0; j<3;j++){
        for(k=0;k<3;k++){
            EqualHB[3 *j +k] = IsEqual();
            EqualHB[3 *j +k].in[0] <== guess[j];
            EqualHB[3 *j +k].in[1] <== soln[k];
            blow += EqualHB[3*j + k].out ;
            num += EqualHB[3*j + k].out;
            if(j==k){
                hit += EqualHB[3*j + k].out;
                blow -= EqualHB[3*j + k].out;
                num =1;
            }

        }

        bagel = num==0?1:0 ;
    }
 log(bagel);
    log(hit);
    log(blow);

    component hitverify = IsEqual();
    hitverify.in[0] <== pubNumHit;
    hitverify.in[1] <== hit;
    hitverify.out === 1;

    component blowverify= IsEqual();
    blowverify.in[0] <== pubNumBlow;
    blowverify.in[1] <== blow;
    blowverify.out === 1;

    component bagelverify= IsEqual();
    bagelverify.in[0] <== pubNumBagel;
    bagelverify.in[1] <== bagel;
    blowverify.out === 1;

    component poseidon = Poseidon(4);

    // log(bagel);
    // log(hit);
    // log(blow);
    poseidon.inputs[0] <== privsalt;
    log(poseidon.inputs[0]);
    log(privsalt);
    poseidon.inputs[1] <== pubNumguessA;
    poseidon.inputs[2] <== pubNumguessB;
    poseidon.inputs[3] <== pubNumguessC;
    log(poseidon.inputs[1]);
    log(poseidon.inputs[2]);
    log(poseidon.inputs[3]);
    log(pubNumguessA);
    log(pubNumguessB);
    log(pubNumguessC);
    SolnhashOut <== poseidon.out;
    log(SolnhashOut);
    // pubSolnhash ===SolnhashOut;

}

component main{public [pubNumguessA,pubNumguessB,pubNumguessC,pubNumHit,pubNumBlow,pubNumBagel,pubSolnhash]} = MastermindVariation();

/*
   INPUT={
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
   */