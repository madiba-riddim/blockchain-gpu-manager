// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/gpu.sol";

contract DeployScript is Script {
    function run() external {
        address professor = vm.envAddress("PROFESSOR"); // 教授錢包
        address token     = vm.envAddress("TOKEN");      // GPUQToken address
        vm.startBroadcast();
        new GPUApproval(professor, token);
        vm.stopBroadcast();
    }
}

