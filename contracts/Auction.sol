// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./interfaces/IBidToken.sol";

contract Auction {
    enum StatusBid {
        UNDEFINE,
        TRADE,
        BUY
    }

    struct Bid {
        uint256 endTime;
        uint24 minAmountforBid;
        address NFT;
        StatusBid status;
    }

    struct Winner {
        address winerBid;
        uint256 highAmountBid;
    }
    event CreateBid(uint256 id, address NFT, uint256 time, uint256 minAmount);
    event CloseBid(uint256 id, address winner);
    event PlaceForBet(address account, uint256 amount, uint256 id);
    event AddMemberForBid(address guest, uint256 amount);
    event BuyBidToken(
        address account,
        uint256 feeAmount,
        uint256 amountBuyToken
    );

    uint256 immutable minAmount;
    uint256 idBid;

    address bidToken;
    address council;
    uint8 platformFee;
    uint256 constant PRICE_TO_BID = 0.3 ether;

    //Check gas! Maybe union varables in one struct
    uint256 allFee;
    uint256 allPayToMember;
    /////

    mapping(uint256 => Bid) bids;
    mapping(uint256 => Winner) winnerBid;
    mapping(address => bool) memberList;
    mapping(address => mapping(uint256 => uint256)) bidAmount;

    modifier onlyMembers() {
        require(memberList[msg.sender], "Auction: You aren't member");
        _;
    }

    modifier onlyContract() {
        require(msg.sender == council, "Auction: You aren't council");
        _;
    }

    constructor(
        address counsil_,
        address bidToken_,
        uint256 minAmount_,
        uint8 platformFee_
    ) {
        bidToken = bidToken_;
        minAmount = minAmount_;
        //fee to platform
        council = counsil_;
        platformFee = platformFee_;
    }

    function createBid(
        address NFT,
        uint256 endTime_,
        uint24 minAmount_
    ) external onlyContract {
        Bid storage bid = bids[idBid];
        bid.NFT = NFT;
        bid.endTime = block.timestamp + endTime_;
        bid.minAmountforBid = minAmount_;
        bid.status = StatusBid.TRADE;
        ++idBid;
        emit CreateBid(idBid, NFT, block.timestamp + endTime_, minAmount_);
    }

    function closeBid(uint256 id) external onlyContract {
        Bid storage bid = bids[id];
        require(bid.status != StatusBid.BUY, "Bid is buy");
        bid.status = StatusBid.BUY;
        Winner storage win = winnerBid[id];
        emit CloseBid(id, win.winerBid);
    }

    function placeBet(uint256 amount, uint256 id) external onlyMembers {
        Bid storage bid = bids[id];
        require(bid.status != StatusBid.BUY, "Bid is buy");

        require(amount >= bid.minAmountforBid, "Your amount is less");
        require(
            IBidToken(bidToken).balanceOf(msg.sender) >= amount,
            "You don't have a lot of tokens"
        );
        bidAmount[msg.sender][id] += amount;
        Winner storage win = winnerBid[id];
        if (amount > win.highAmountBid) {
            win.highAmountBid = amount;
            win.winerBid = msg.sender;
        }
        emit PlaceForBet(msg.sender, amount, id);
    }

    function buyBidToken() external payable {
        require(
            msg.value >= PRICE_TO_BID,
            "Auction: Invested amount is too small"
        );
        uint256 feeAmount = _calcPercent(msg.value, platformFee);
        allFee += feeAmount;
        uint256 cleanAmount = msg.value - feeAmount;

        uint256 amountBuyToken = cleanAmount / IBidToken(bidToken).getPrice();
        allPayToMember += msg.value;
        memberList[msg.sender] = true;
        IBidToken(bidToken).transferFrom(bidToken, msg.sender, amountBuyToken);
        emit BuyBidToken(msg.sender, feeAmount, amountBuyToken);
    }

    function _calcPercent(uint256 value, uint256 percent)
        internal
        pure
        returns (uint256 res)
    {
        return ((percent * value) / (100));
    }
}
