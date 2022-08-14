const { expect } = require("chai");
const { ethers, waffle, network } = require("hardhat");
//const provider = waffle.provider;
const { parseEther } = require("ethers/lib/utils");
const { utils, BigNumber } = require("ethers");

async function timeShift(time) {
    await network.provider.send("evm_setNextBlockTimestamp", [time]);
    await network.provider.send("evm_mine");
}

async function timeShiftBy(ethers, timeDelta) {
    let time = (await getBlockTime(ethers)) + timeDelta;
    await network.provider.send("evm_setNextBlockTimestamp", [time]);
    await network.provider.send("evm_mine");
}
async function getBlockTime(ethers) {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const time = blockBefore.timestamp;
    return time;
}

async function getABICreateBidFunction() {
    const ABI = ["function createBid(address NFT, uint256 endTime_, uint24 minAmount_)"];
    const interface = new ethers.utils.Interface(ABI);
    const txData = await interface.encodeFunctionData("createBid", [arguments[0], arguments[1], arguments[2]]);
    return txData;
}

async function getABICloseBidFunction() {
    const ABI = ["function closeBid(uint256 id)"];
    const interface = new ethers.utils.Interface(ABI);
    const txData = await interface.encodeFunctionData("closeBid", [arguments[0]]);
    return txData;
}



const prepareContract = async () => {
    const MINTABLE_AMOUNT = BigNumber.from(8_000_000).mul(BigNumber.from("10").pow(18)).toString();
    const PLATFORM_FEE = 2;
    const MIN_CONFRIM_VOICE = 3;
    [owner, member1, member2, member3, member4, member5, ...addrs] = await ethers.getSigners();

    //Mock_NFT
    TestNFT = await ethers.getContractFactory("TestNFT");
    testNFT = await TestNFT.deploy();
    await testNFT.deployed();

    // Council
    Council = await ethers.getContractFactory("Council");
    council = await Council.deploy([member1.address, member2.address, member3.address, member4.address, member5.address], MIN_CONFRIM_VOICE);
    await council.deployed();

    // Auction
    Auction = await ethers.getContractFactory("Auction");
    auction = await Auction.deploy(council.address, utils.parseEther('0.3'), PLATFORM_FEE);
    await auction.deployed();

    //BidToken
    BidToken = await ethers.getContractFactory("BidToken");
    bidToken = await BidToken.deploy(utils.parseEther('0.1'), MINTABLE_AMOUNT, auction.address);
    await bidToken.deployed();

    auction.setToken(bidToken.address);
    return [testNFT, council, auction, bidToken];
};
module.exports = {
    prepareContract,
    getBlockTime,
    timeShift,
    timeShiftBy,
    getABICreateBidFunction,
    getABICloseBidFunction
};