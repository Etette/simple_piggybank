// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import { PiggyBank } from "../src/piggybank.sol";
import {MyToken} from "../src/ERC20.sol";



contract deployPiggyBank is Script {
    MyToken public token;
    PiggyBank public piggyBank;

    address public owner;
    address public user;
    address public approver1;
    address public approver2;
    address[] public approvers;

    uint256 public goalAmount = 1000 * 10 ** 18; // 1000 tokens
    uint256 public deadline;

    function run() external {
        owner = msg.sender;
        user = vm.addr(1);
        approver1 = vm.addr(2);
        approver2 = vm.addr(3);
        approvers.push(approver1);
        approvers.push(approver2);

        vm.startBroadcast(owner);

        // Deploy SimpleERC20 token
        token = new MyToken(1000000 * 10 ** 18);

        // Distribute tokens
        token.transfer(user, 500 * 10 ** 18);
        token.transfer(approver1, 500 * 10 ** 18);
        token.transfer(approver2, 500 * 10 ** 18);

        // Set the deadline
        deadline = block.timestamp;

        // Deploy PiggyBank contract
        piggyBank = new PiggyBank(address(token), goalAmount, deadline, approvers, 2);
        vm.stopBroadcast();

        // Approve PiggyBank contract to spend tokens and deposit as user
        vm.startBroadcast(owner);
        token.approve(address(piggyBank), goalAmount); // Approve exact goal amount

        // Deposit tokens to reach the goal
        piggyBank.deposit(goalAmount);

        vm.stopBroadcast();

        // extend to after the deadline
        vm.warp(deadline + 1 days);

        // Withdraw tokens as the owner
        vm.startBroadcast(owner);
        piggyBank.withdraw(goalAmount);

        vm.stopBroadcast();
    }
}
