const { expect, assert } = require("chai");
const { ethers, waffle, network } = require("hardhat");
//const provider = waffle.provider;
const { parseEther } = require("ethers/lib/utils");
const { utils, BigNumber } = require("ethers");
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const {
    getBlockTime,
    timeShift,
    timeShiftBy,
    prepareContract,
    getABICreateBidFunction,
    getABICloseBidFunction
} = require("../utils/utils");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("Council test", function () {
    beforeEach(async function () {
        [owner, member1, member2, member3, member4, member5, member6, ...addrs] = await ethers.getSigners();
        [testNFT, council, auction, bidToken] = await prepareContract();
    });

    it("Council: Should't call function createBid(address, uint256, uint24)", async () => {
        await expect(auction.createBid(testNFT.address, 300, 1)).to.be.revertedWith("Auction: You aren't council");
    });

    it("Council: Should't call function closeBid( uint256)", async () => {
        await expect(auction.closeBid(1)).to.be.revertedWith("Auction: You aren't council");
    });

    it("Council: Should't call function closeBid( uint256)", async () => {
        await expect(auction.closeBid(1)).to.be.revertedWith("Auction: You aren't council");
    });

    it("Council: Should't call fucntion excecuteTransaction(uint256) because council doesn't approve", async () => {
        let callFunc = getABICreateBidFunction(testNFT.address, 50, 100);
        await expect(council.addTransaction(callFunc)).to.be.revertedWith("Council: You aren't owner");
        await expect(auction.createBid(testNFT.address, 300, 1)).to.be.revertedWith("Auction: You aren't council");
        await council.connect(member1).addTransaction(callFunc);
        await expect(council.connect(member1).excecuteTransaction(0)).to.be.revertedWith("Council: This transaction had little approval");
        await council.connect(member1).voteTransaction(0, false);
        await council.connect(member2).voteTransaction(0, true);
        await council.connect(member3).voteTransaction(0, true);
        await expect(council.connect(member3).excecuteTransaction(0)).to.be.revertedWith("Council: This transaction had little approval");

    });

    it("Council: Should call fucntion createBid(address, uint256, uint24)", async () => {
        let callFunc = getABICreateBidFunction(testNFT.address, 50, 100);
        await expect(council.addTransaction(callFunc)).to.be.revertedWith("Council: You aren't owner");
        await expect(auction.createBid(testNFT.address, 300, 1)).to.be.revertedWith("Auction: You aren't council");
        await council.connect(member1).addTransaction(callFunc);
        await expect(council.connect(member1).excecuteTransaction(0)).to.be.revertedWith("Council: This transaction had little approval");
        await council.connect(member1).voteTransaction(0, true);
        await council.connect(member2).voteTransaction(0, true);
        await council.connect(member3).voteTransaction(0, true);
        await expect(council.connect(member3).excecuteTransaction(0)).to.emit(council, 'ExcecuteTransaction').withArgs(0, 3);
    });

    it("Council: Should include/exclude to council", async () => {
        let callFunc = getABICreateBidFunction(testNFT.address, 50, 100);
        await expect(council.connect(member6).addTransaction(callFunc)).to.be.revertedWith("Council: You aren't owner");
        await council.connect(member5).includeToCouncil(member6.address);
        await council.connect(member6).excludeFromCouncil(member5.address);
        await expect(council.connect(member5).addTransaction(callFunc)).to.be.revertedWith("Council: You aren't owner");
    });

});
