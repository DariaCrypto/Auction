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

const prepareContract = async () => {
    const MINTABLE_AMOUNT = BigNumber.from(8_000_000);
    const PLATFORM_FEE = 2;
    const MIN_CONFRIM_VOICE = 3;
    [owner, addr1, addr2, addr3, addr4, addr5, ...addrs] = await ethers.getSigners();

    //Mock_NFT
    TestNFT = await ethers.getContractFactory("TestNFT");
    testNFT = await TestNFT.deploy();
    await testNFT.deployed();

    //BidToken
    BidToken = await ethers.getContractFactory("BidToken");
    bidToken = await BidToken.deploy(utils.parseEther('0.00000001'), MINTABLE_AMOUNT);
    await bidToken.deployed();


    // Council
    Council = await ethers.getContractFactory("Council");
    council = await Council.deploy([addr1.address, addr2.address, addr3.address, addr4.address, addr5.address], MIN_CONFRIM_VOICE);
    await council.deployed();

    // Auction
    Auction = await ethers.getContractFactory("Auction");
    auction = await Auction.deploy(council.address, bidToken.address, utils.parseEther('0.3'), PLATFORM_FEE);
    await auction.deployed();



    return [testNFT, council, auction, bidToken];
};
module.exports = {
    prepareContract,
    getBlockTime,
    timeShift,
    timeShiftBy
};