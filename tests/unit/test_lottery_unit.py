from brownie import network, VRFCoordinatorV2Mock
from web3 import Web3
from scripts.helpful_scripts import get_account, get_contract
from scripts.deploy import deploy_lottery
from web3 import Web3
import pytest

def test_get_entrance_fee():
    if network.show_active() in "mainnet-fork":
        lottery = deploy_lottery()
        expected_entrance_fee = Web3.to_wei(0.025, "ether")
        entrance_fee = lottery.getEntranceFee()
        assert expected_entrance_fee == entrance_fee
    else:
        pytest.skip()

def test_cant_enter_unless_started():
    if network.show_active() in "mainnet-fork":
        lottery = deploy_lottery()
        lottery.enter({"from":get_account(), "value" : lottery.getEntranceFee()})
    else:
        pytest.skip()

def test_can_start_and_enter_lottery():
    if network.show_active() in "mainnet-fork":
        lottery = deploy_lottery()
        account = get_account()
        lottery.startLottery({"from":account})
        lottery.enter({"from":account, "value" : lottery.getEntranceFee()})
        assert lottery.players(0) == account
    else:
        pytest.skip()

def test_can_end_lottery():
    if network.show_active() in "mainnet-fork":
        lottery = deploy_lottery()
        get_contract("vrf_coordinator").addConsumer(1, lottery.address)
        account = get_account()
        lottery.startLottery({"from":account})
        lottery.enter({"from":account, "value" : lottery.getEntranceFee()})        
        lottery.endLottery({"from":account})
        assert lottery.lottery_state() == 2
    else:
        pytest.skip()

def test_can_pick_winner_correctly():
    if network.show_active() in "mainnet-fork":
        lottery = deploy_lottery()
        get_contract("vrf_coordinator").addConsumer(1, lottery.address)
        account = get_account()
        lottery.startLottery({"from":account})
        lottery.enter({"from":account, "value" : lottery.getEntranceFee()})
        lottery.enter({"from":get_account(1), "value" : lottery.getEntranceFee()})
        lottery.enter({"from":get_account(2), "value" : lottery.getEntranceFee()})
        
        winner_intial_balance = get_account(1).balance()
        lottery_balance = lottery.balance()

        transaction = lottery.endLottery({"from":account})
        requestId = transaction.events["RequestedRandomWords"]["requestId"]
        get_contract("vrf_coordinator").fulfillRandomWords(requestId, lottery.address)
        
        assert lottery.recentWinner() == get_account(1)
        assert lottery.balance() == 0
        assert get_account(1).balance() == winner_intial_balance + lottery_balance
    else:
        pytest.skip()