from brownie import accounts, network, Lottery, config
import time
from scripts.helpful_scripts import get_account

def deploy():
    account = get_account()
    lottery = Lottery.deploy(config["networks"][network.show_active()]["eth_usd_price_feed"],
                            config["networks"][network.show_active()]["vrf_coordinator"],
                            config["networks"][network.show_active()]["link_token"],
                            config["networks"][network.show_active()]["fee"],
                            config["networks"][network.show_active()]["key_hash"] ,
                            {"from":account}
                            )
    time.sleep(1)

def main():
    deploy()