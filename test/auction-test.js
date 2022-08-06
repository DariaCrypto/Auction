const { expect } = require("chai");
const { ethers, waffle, network } = require("hardhat");
const provider = waffle.provider;
const { parseEther } = require("ethers/lib/utils");
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Auction prepare", function () {
    beforeEach(async function () {
        [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    });
});
