// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SkyLinkToken is ERC20, ERC20Burnable {
    using SafeMath for uint256;

    // Tax 2.5%
    uint256 private constant _taxFee = 25;

    // Burn 0.5%
    uint256 private constant _burnFee = 5;

    // Address for SkyLink treasury Contract
    address private constant _treasury = 0x1AB6B4e4A368289f1E0fF6257D0526939f554698;

    // Address for market
    address private constant _market = 0x563394929fea4b4029BB2552Dd94Efad23EE0e18;

    // Mapping owner address to tax status
    mapping(address => bool) private _feeWhiteList;

    constructor() ERC20("SkyLink Token", "SKY") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());

        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[_treasury] = true;
        _feeWhiteList[_market] = true;
    }

    function send(address[] calldata addresses, uint256 amount) public {
        for (uint256 i = 0;i < addresses.length;i++) {
            address to = addresses[i];
            transfer(to, amount);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            // tax
            uint256 taxAmount = amount.mul(_taxFee).div(1000);
            super._transfer(from, _treasury, taxAmount);

            // burn
            uint256 burnAmount = amount.mul(_burnFee).div(1000);
            super._burn(from, burnAmount);

            amount = amount.sub(taxAmount).sub(burnAmount);
        }
        super._transfer(from, to, amount);
    }
}
