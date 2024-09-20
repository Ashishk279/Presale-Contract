//SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    address admin;

    constructor() ERC20("Tether USD", "USDT") {
        admin = msg.sender;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6; 
    }

    function burn(uint256 amount) external {
        require(
            balanceOf(msg.sender) >= amount,
            "you dont have enough token to burn"
        );
        _burn(msg.sender, amount);
    }
}