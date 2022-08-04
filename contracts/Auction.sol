pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Auction is Ownable {
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

    uint256 immutable minAmount;
    uint256 idBid;
    address bidToken;

    mapping(uint256 => Bid) bids;
    mapping(address => bool) whiteList;
    mapping(address => mapping(uint256 => uint256)) bidAmount;

    constructor(address bidToken_, uint256 minAmount_) {
        bidToken = bidToken_;
        minAmount = minAmount_;
    }

    function addBid(
        address NFT,
        uint256 endTime_,
        uint24 minAmount_
    ) external onlyOwner {
        Bid storage bid = bids[idBid];
        bid.NFT = NFT;
        bid.endTime = block.timestamp + endTime_;
        bid.minAmountforBid = minAmount_;
        bid.status = StatusBid.TRADE;
        ++idBid;
    }

    function closeBid(uint256 id) external onlyOwner {
        Bid storage bid = bids[id];
        require(bid.status == StatusBid.TRADE, "Bid is buy");
        bid.status = StatusBid.BUY;
    }

    function placeBet(uint256 amount, uint256 id) external {
        Bid storage bid = bids[id];
        require(bid.status == StatusBid.TRADE, "Bid is buy");
        bidAmount[msg.sender][id] += amount;
    }

    function addGuestForBid(address guest) external {
        whiteList[guest] = true;
    }

    function buyBidToken(uint256 amount) external payable {
        require(
            msg.value >= minAmount,
            "Auction: Invested amount is too small"
        );
        uint256 BToken = msg.value / priceToken;
    }

    function getFee() internal {}
}
