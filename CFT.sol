// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ChainForgeToken is ERC20 {
    address public admin;
    address public presaleContract;


    constructor() ERC20("ChainForgeToken", "CFT") {
        admin = msg.sender;
    }

    function mint(address to, uint256 tokens) external {
        require(
            msg.sender == presaleContract,
            "Only presaleContract mint the tokens."
        );
        require(to != address(0), "to address != 0");
        require(tokens > 0, "Tokens > 0");
        _mint(to, tokens);
    }

    function approve(address spender, uint256 tokens) public override returns (bool) {
        require(msg.sender == admin, "Only admin");
        _approve(admin, spender, tokens);
        return true;
    }


    function setPresaleContractAddress(address presaleContractAddress)
        external
    {
        require(
            presaleContract == address(0),
            "Token_1155: Property contract already set"
        );
        presaleContract = presaleContractAddress;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
