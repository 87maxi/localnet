// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

contract DepositContract {
    bytes32 public deposit_root;
    
    event DepositEvent(
        bytes pubkey,
        bytes withdrawal_credentials,
        bytes amount,
        bytes signature,
        bytes index
    );
    
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials, 
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable {
        require(msg.value == 32 ether, "Deposit must be 32 ETH");
        emit DepositEvent(
            pubkey, 
            withdrawal_credentials, 
            abi.encodePacked(msg.value), 
            signature, 
            abi.encodePacked(uint64(0))
        );
    }
    
    function get_deposit_root() external view returns (bytes32) {
        return deposit_root;
    }
}