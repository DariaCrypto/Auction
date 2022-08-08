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
    prepareContract
} = require("../utils/utils");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("Auction test", function () {
    beforeEach(async function () {
        [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
        [testNFT, council, auction, bidToken] = await prepareContract();
    });

    it("Auction: Should't call fucntion createBid(address, uint256, uint24)", async () => {
        await expect(auction.createBid(testNFT.address, 300, 1)).to.be.revertedWith("Auction: You are't council");
    });

    it("Auction: Should't call fucntion closeBid( uint256)", async () => {
        await expect(auction.closeBid(1)).to.be.revertedWith("Auction: You are't council");
    });

    it("Auction: Should't call fucntion closeBid( uint256)", async () => {
        await expect(auction.closeBid(1)).to.be.revertedWith("Auction: You are't council");
    });

    it("Auction: Should call fucntion createBid(address, uint256, uint24)", async () => {
        let callFunc = await council.getDataCreateBid("createBid(address NFT, uint256 endTime_, uint24 minAmount_)", testNFT.address, 40, 100);
        await expect(council.addTransaction(callFunc)).to.be.revertedWith("Council: You are't owner");
        await expect(auction.createBid(testNFT.address, 300, 1)).to.be.revertedWith("Auction: You are't council");
        await council.connect(addr1).addTransaction(callFunc);
        await expect(council.connect(addr1).excecuteTransaction(0)).to.be.revertedWith("Council: This transaction had little approval");
        await council.connect(addr1).voteTransaction(0, true);
    });

});
