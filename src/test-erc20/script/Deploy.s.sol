// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ERC20Token.sol";

contract Deploy is Script {
    function run() external {
        // Deploy the ERC20Token contract
        ERC20Token token = new ERC20Token("MyToken", "MTK", 1_000_000 * 10**18);
        
        // Log the deployed contract address
        vm.broadcast(); // Ensures transaction is sent from deployer
        console.log("ERC20Token deployed at: %s", address(token));
    }
}
