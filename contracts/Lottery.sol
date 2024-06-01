// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Lottery is VRFConsumerBaseV2Plus {

    address[] public players;
    uint256 public usdEntryFee; 
    AggregatorV3Interface internal priceFeed;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;
    address public recentWinner;

    bytes32 immutable public KEY_HASH;
    uint256 immutable public SUBSCRIPTION_ID;
 
    // Constants
    uint32 constant public CALLBACK_GAS_LIMIT = 1000000;
    uint16 constant public REQUEST_CONFORMATIONS = 3;
    uint32 constant public NUM_WORDS = 1;

    event RequestedRandomWords(uint256 requestId);

    error unauthorizedAccessException(address expected, address received);
    error lotteryStateException(LOTTERY_STATE expectedState, LOTTERY_STATE actualState);
    error insufficientEtherException(uint256 expectedAmount, uint256 actualAmount);
    error InvalidPriceFeedDataException(); 
    error entryFeeTooLowException();
    error ethPriceTooLowException();
    error incorrectRandomValueException();
    error costTooLowException();

    constructor(address _priceFeedAddress, address _vrfCoordinator, uint256 _subscriptionId, bytes32 _keyHash) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        usdEntryFee = 50;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        KEY_HASH = _keyHash;
        SUBSCRIPTION_ID = _subscriptionId;
    }

    function enter() public payable {
        if(lottery_state != LOTTERY_STATE.OPEN){
            revert lotteryStateException(LOTTERY_STATE.OPEN, lottery_state);
        } 

        if(msg.value < getEntranceFee()){
            revert insufficientEtherException(getEntranceFee(), msg.value);
        }

        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        (,int answer,,,) = priceFeed.latestRoundData();
        if(answer <= 0){
            revert InvalidPriceFeedDataException();
        }

        uint256 ethPrice = uint256(answer) * 1e10; 
        uint256 adjustedUsdEntryFee = usdEntryFee * 1e18;
        
        if(adjustedUsdEntryFee <= 0){
            revert entryFeeTooLowException();
        }

        if(ethPrice <= 0){
            revert ethPriceTooLowException();
        }

        uint256 costToEnter = (adjustedUsdEntryFee * 1e18) / ethPrice;

        if(costToEnter <= 0){
            revert costTooLowException();
        }

        return costToEnter;        
    }

    function startLottery() public onlyOwner() {
        if(lottery_state != LOTTERY_STATE.CLOSED){
            revert lotteryStateException(LOTTERY_STATE.CLOSED, lottery_state);
        }     

        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner() {
        if(lottery_state != LOTTERY_STATE.OPEN){
            revert lotteryStateException(LOTTERY_STATE.OPEN, lottery_state);
        }

        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;

        // Requesting a random number from the oracle network
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: KEY_HASH,
                subId: SUBSCRIPTION_ID,
                requestConfirmations: REQUEST_CONFORMATIONS,
                callbackGasLimit: CALLBACK_GAS_LIMIT,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        emit RequestedRandomWords(requestId);
    }

    function fulfillRandomWords(uint256, uint256[] calldata _randomWords) internal override {
        if(lottery_state != LOTTERY_STATE.CALCULATING_WINNER){
            revert lotteryStateException(LOTTERY_STATE.CALCULATING_WINNER, lottery_state);
        } 

        if(_randomWords[0] <= 0){
            revert incorrectRandomValueException();
        }

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