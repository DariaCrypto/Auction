// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Council {
    address auction;
    address[] owners;
    uint256 internal minConfrimVoice;
    mapping(address => bool) isOwner;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    enum StatusTransaction {
        UNDEFINE,
        CREATE,
        VOTE,
        SUCCESS,
        FAIL
    }
    struct Transaction {
        bytes data;
        bool executed;
        uint256 numConfirmations;
        StatusTransaction status;
    }
    event ExcecuteTransaction(uint256 txId, StatusTransaction status);
    event AddTransaction(uint256 idTx, bytes data);
    event VoteToTransaction(uint256 idTx, address voter, bool answer);
    event SetAuctionAddress(address auction);
    event IncludeToCouncil(address account);
    event ExcludeToCouncil(address account);
    //TODO: remove array from contract
    Transaction[] public transactions;
    uint256 public counter;
    modifier onlyOwners() {
        require(isOwner[msg.sender], "Council: You aren't owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "Council: Tx does't exist");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "Council: Tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txId) {
        require(
            !isConfirmed[_txId][msg.sender],
            "Council: tx already confirmed"
        );
        _;
    }

    constructor(address[] memory owners_, uint256 minConfrimVoice_) {
        require(owners_.length > 0, "Council: Owners required");
        require(
            minConfrimVoice_ > 0 && minConfrimVoice_ <= owners_.length,
            "Council: Invalid number of required confirmations"
        );

        for (uint256 i = 0; i < owners_.length; i++) {
            address owner = owners_[i];

            require(owner != address(0), "Council: Invalid owner");
            require(!isOwner[owner], "Council: Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        minConfrimVoice = minConfrimVoice_;
    }

    function addTransaction(bytes memory _data) public onlyOwners {
        transactions.push(
            Transaction({
                data: _data,
                executed: false,
                numConfirmations: 0,
                status: StatusTransaction.CREATE
            })
        );
        emit AddTransaction(transactions.length, _data);
    }

    function voteTransaction(uint256 txId, bool answer) external onlyOwners {
        Transaction storage tX = transactions[txId];
        require(
            tX.executed == false,
            "Council: You need to create a transaction"
        );
        //check to optimize gas! STORAGE
        tX.status = StatusTransaction.VOTE;
        if (answer) ++tX.numConfirmations;
        isConfirmed[txId][msg.sender] = answer;
        emit VoteToTransaction(txId, msg.sender, answer);
    }

    function excecuteTransaction(uint256 txId)
        external
        onlyOwners
        txExists(txId)
        notExecuted(txId)
    {
        Transaction storage tX = transactions[txId];
        require(
            tX.numConfirmations >= minConfrimVoice,
            "Council: This transaction had little approval"
        );

        (bool success, ) = auction.call{value: 0}(tX.data);
        success
            ? tX.status = StatusTransaction.SUCCESS
            : tX.status = StatusTransaction.FAIL;
        tX.executed = true;
        emit ExcecuteTransaction(txId, tX.status);
    }

    function setAuctionAddress(address auction_) external onlyOwners {
        auction = auction_;
        emit SetAuctionAddress(auction_);
    }

    function includeToCouncil(address account) external onlyOwners {
        isOwner[account] = true;
        emit IncludeToCouncil(account);
    }

    function excludeFromCouncil(address account) external onlyOwners {
        isOwner[account] = false;
        emit ExcludeToCouncil(account);
    }
}
