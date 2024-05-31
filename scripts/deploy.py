from brownie import network, Lottery, config
import time
from scripts.helpful_scripts import get_account, get_contract

def deploy_lottery():
    account = get_account()
    lottery = Lottery.deploy(
        get_contract("eth_usd_price_feed").address,
        get_contract("vrf_coordinator").address,
        config["networks"][network.show_active()]["subscription_id"] ,
        config["networks"][network.show_active()]["key_hash"] ,
        {"from":account}
    )
    time.sleep(1)
    print("Lottery Deployed!")
    return lottery

def start_lottery():
    account = get_account()
    lottery = Lottery[-1]
    start_lottery_txn = lottery.startLottery({"from":account})
    start_lottery_txn.wait(1)
    print("The lottery is started!")

def enter_lottery():
    account = get_account()
    lottery = Lottery[-1]
    value = lottery.getEntranceFee() + 100000000
    lottery_enter_txn = lottery.enter({"from":account, "value" : value})
    lottery_enter_txn.wait(1)
    print("You entered the lottery!")

def end_lottery():
    account = get_account()
    lottery = Lottery[-1]
    lottery_end_txn = lottery.endLottery({"from":account})
    lottery_end_txn.wait(1)
    time.sleep(60)
    print("Lottery is ended and the winner is -> " + lottery.recentWinner())

def main():
    deploy_lottery()
    start_lottery()
    enter_lottery()
    end_lottery()