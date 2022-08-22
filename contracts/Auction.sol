// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./interfaces/IBidToken.sol";
import "./interfaces/IERC721NFT.sol";

contract Auction {
    enum StatusBid {
        UNDEFINE,
        TRADE,
        BUY
    }

    struct AuctionInfo {
        uint256 allFee;
        uint256 allPayToMember;
        address bidToken;
        address council;
        uint8 platformFee;
    }

    struct Bid {
        uint24 minAmountforBid;
        address NFT;
        StatusBid status;
    }

    struct Winner {
        address winerBid;
        uint256 highAmountBid;
    }
    /**
     *@notice Emitted when create the bet
     *@param id bet identifier
     *@param NFT address NFT token for the bet
     *@param minAmount minimal amount for the bet
     **/
    event CreateBid(uint256 id, address NFT, uint256 minAmount);

    /**@notice Emitted when close the bet
     *@param id bet identifier
     *@param winner address member who win the bet
     **/
    event CloseBid(uint256 id, address winner);

    /**
     *@notice Emitted when place a bet
     *@param account who place the bet
     *@param amount bet tokens
     *@param id bet identifier
     */
    event PlaceForBet(address account, uint256 amount, uint256 id);

    /**
     *@notice Emitted when add a member for the auction
     *@param guest address add for the auction
     *@param amount invested amount
     */
    event AddMemberForBet(address guest, uint256 amount);

    /**
     *@notice Emitted when the member buy token for the auction
     *@param account address who buy tokens for the auction
     *@param feeAmount amount that transfer to platform
     *@param amountBuyToken amount buyed tokens
     */
    event BuyBidToken(
        address account,
        uint256 feeAmount,
        uint256 amountBuyToken
    );

    uint256 internal constant PRECISION = 1e18;
    uint256 internal constant PRICE_TO_BID = 0.3 ether;
    uint256 immutable minAmount;
    AuctionInfo internal auctionInfo;
    uint256 idBid;

    mapping(uint256 => Bid) bids;
    mapping(uint256 => Winner) winnerBid;
    mapping(address => bool) memberList;
    mapping(address => mapping(uint256 => uint256)) bidAmount;

    modifier onlyMembers() {
        require(memberList[msg.sender], "Auction: You aren't member");
        _;
    }

    modifier onlyContract() {
        require(
            msg.sender == auctionInfo.council,
            "Auction: You aren't council"
        );
        _;
    }

    constructor(
        address counsil_,
        uint256 minAmount_,
        uint8 platformFee_
    ) {
        minAmount = minAmount_;
        auctionInfo.council = counsil_;
        auctionInfo.platformFee = platformFee_;
    }

    /**
     *@notice Get information about auction
     */
    function getAuctionInfo() external view returns (AuctionInfo memory) {
        return
            AuctionInfo(
                auctionInfo.allFee,
                auctionInfo.allPayToMember,
                auctionInfo.bidToken,
                auctionInfo.council,
                auctionInfo.platformFee
            );
    }

    /**
     *@notice Create the bid for auction with the NFT
     *@param NFT address NFT token for the bet
     *@param endTime_ time when the bid create(add future)
     *@param minAmount_ minimal amount for the bet
     */
    function createBid(
        address NFT,
        uint256 endTime_,
        uint24 minAmount_
    ) external onlyContract {
        Bid storage bid = bids[idBid];
        bid.NFT = NFT;
        bid.minAmountforBid = minAmount_;
        bid.status = StatusBid.TRADE;
        ++idBid;
        emit CreateBid(idBid, NFT, minAmount_);
    }

    /**
     *@notice Close the bid and transfer the NFT to winner
     *@param id bet identifier
     */
    function closeBid(uint256 id) external onlyContract {
        Bid storage bid = bids[id];
        require(bid.status != StatusBid.BUY, "Auction: Bet is buy");
        bid.status = StatusBid.BUY;
        Winner storage win = winnerBid[id];
        IERC721(bid.NFT).safeTransferFrom(address(this), win.winerBid, id);
        emit CloseBid(id, win.winerBid);
    }

    /**
     *@notice Place the bet
     *@param amount bet for the bid
     *@param id bet identifier
     */
    function placeBet(uint256 amount, uint256 id) external onlyMembers {
        Bid storage bid = bids[id];
        require(bid.status != StatusBid.BUY, "Auction: Bid is buy");
        require(amount >= bid.minAmountforBid, "Auction: Your amount is less");
        require(
            IBidToken(auctionInfo.bidToken).balanceOf(msg.sender) >= amount,
            "Auction: You don't have a lot of tokens"
        );
        bidAmount[msg.sender][id] += amount;
        Winner storage win = winnerBid[id];
        if (amount > win.highAmountBid) {
            win.highAmountBid = amount;
            win.winerBid = msg.sender;
        }
        emit PlaceForBet(msg.sender, amount, id);
    }

    /**
     *@notice Buy token for the auction
     */
    function buyBidToken() external payable {
        require(
            msg.value >= PRICE_TO_BID,
            "Auction: Invested amount is too small"
        );
        uint256 feeAmount = _calcPercent(msg.value, auctionInfo.platformFee);
        auctionInfo.allFee += feeAmount;
        uint256 cleanAmount = msg.value - feeAmount;

        uint256 amountBuyToken = ((cleanAmount * PRECISION) /
            IBidToken(auctionInfo.bidToken).getPrice());
        auctionInfo.allPayToMember += msg.value;
        memberList[msg.sender] = true;
        IBidToken(auctionInfo.bidToken).transfer(msg.sender, amountBuyToken);
        emit BuyBidToken(msg.sender, feeAmount, amountBuyToken);
    }

    /**
     *@notice Buy token for the auction
     *@param tokenAddress new the bid token address
     */
    function setToken(address tokenAddress) external {
        require(
            tokenAddress != address(0),
            "Auction: Token address can't equal address(0) "
        );
        auctionInfo.bidToken = tokenAddress;
    }

    function _calcPercent(uint256 value, uint256 percent)
        internal
        pure
        returns (uint256 res)
    {
        return ((percent * value) / (100));
    }
}
