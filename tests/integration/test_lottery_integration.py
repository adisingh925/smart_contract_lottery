from brownie import network
from scripts.deploy import deploy_lottery
from scripts.helpful_scripts import get_account
import time

def test_can_pick_winner():
    if network.show_active() in "sepolia":
        lottery = deploy_lottery()
        account = get_account()
        lottery.startLottery({"from":account})
        lottery.enter({"from":account, "value":lottery.getEntranceFee()})
        lottery.enter({"from":account, "value":lottery.getEntranceFee()})
        lottery.endLottery({"from":account})
        time.sleep(60)

        assert lottery.recentWinner() == account
        assert lottery.balance() == 0

