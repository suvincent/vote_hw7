const VoteBuild = require('./build/Ballot.json');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
console.log(web3.utils.asciiToHex("random",32))

//console.log(VoteBuild.abi)
// console.log(VoteBuild.evm.bytecode)
// for (var i in VoteBuild){
//     console.log(i)
// }
async function deployFunction(){
var accounts = await web3.eth.getAccounts();
try{
var Election = await new web3.eth.Contract(VoteBuild.abi)
              .deploy({ data: '0x'+VoteBuild.evm.bytecode.object,arguments:[0,1]})
              .send({ from: accounts[0],gas:30000000000000,gasPrice: '45000000000000' });
//   console.log(Election)
}
catch(e){
    // console.log(e.message);
}
}

// deployFunction()