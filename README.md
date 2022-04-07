# FIX - Fractional Insurance Exchange

This project develops an insurance exchange, named FIX, for individuals to buy and sell insurance policies.

Unlike other blockchain based insurance services that allow only corporate insurers to provide insurance policies. FIX allows individuals to insure via fractionalizing insurance policies. 

For example, a life insurance policy with face value 1 million dollars seems too much for one individual to insure. But 1/10000 portion of this life insurance policy, which has face value equals $100, is acceptable to individual insurers. When an individual insurer has 100 fractional insurance policies like this, his or her portfolio would become diverse enough to become stable investment.

In other words, individuals are capable of diversify their risks by insuring each other without intermediaries. Therefore, the objective of this project is to create a such platform for individuals for decentralized risk sharing. 

The idea has more profound impact on some long lasting insurance problems, such as catastrophic insurance. When individuals start insuring, they could diversify catastrophic loss way better than corproate insurers simply because their insurance investment portfolios would combine with their other investment portfolios including stocks and ETFs.

The following sections dig into more details.

## Roles in FIX

There are 4 roles required for FIX to operate:
* Insured
* Insurer
* Identification Verifier
* Accident Verifier

In addition, some optional roles could largely faciliate the process:
* Data Service Provider
    * Data Provider
    * Data Analytic Solution
    * Scoring Entity
* Compliance Checker
* Insurance Brokerage

The first 4 roles must have their own smart contracts interacting with each other to complete a full cycle of an insurance policy.

This project starts with trip delay insurance, especially flight delay insurance due to the simplicity of accident verification and risk modeling.

For other lines of business

### Insured


 

## FIX Token

FIX token is an ERC20 token. The token is needed for all roles to perform in the exchange.