// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/gpu.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        new GPUApproval(0x6728686aDB3356C2E10C64AD0A4e2bCCA77EdaCb);
        vm.stopBroadcast();
    }
}

