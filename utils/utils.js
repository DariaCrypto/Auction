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

const prepareEmptyStand = async (ethers) => {
    const mintableAmount = BigNumber.from(tokens(8_000_000));

    // Council
    Council = await ethers.getContractFactory("Council");
    council = await Council.deploy();
    await council.deployed();

    // Auction
    Auction = await ethers.getContractFactory("Auction");
    auction = await upgrades.deployProxy(Auction);
    await auction.deployed();

    //BidToken
    BidToken = await ethers.getContractFactory("BidToken");
    bidToken = await BidToken.deploy(freeBetNFT.address);
    await bidToken.deployed();


    return [council, auction, bidToken];
};