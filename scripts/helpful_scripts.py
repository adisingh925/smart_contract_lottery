from brownie import network, accounts, config

def get_account():
    if(network.show_active() in "sepolia"):
        return accounts.add(config["wallets"]["from_key"])
    elif(network.show_active() in "mainnet-fork"):
        return accounts[0]