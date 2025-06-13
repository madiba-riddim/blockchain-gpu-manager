// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title GPUQToken
 * @notice 1 token represents permission to book a GPU once.
 *         The professor (deployer) receives the initial supply
 *         and can distribute / sell / airdrop to students.
 */
contract GPUQToken is ERC20 {
    constructor(uint initialSupply) ERC20("GPU Quota Token", "GPUQ") {
        _mint(msg.sender, initialSupply);
    }
}