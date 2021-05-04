const assert = require('assert');
const ganache = require('ganache-cli');
const moment = require('moment');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const VoteBuild = require('../build/Ballot.json');

var accounts;
var Election;
var vst;
var vet;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  vst = moment().add(1,'M');
  // console.log(vst.valueOf())
  vet = vst.add(1,'M')
  // console.log(vet.valueOf())

  Election = await new web3.eth.Contract(VoteBuild.abi)
                .deploy({ data: '0x'+VoteBuild.evm.bytecode.object,arguments:[vst.valueOf(),vet.valueOf()]})
                .send({ from: accounts[0] ,gas: 1500000, gasPrice: '30000000000000'});
});

describe('Vote', () => {
  it('deploys a Vote', () => {
    console.log(Election.options.address)
    assert.ok(Election.options.address);
  });
  it('check vote start time and end time',async()=>{
    let t0 = await Election.methods.times(0).call()
    let t1 = await Election.methods.times(1).call()
    // console.log(t)
    assert.equal(vst.valueOf(),t0)
    assert.equal(vet.valueOf(),t1)
  });
  it('check if is setting time',async()=>{
    let flag = await Election.methods.blockOrTimeReached(0).call();
    let now = moment();
    console.log(now.valueOf())
    if(now < vst)
      assert.equal(true,flag)
    else
      assert.equal(false,flag)
  });
  it('check whether can propose',async()=>{
    accounts = await web3.eth.getAccounts();
    // QAQ's hash
    b32 = "0x950a0e4dd96d6d933eebd7dc069bb79722bf3a5706bceef9fa37f4cfc33613b9";
    try{
        await Election.methods.Proposed(1).send({ from: accounts[0] ,gas:300000});
        let p = Election.methods.proposals(0).call();
        assert.equal(p,1);
    }
    catch(e){
      console.log(e.message)
    }
    //let proposal = Election.methods.proposals(0).call()
    // assert.equal(true,true)
  });

  
});