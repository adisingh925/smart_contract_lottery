// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Lottery is Ownable, VRFConsumerBaseV2 {

    address[] public players;
    uint256 public usdEntryFee; 
    AggregatorV3Interface internal priceFeed;
    VRFCoordinatorV2Interface internal COORDINATOR;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyHash;
    address public recentWinner;
    uint256 public subscriptionId; 
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    event RequestedRandomWords(uint256 requestId);

    constructor(address _priceFeedAddress, address _vrfCoordinator, uint256 _subscriptionId, bytes32 _keyHash) Ownable(msg.sender) VRFConsumerBaseV2(_vrfCoordinator) {
        usdEntryFee = 50;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open!");
        require(msg.value >= getEntranceFee(), "Not Enough ETH!");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        (,int answer,,,) = priceFeed.latestRoundData();
        require(answer > 0, "Invalid price feed data");

        uint256 ethPrice = uint256(answer) * 1e10; 
        uint256 adjustedUsdEntryFee = usdEntryFee * 1e18;
        
        require(adjustedUsdEntryFee > 0, "USD entry fee is too low");
        require(ethPrice > 0, "ETH price is too low");

        uint256 costToEnter = (adjustedUsdEntryFee * 1e18) / ethPrice;

        require(costToEnter > 0, "Cost is too low!");

        return costToEnter;        
    }

    function startLottery() public onlyOwner {
        require(lottery_state == LOTTERY_STATE.CLOSED, "Can't start a new lottery yet!");
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public {
        require(lottery_state == LOTTERY_STATE.OPEN);
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;

        // Requesting a random number from the oracle network
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
       );

        emit RequestedRandomWords(requestId);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "Illegal function call!");
        require(_randomWords[0] > 0, "Incorrect Random Value");

        // Calculating the winner of the lottery
        uint256 winnerIndex = _randomWords[0] % players.length;
        recentWinner = players[winnerIndex];
        
        // Transfering all the money to the winner
        payable(recentWinner).transfer(address(this).balance);

        // Resetting the players list
        players = new address[](0);

        // Closing the lottery
        lottery_state = LOTTERY_STATE.CLOSED;
    }
}