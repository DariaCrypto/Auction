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
let AMOUNT_ETH = utils.parseEther('1');
let SMALL_AMOUNT_ETH = utils.parseEther('0.1');
let FEE_PLATFORM = 2;
describe("Auction test", function () {
    beforeEach(async function () {
        [owner, council1, council2, council3, council4, council5, council6, member1, member2, member3, member4, member5, ...addrs] = await ethers.getSigners();
        [testNFT, council, auction, bidToken] = await prepareContract();
        let allowAmount = BigInt(100000 * 1e18);
        await bidToken.approve(member1.address, allowAmount);
        await bidToken.approve(member2.address, allowAmount);
        await bidToken.approve(member3.address, allowAmount);
        await bidToken.approve(member4.address, allowAmount);
        await bidToken.approve(member5.address, allowAmount);
    });

    it("Auction: Shouldn't call fucntion placeBet(uint256, uint256)", async () => {
        let callFunc = getABICreateBidFunction(testNFT.address, 50, 100);
        await council.connect(council1).addTransaction(callFunc);
        await council.connect(council1).voteTransaction(0, true);
        await council.connect(council2).voteTransaction(0, true);
        await council.connect(council3).voteTransaction(0, true);
        await council.connect(council3).excecuteTransaction(0);
        await expect(auction.placeBet(100, 0)).to.be.rejectedWith("Auction: You aren't member");
    });

    it("Auction: Shouldn call fucntion placeBet(uint256, uint256)", async () => {
        let callFunc = getABICreateBidFunction(testNFT.address, 50, 100);
        await council.connect(council1).addTransaction(callFunc);
        await council.connect(council1).voteTransaction(0, true);
        await council.connect(council2).voteTransaction(0, true);
        await council.connect(council3).voteTransaction(0, true);
        await council.connect(council3).excecuteTransaction(0);
        await expect(auction.placeBet(100, 0)).to.be.rejectedWith("Auction: You aren't member");
        await auction.connect(member1)["buyBidToken()"]({ value: AMOUNT_ETH });
        await expect(auction.connect(member1).placeBet(100, 0)).to.be.rejectedWith("You don't have a lot of tokens");
        amountBidToken = parseFloat(0.98 / utils.parseEther('0.1')).toString();
        expectResult = await bidToken.balanceOf(member1.address);
        expect(expectResult.toString()).to.be.equal(amountBidToken);

    });


});