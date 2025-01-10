//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Test,console} from "forge-std/Test.sol";
import {FundContract} from "../../src/fundme.sol";
import {Deployfundme} from "../../script/fundme.s.sol";
// 1. Unit Testing: Tests individual contract functions in isolation.
// 2. Integration Testing: Verifies interactions between multiple contracts.
// 3. Forked Testing: Simulates testing on a forked mainnet or testnet environment.
// 4. Staging Testing: Validates the contract in a production-like environment before deployment.
contract test_fundme is Test{
    FundContract obj;

    //Normal variables for testing :
    address USER=makeAddr("user");
    uint256 constant send_value=0.1 ether;
    uint256 constant starting_balance=10 ether;
    function setUp() external{
        Deployfundme deployfundme=new Deployfundme();
        obj=deployfundme.run();
        vm.deal(USER,starting_balance);
        // assert(1==1);
    }
    function testMindollars() view public{
        assert(obj.minUSD()==0.01 * 1e18);
    }
    //To test a particular test function: use below cmd:
    //forge test --fork-url $sepolia_rpc_url --match-test testVersion
    function testVersion() view public{
        uint256 version=obj.getversion();
        console.log(version);
        assert(version==4);
    }
    function testFundFails()public{
        vm.expectRevert();//Shortcut to validate for the next line to fail ;
        obj.fund{value:2}();
    }
    function testFundUpdatesDataStructure()public{
        vm.prank(USER);
        obj.fund{value:send_value}();
        uint amountfunded=obj.getAddToAmountFunded(USER);
        assert(amountfunded==send_value);
    }
    function testOnlyOwnerWithDrawsMoney()public{
        vm.expectRevert();
        vm.prank(USER);
        //Since user is not the owner 
        //(only owners can withdraw money) it reverts;
        obj.withDraw();
    }


    modifier funded() {
        vm.deal(USER, send_value); // Assign Ether to the USER address
        vm.prank(USER);            // Simulate the USER making the call
        obj.fund{value: send_value}(); // Fund the contract
        _;
    }

    function testwithDrawWithaSingleFunder()public funded{
        //Arrange 
        uint256 startingOwnerBalance=obj.getOwner().balance;
        uint256 startingobjBalance=address(obj).balance;
        //Act
        vm.prank(obj.getOwner());
        obj.withDraw();
        //Assert
        uint256 endingOwnerBalance=obj.getOwner().balance;
        uint256 endingobjBalance=address(obj).balance;
        // console.log(endingOwnerBalance);
        assert(endingobjBalance==0);
        assert(endingOwnerBalance==startingOwnerBalance+startingobjBalance);
    }
    //Explanation for above Function:
    // This Solidity code tests the `withDraw` function of a smart contract. It uses a `funded` modifier to ensure the contract is pre-funded before running the test. The test:

    // 1. Simulates funding the contract by a user (`USER`) with a specified amount (`send_value`).
    // 2. Records the initial balances of the contract and its owner.
    // 3. Calls the `withDraw` function as the contract owner to transfer all funds from the contract to the owner's account.
    // 4. Verifies that:
    // - The contract's balance becomes zero.
    // - The owner's balance increases by the withdrawn amount. 

    // The code efficiently uses the `funded` modifier and Foundry's `vm.prank` for simulation.


    function testWithMultipleFunders() public {
        // Arrange: Simulate multiple funders contributing to the contract
        for (uint160 i = 1; i < 10; i++) {
            vm.deal(address(i), send_value); // Assign Ether to the funder's address
            vm.prank(address(i));           // Simulate the funder's call
            obj.fund{value: send_value}();  // Fund the contract

            // Note: Alternatively, we could use the hoax(address, amount) cheat code
            // which combines vm.deal and vm.prank in a single step.
        }

        // Act: Record starting balances before withdrawal
        uint256 startingOwnerBalance = obj.getOwner().balance;  // Get owner's balance
        uint256 startingObjBalance = address(obj).balance;      // Get contract's balance

        vm.prank(obj.getOwner()); // Simulate the owner calling withdraw
        obj.withDraw();

        // Assert: Verify the contract's balance is zero
        assert(address(obj).balance == 0);

        // Assert: Verify the owner's balance has increased appropriately
        assert(
            startingOwnerBalance + startingObjBalance == obj.getOwner().balance
        );
    }
}