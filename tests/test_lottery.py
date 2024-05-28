from brownie import Lottery, config, network
from web3 import Web3
from scripts.helpful_scripts import get_account

def test_get_entrance_fee():
    account = get_account()
    lottery = Lottery.deploy(config["networks"][network.show_active()]["eth_usd_price_feed"],
                            config["networks"][network.show_active()]["vrf_coordinator"],
                            config["networks"][network.show_active()]["link_token"],
                            config["networks"][network.show_active()]["fee"],
                            config["networks"][network.show_active()]["key_hash"] ,
                            {"from":account}, publish_source=config["networks"][network.show_active()].get("verify", False)
                            )
    
    print(lottery.getEntranceFee())
    assert lottery.getEntranceFee() > Web3.to_wei(0.011, "ether")
    assert lottery.getEntranceFee() < Web3.to_wei(0.013, "ether")