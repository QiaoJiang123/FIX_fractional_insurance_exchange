# FIX - Fractional Insurance Exchange

This project develops an insurance exchange, named FIX, for individuals to buy and sell insurance policies.

Unlike other blockchain based insurance services that allow only corporate insurers to provide insurance policies. FIX allows individuals to insure via fractionalizing insurance policies. 

For example, a life insurance policy with face value 1 million dollars seems too much for one individual to insure. But 1/10000 portion of this life insurance policy, which has face value equals $100, is acceptable to individual insurers. When an individual insurer has 100 fractional insurance policies like this, his or her portfolio would become diverse enough to become stable investment.

In other words, individuals are capable of diversify their risks by insuring each other without intermediaries. Therefore, the objective of this project is to create a such platform for individuals for decentralized risk sharing. 

The idea has more profound impact on some long lasting insurance problems, such as catastrophic insurance. When individuals start insuring, they could diversify catastrophic loss way better than corproate insurers simply because their insurance investment portfolios would combine with their other investment portfolios including stocks and ETFs.

The following sections dig into more details.

## Roles in FIX

There are 5 roles required for FIX to operate:
* Insured
* Insurer
* Eligibility Verifier
* Accident Verifier
* Loss Verifier

In addition, some optional roles could largely faciliate the process:
* Data Service Provider
    * Data Provider
    * Data Analytic Solution
    * Scoring Entity
* Compliance Checker
* Insurance Brokerage

The first 5 roles must have their own smart contracts interacting with each other to complete a full cycle of an insurance policy.

This project starts with trip delay insurance, especially flight delay insurance due to the simplicity of accident verification and risk modeling.

For other lines of business such as auto insurance and life insurance, more complicated processing is needed for verification part. But, as AI and autonomous dirving become more prevailing, determining accident and ultimate loss would be sorted out along the way.

To go even further, one major branch of participants in fractional insurance industry would be the ones with Internet of Things (IoT) data.

For traditional corporate insurers, they could join the exchange just as individual insurers. Or they could provide micro-reinsurance to individual insurers since for some lines of business, the ultimate loss could be extreme and individual insurers may need excess insurance from large financial entities.

Overall, the fractional insurance exchange introduces non-traditional roles for participants and welcome new joiners to the insurance industry.

The following sub sections introduce each role in detail.

### Insured

An insured can be anyone who needs an insurance from the blockchain. It is the start of an insurance contract. FIXInsured.sol contains all the functions for an insured.

An insured needs to deploy a new smart contract using FIXInsured.sol to initialize an insurance process. It is also the insured's responsibility to appoint different verifiers and pay the fees for the services. Moreover, the insured could also specify the number of insurers needed in the insurance contract and how many portions each insurer could have.

For example, for flight delay insurance, an insured could ask for 20 insurers who equally insure a flight with ticket worth $600. If the premium is $10, each insurer would receive 50 cents. If the flight is delayed, each insurer would pay the loss based on their portions. Since the insurance policy is equally split, the payment would be $30 for each insurer.

### Insurer

An insurer in FIX can be either individual or corporate entities. As long as they agree to pay the loss when accident occurs. Unlike traditional corporate insurers, the insurers in FIX could insure portion of an insurance policy, as mentioned in the last section. 

In addition to the contingent transactions mentioned above, insurers are also required to hold certain amount of reserve based on regulations, like traditional corporate insurers. The Compliance Checker section will discuss more about it.

### Eligibility Verifier

Eligibility verificaiton is an important procedure for insurance business.

### Accident Verifier

### Loss Verifier

### Data Service Provider

### Compliance Checker

### Insurance Brokerage

## FIX Token

FIX token is an ERC20 token for this project. The token is needed for all roles to perform in the exchange.

There are several use cases:
1. Bidding insurance polices
2. Use verification services

### Use Case 1: Bidding Insurance Policies

When an insured requests an insurance policy via deploying a smart contract, everyone on the chain could become an insurer and collects some premium.

This puts individual insurers in a disadvantageous position since corporate entities are more likely to have faster internet and response as soon as the request is sent. Also, to prevent certain insurers from utilizing the exchange for fund raising as premium is paid first, a fee is needed for them to participate in bidding the request. The fee is paid in FIX token. 

In other words, there are two rounds for an insurer to insure a policy. First, the insurer must win a lottery to particpate in an auction. There may be multiple winners. The fee is associated with the winning likelihood. The more fees paid, the more likely an insurer has the chance to insure the insurance policy. The smart contract will request a random number from another source, such as Chainlink, to determine which insurers have chances to bid. In the second round, the insurer needs to propose a quote for the insurance policy. The insurers with the cheapest quotes will be chosen.

### Use Case 2: Service Fee

Unlike traditional insurance business model which is BtoC, the participants in this fractional insurance exchange need more services than ever. It is due to more uncertainties resulting from lack of information. The missing information includes but not limited to:
1. Characteristics of insured
2. Characteristics of insurer
3. Risk frequency and severity distribution
4. Correlations among covered risks
5. Accident occurrence, etc.

Some types of the missing information are resolved by corporate insurers such as 1, 3, 4, 5. Some are just new to current participants such as 2 and 5. Note that accident occurrence appears in both categories.

## Secondary Insurance Market

## Financial Derivatives

## New Solution for Catastrophic Insurance
