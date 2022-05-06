from scripts.help_scripts import get_account
from brownie import accounts

# use ganache-cli -a <number of accounts> to specify how many accounts needed for testing.

# This test will be on local chain.


def main():
    for i in range(16):
        print(accounts[i])


main()
