from brownie import network, accounts, config, interface, MockV3Aggregator, LinkToken, VRFCoordinatorMock, Contract
import time

DECIMALS = 8
INITIAL_VALUE = 200000000000

def get_account():
    if(network.show_active() in "sepolia"):
        return accounts.add(config["wallets"]["from_key"])
    elif(network.show_active() in "mainnet-fork"):
        return accounts[0]
    
def fund_with_link(contract_address):
    account = get_account()
    amount = 250000000000000000
    link_token = get_contract("link_token")
    link_token_contract = interface.LinkTokenInterface(link_token)
    txn = link_token_contract.transfer(contract_address, amount, {"from":account})
    txn.wait(1)
    print("Contract funded with link token!")
    return txn


def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    account = get_account()
    MockV3Aggregator.deploy(decimals, initial_value, {"from":account})
    time.sleep(1)
    link_token = LinkToken.deploy({"from":account})
    time.sleep(1)
    VRFCoordinatorMock.deploy(link_token.address, {"from":account})

get_contract_from_name = {"eth_usd_price_feed" : MockV3Aggregator, "vrf_coordinator" : VRFCoordinatorMock, "link_token" : LinkToken}

def get_contract(contract_name):
    contract_type = get_contract_from_name[contract_name]
    if network.show_active() in "mainnet-fork":
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_Active()][contract_name]
        contract = Contract.from_abi(contract_type._name, contract_address, contract_type.abi)

    return contract

    