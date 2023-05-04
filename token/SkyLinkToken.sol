// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SkyLinkToken is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    uint256 private taxFee           = 25;
    uint256 private burnFee          = 5;
    address public  treasury         = 0x38dFf29a1D010AcCDdB2bf840C8b98Df33eE98b5;

    mapping(address => bool) private _feeWhiteList;

    constructor() ERC20("SkyLink Token", "SKY") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());

        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[treasury]   = true;
    }

    function setTreasuryAddress(address ts) external onlyOwner {
        require(ts != address(0), "ERC20: zero address");
        _feeWhiteList[treasury] = false;
        treasury = ts;
        _feeWhiteList[treasury] = true;
    }

    function setFeeWhiteList(address[] calldata accounts, bool enable) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = enable;
        }
    }

    function checkAddressFee(address account) public view returns(bool) {
        return _feeWhiteList[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            // tax
            uint256 taxAmount = amount.mul(taxFee).div(1000);
            super._transfer(from, treasury, taxAmount);

            // burn
            uint256 burnAmount = amount.mul(burnFee).div(1000);
            super._burn(from, burnAmount);

            amount = amount.sub(taxAmount).sub(burnAmount);
        }
        super._transfer(from, to, amount);
    }

    function send(address[] calldata addresses, uint256 amount) public {
        for (uint256 i = 0;i < addresses.length;i++) {
            address to = addresses[i];
            transfer(to, amount);
        }
    }
}