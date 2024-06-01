from brownie import network, accounts, config, MockV3Aggregator, VRFCoordinatorV2Mock, Contract
import time

DECIMALS = 8
INITIAL_VALUE = 200000000000

def get_account(index=0):
    if(network.show_active() in "sepolia"):
        return accounts.add(config["wallets"]["from_key"])
    elif(network.show_active() in "mainnet-fork"):
        return accounts[0]


def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    account = get_account()
    MockV3Aggregator.deploy(decimals, initial_value, {"from":account})
    time.sleep(1)
    txn = VRFCoordinatorV2Mock.deploy(
        100000000000000000, 
        1000000000, 
        {"from":account}
    )
    txn.createSubscription()
    txn.fundSubscription(1, 1000000000000000000)

get_contract_from_name = {"eth_usd_price_feed" : MockV3Aggregator, "vrf_coordinator" : VRFCoordinatorV2Mock}

def get_contract(contract_name):
    contract_type = get_contract_from_name[contract_name]
    if network.show_active() in "mainnet-fork":
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(contract_type._name, contract_address, contract_type.abi)

    return contract

    