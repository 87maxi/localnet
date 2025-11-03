// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    
    function setUp() public {
        token = new ERC20Token(1000);
    }
    
    function testName() public {
        assertEq(token.name(), "Test Token");
    }
    
    function testSymbol() public {
        assertEq(token.symbol(), "TEST");
    }
    
    function testDecimals() public {
        assertEq(token.decimals(), 18);
    }
    
    function testTotalSupply() public {
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
    }
    
    function testInitialBalance() public {
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** 18);
    }
    
    function testTransfer() public {
        address sender = address(this);
        address recipient = address(0x4);
        uint256 amount = 100 * 10 ** 18;
        
        uint256 senderBalanceBefore = token.balanceOf(sender);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        
        assertTrue(token.transfer(recipient, amount));
        
        assertEq(token.balanceOf(sender), senderBalanceBefore - amount);
        assertEq(token.balanceOf(recipient), recipientBalanceBefore + amount);
    }
    
    function testTransferInsufficientBalance() public {
        address recipient = address(0x4);
        uint256 amount = 2000 * 10 ** 18;
        
        vm.expectRevert("Insufficient balance");
        token.transfer(recipient, amount);
    }
    
    function testApprove() public {
        address spender = address(0x4);
        uint256 amount = 100 * 10 ** 18;
        
        assertTrue(token.approve(spender, amount));
        assertEq(token.allowance(address(this), spender), amount);
    }
    
    function testTransferFrom() public {
        address from = address(this);
        address to = address(0x5);
        address spender = address(0x6);
        uint256 amount = 100 * 10 ** 18;
        
        token.approve(spender, amount);
        
        vm.prank(spender);
        assertTrue(token.transferFrom(from, to, amount));
        
        assertEq(token.balanceOf(from), (1000 * 10 ** 18) - amount);
        assertEq(token.balanceOf(to), amount);
        assertEq(token.allowance(from, spender), 0);
    }
    
    function testTransferFromInsufficientBalance() public {
        address from = address(this);
        address to = address(0x5);
        address spender = address(0x6);
        uint256 amount = 2000 * 10 ** 18;
        
        token.approve(spender, amount);
        
        vm.prank(spender);
        vm.expectRevert("Insufficient balance");
        token.transferFrom(from, to, amount);
    }
    
    function testTransferFromInsufficientAllowance() public {
        address from = address(this);
        address to = address(0x5);
        address spender = address(0x6);
        uint256 amount = 100 * 10 ** 18;
        
        vm.prank(spender);
        vm.expectRevert("Insufficient allowance");
        token.transferFrom(from, to, amount);
    }
}