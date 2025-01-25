// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

    contract Lottery {

        // define important variables for the lottery
        mapping (address => bool) private players;
        uint deadline = block.timestamp + 2 days;
        address payable [] users;

        // functions are ordered such a way that the functions are defined before the call happens.
        // below function implements randomness to return a index
        function random_winner_index() private view returns (uint){
            return uint(blockhash(block.timestamp%256))%users.length;
        }


        // transfers all the balance of this contract account after deadline ends
        function transfer_lottery() public  payable {
            require(deadline <= block.timestamp);
            users[random_winner_index()].transfer(address(this).balance);
        }

        //checks time, if its past deadline it will transfer all lottery to winner
        function Check_time() private {
            if(deadline <= block.timestamp){
                transfer_lottery();
            }
        }


        function Rules() public returns (string memory) {
            Check_time();
            return "cost 1 ether to join the lottery, the user must apply for the lottery themself and multiple entries are denied.\n the deadline to apply for lottery is 2 days from the block uptime";
        }

        function Lottery_money() public payable {
            // here we cannot use check time function as the required field below needs timestamp to be less than deadline
            // calling check time will get reverted and lottery transfer will not take place
            // even after the deadline ends, removing deadline from required field will cause 
            // the transfer of ether from sender to contract take place and deduct gas fee 


            //first check if the sender is the original sender and not through another contract
            //to make sure he does not make another entry into the lottery system
            //and the lottery requires 1 ether for player to join lottery
            require(msg.sender==tx.origin && msg.value == 1 ether && block.timestamp <= deadline && !players[msg.sender],
            "Please try again if you are following all the rules");

            // this indicates that the player has joined the lottery  
            players[msg.sender] = true;
            users.push(payable(msg.sender));
        }


    }