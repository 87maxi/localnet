#!/bin/bash

cd ../test;

# Compile the contract
forge compile;

# Deploy the contract
forge create ./src/MyERC20.sol:MyERC20 --rpc-url http://localhost:8545;