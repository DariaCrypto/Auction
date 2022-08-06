// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Council {
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
        address to;
        bytes data;
        bool executed;
        uint256 numConfirmations;
        uint256 value;
        StatusTransaction status;
    }
    Transaction[] public transactions;

    modifier onlyOwners() {
        require(isOwner[msg.sender], "Council: You are't owner");
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
        //Additional check addresses(maybe remove this fragment)
        for (uint256 i = 0; i < owners_.length; i++) {
            address owner = owners_[i];

            require(owner != address(0), "Council: Invalid owner");
            require(!isOwner[owner], "Council: Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        minConfrimVoice = minConfrimVoice_;
    }

    function addTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwners {
        transactions.push(
            Transaction({
                to: _to,
                data: _data,
                executed: false,
                value: _value,
                numConfirmations: 0,
                status: StatusTransaction.CREATE
            })
        );
    }

    function voteTransaction(uint256 txId, bool answer) external onlyOwners {
        Transaction storage tX = transactions[txId];
        tX.status = StatusTransaction.VOTE;
        answer ? ++tX.numConfirmations : --tX.numConfirmations;
        isConfirmed[txId][msg.sender] = answer;
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

        (bool success, ) = tX.to.call{value: 0}(tX.data);
        success
            ? tX.status = StatusTransaction.SUCCESS
            : tX.status = StatusTransaction.FAIL;
        require(success, "Council: Transaction fail");
    }

    function includeToCouncil(address account) external onlyOwners {
        isOwner[account] = true;
    }

    function excludeFromCouncil(address account) external onlyOwners {
        isOwner[account] = false;
    }
}
