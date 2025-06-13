// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import "../src/GPUQToken.sol";

contract DeployToken is Script {
    function run() external {
        vm.startBroadcast();
        new GPUQToken(100000e18);
        vm.stopBroadcast();
    }
}
