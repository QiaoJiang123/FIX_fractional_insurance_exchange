from brownie import Contract, accounts, network, config
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork-dev"]
# LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat", "development", "ganache", "mainnet-fork"]


def get_account(index=None, id=None):

    # use brownie accounts generate <id> to generate several accounts.
    # <id> is a named given to the account.

    # current list of accounts:
    # accounti where i is from 1 to 10
    # freecodecamp-account

    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if index == None and id == None:
        print("Index and id cannot both be None. The default is freecodecamp-account.")
        return accounts.load("freecodecamp-account")
