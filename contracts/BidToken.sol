pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BidToken is ERC20 {
    uint256 public price = 1e17; // 0.1 ETH

    constructor(uint256 price_) ERC20("BidToken", "BD") {
        price = price_;
    }

    function setPrice(uint256 price_) external {
        require(price_ > 0, "Price can't equal 0");
        price = price_;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    function withdraw() external {}
}
