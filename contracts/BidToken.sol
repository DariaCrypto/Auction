// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBidToken.sol";

contract BidToken is ERC20, Ownable {
    uint256 private price = 0.1 ether;

    constructor(
        uint256 price_,
        uint256 amountMint,
        address mintAddress
    ) ERC20("BidToken", "BD") {
        price = price_;
        _mint(mintAddress, amountMint);
    }

    function decimals() public view override returns (uint8) {
        return 18;
    }

    function setPrice(uint256 price_) external onlyOwner {
        require(price_ > 0, "Price can't equal 0");
        price = price_;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }
}
