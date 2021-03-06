# FIX - Fractional Insurance Exchange #

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

Eligibility verificaiton is an important step for insurance business. Insurance is essentially a gambling. What differs insurance from gambling is its purpose, that is, risk 
transfer. That means one party must have some existing risk before entering an insurance policy for that risk. Also, the party or the family of the party must be the beneficiary of the insurance policy. The conditions make the party eligible to get a certain type of an insurance policy.

Eligibility verification ensures that the smart contract is an insurance policy. For example, for flight delay insurance, the insured must be the flight ticket holder to buy a flight delay insurance for his or her flight.

In FIX, the insured has the responsibility to appoint eligibility verifier(s). There could be multiple eligibility verifiers just to ensure the accuracy of verification.

One natural question is what if the appointed eligibility verifier does not provide true information and trick insurers to provide insurance. This problem could be resolved by browsing the verification history of the verifier or by appointing corporate eligibility verifier with high reputation. Note that insurers have the choice to provide insurance or not based on the insureds' appointment. In other words, it is a game between insureds and insurers. Both parties are playing strategically.

### Accident Verifier

When an insurance contract is agreed by insured and insurer(s), the next step is to verify if an accident occurs before the expiration date. Since Ethereum cannot 'access the internet' directly (so does api services), some node needs to notify the smart contract about any accident occurence. This is where accident verifier plays a role. For example, for flight delay insurance, it needs a node to verify whether the flight is delayed or not. If the flight delayed, insurers will transfer loss to insured directly. Otherwise, the insurance will be closed.

It is also the insured's responsibility to appoint accident verifier(s).

### Loss Verifier

For some LOB such as auto insurance, verifiying accident is not enough. Loss amount needs to be determined for final payment. At current stage, the project only focuses on flight delay insurance. We will circle back to other insurance later. 

### Data Service Provider

Data Service Provider is not required in the smart contract. However, it is an important player in FIX since both insureds and insurers are individuals now. They do not have enough data to start an insurance policy. For example, for flight delay insurance, both insureds and insurers need to know the odds for the premium and reserves. Moreover, for insurers, they need to know the multi-variable distributions among flights to find the best insurance policy portfolio, just like how people invest stocks. Another type of data needed maybe the characteristic of insureds. It may not be PII but it could be a score to indicate the riskiness of the insured based on his or her insurance history.

There are much more scenarios for the need of data service. This is where new participants, such as car manufacturers who have telematics data or autonomous driving data,come into the game.

### Compliance Checker

Regulation is still needed since each individual insurer is just like a micro insurance company. They are facing and creating the same problems such as insolvency, suspecious fund raising using insurance, etc. Therefore, some certain regulations need to be enforced. The reason why this role is not required is that insured and insurer may be willing to take risks. However, getting a stamp from Compliance Checker is definitely recommended in the system. 

Compliance Checker will check whether certain regulation requirement are met or not. For example, if an insurer provides an insurance, he/she should have certain amount of reserves held. 

### Insurance Brokerage

FIX is an open exchange. Whenever there is a request for an insurance policy, any participant could compete for the opportunity. The problem is if individual insurers are able to compete with corporate insurers if corporate insurers decide to use the exchange as well. The latter participant may have faster internet and better servers to find new requests.

Also, if a new joiner wants to provide insurance policies, how can he/she start? 

Therefore, there is a natural need for insurance brokerage to provide services such as bidding for new insurance requests on behalf of individual insurers or provide starter insurance policy portfolios for new joiners. 

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

Some types of the missing information are resolved by corporate insurers such as 1, 3, 4, 5. Some are just new to current participants such as 2 and 5. Note that accident occurrence appears in both categories. It is because unlike traditional way to collect accident occurence data using investgators, accident verifier in FIX may use telematics data or autonomous driving data for accident verification. It requires new type of participants. Refer to New Market Players below for more information.

## Secondary Insurance Market

Once an insurance policy is issued, there exists an opportunity for insurers to trade the policy with others. This is called Secondary Insurance Market. It would be easier to think of insurance issurance as IPO in stock market.

What makes the secondary trading possible is the need to optimize insurance policy portfolios. If an insurance policy provides more diversificaiton to an insurer than the owner, the trading may lead to a win-win transaction.

## Financial Derivatives

Due to the existence of secondary insurance market, securitization of insurance policies become viable in FIX. A financial institute could buy a portfolio of insurance policies and securitize them into a bond. Such bond could be sold in the financial market. This is a great way to transfer insurance risk into the financial market. This risk transfer is a great solution for catastrophic insurance problem.

## New Solution for Catastrophic Insurance

Catastrophic insurance is always a problem. In academia, this insurance is not considered globally insurable since the loss result from a catastrophic event is so extreme that the insurance industry could not absorb it. Howevet, compared to the size of the financial market, catastrophic loss does not seem to be extreme. Therefore, transfering catastrophic risk to the financial market is a viable solution to catastrophic insurance. The existing and popular tool is CAT bond. But the market lacks liquidity and CAT bond is less transparent.

If catastrophic insurance is sold in FIX and securitization is used for risk transfer, the catastrophic risk could be smoothly transferred to the financial market with high transparency.

## New Market Players

### Internet of Things (IoT) Company

FIX is designed to be a highly automated system. One of its advantages is to reduce manual work to large extent, such as accident verification and loss verification. The exchange may not deploy any model for both verification since it requires large space for storage, which lead to high cost. Therefore, the exchange expects third parties to provide such service. This leads to the first group of new market players in the insurance industry, that is, tech companies that specialized in Internet of Things and Artificial Intelligence.

For example, consider the accident verification of a car in an auto insurance. Many car manufractuers possess telematics data or/and autonomous driving data. Those data can be used to identify an accident after processed by a machine learning model and update the status in the blockchain. It generates new revenue stream for the companies and cause no privacy issue.

### Insurance Brokerage

The second group of new market players can be very similar to financial market service providers. Traditionally, insurers possess the information to calculate the premium for insureds. When both insureds and insurers are individuals in FIX, no side has enough information about premium, reserve and policy portfolio selection. For premium and reserve, insureds and insurers could request for extra consulting service from insurance experts, individuals or corporates, subject to regulation.

For policy protfolio selection, it is like stock portfolio selection. Insurers need extra information to decide which insurance policy to insure and what is the optimal portion to invest. There will be the need for insurance brokerage for data and recommendation. 

Lastly, since there will be both individual and corporate insurers in the exchange, it would be hard for individuals to be picked due to less professional infracstructure, including internet speed, cloud service, etc. Thus, this is another need for insurance brokerage to acquire insurance policies for individual insurers or help them get into the lottery phase for insurance policy investment with some advantage.

### Reserve Verifier

When insurer starts insuring, a certain amount of reserve is needed. There are two ways to store reserves. The first way is to send the full amount of possible loss to the insurance smart contract deployed by the insurer. For instance, if an insurer gets 10% of a flight delay insurance with $600 coverage, the insurer needs to transfer $60 to the smart contract. If the flight is delayed, the amount will be transferred to the insured. Otherwise, the insurer will have $60 back plus 10% premium.

The first method is not very efficient since it is very rare to have all insurance policies triggered. The typical as well as more efficient way is to have another account (smart contract) to store reserves for all insurance policies. The amount of reserve will not equal to the full contingent amount. Instead, the reserve will be calculated as in traditional corporate insurance companies. It will depend on the statistical characteristics of each insurance policy (full or partial), confidence level, regulatory requirements, etc. 

The reserve account will be updated daily to reflect the change in risk. If the required amount is more than the actual amount, more contribution is needed from the insurer. Also, when a payment is made from the reserve account due to an incident, the new reserve amount will be calculated and the new required amount will be sent to the insurer for more contribution.

ALl the calculation the compliance requirement in the second method need a thid party, called Reserve Verifier, to verify to ensure the insurer is complying with all regulations so that the insolvency risk is reasonable.

### DeFi

In traditional insurance business, insurance companies invest the premium they receive, subject to certain regulation. In FIX, individual insurers should have the same capability to invest the premium. Instead of traditional investment channels such as stock exchange, insurers in FIX can use DeFi for investment. This can be complished by enabling staking and withdrawing in the reserve account. Meanwhile, for liquidity issue, the reserve account will prioitize loss payment over staking and force withdrawal when not enough balance in the reserve account.

### Micro-reinsurer

Micro-reinsurer is another new market player. For some insurance, the loss is fixed such as life insurance and flight delay insurance. Individual insurers should not worry about excessive loss. However, for other lines of business, such as auto insurance, the loss could range from $0 to tens of throusands of dollars. Even insuring a part of an insurance policy, individual insurers may still find the variation large which could lead to large amount of reserve requirement. One solution is to impose a cap on the loss payment and transfer the residual loss to another party. The concept is identical to Excess of Loss reinsurance. But the distribution of the underlying loss may be very different. Also, the data needed to model the loss could be different. This is where traditional corproate insurers could get involved and provide individual insurers micro-reinsurance policies for the residual loss.

## Q&A

In this section, I will answer some questions I have been frequently asked when I introduced the idea to others. Hopefully, this Q&A section could clarify some confusion

### Q1: Why do you choose blockchain instead of current IT infrastructure which seems more efficient?

Current IT infrastructure could be used to develop the same system more efficiently and easily using API, cloud services, etc. Also, many hard technical problems in blockchain such as random number generation and access internet data become very natural to traditional IT infracstructure. 

However, the biggest concern on allowing individual insurers is the regulation. Regulating a big corporate insurer would be much easier than regulating a large amount of atomic individual insurers. For example, the regulation costs could be easily passed to corporate insurers such as more reporting and more scenario simulations. So, it is pessimistic that regulators would ever allow individual insurers in the industry. From this perspective, the major advantage of using blockchain to build FIX is to provide a sort of bargaining power of individual insurers against regulators simply because blockchain is a decentralized and anonymous system where it is extremely hard to enforce regulation. In other words, individual insurers and insureds do not need or even enacounter any effective regulation to finsih a deal. 

It does not mean regulation is not necessary. In fact, since an insurance can be considered as a gamling game with 'good' purpose, some essential regulation is needed to make a gamling game into an insurance.

What FIX could achieve is to utilize the highly automated system built on top of blockchain to enforce essential regulation so that individual insurers could involve in insurance business.

### Q2. What roles traditional corporate insurers would play in FIX?

There are multiple new roles that traditional corporate insurers can play in FIX. First, individual insurers need data to determine premium and reserve. Traditional corproate insurers could leverage the historical data to provide consulting services for individual insurers. Also, like mentioned in New Market Players section, tradtitional corporate insurers could also provide micro-reinsurance for partial insurance policies. 

A natural follow-up question would be why traditional corporate insurers cannot sell insurance policies like they used to do in FIX. The simple answer is YES, they can still sell insurance policies. But, their market share would decrease as individual insurers are taking part of it. It is vital to realize that FIX in blockchain is not only a new platform but also introduces a new landscape for revenue distribution in the insurance industry. It is not corporate insurers versus individual insurers. It is new insurance players versus old insurance players. Individual insurers may be equipped with services from new market players such as IoT tech companies when competing with corporate insurers, which gives individual insurers advantages in the compeition while sharing the profit with new group of players such as IoT tech companies, insurance brokerage, etc. 

Therefore, traditional corporate insurers may need to consider new roles in FIX. This implies that they need some transition to some new business model.

### Q3. Who will be eligibility verifier(s), accident verififer(s) and loss verifier(s)?

There is no requirement, license or certificate needed for those verifiers. By rules, everyone in the blockchain could be a verifier. But in practice, only verifiers that are able to and does provide accurate verification can survive at last. This implies that IoT tech companies and data oracle companies may be the main players as verifiers at last. Insureds and insurers can easily review the accuracy of each verifier by browsing their history.

### Q4. How service fee is calculated?

In later version of FIX, service fee will be needed using FIX token. Service fee is subject to each service provider including verification, data analytics, etc. The amount of service fee for each service also depends on its provider. 

### Q5. Who will be the data oracles?

In theory, anyone can be a data oracle for FIX. However, in practice, traditional corporate insurers, IoT tech companies, and other platforms that own data will play important roles in FIX as data oracles. For example, in flight delay insurance, data oracles include those that have access to flight purchase data for eligibility verification and flight departure data for accident verification. Whether a data oracle could success in FIX depends on their data accuracy, data update speed, service fee, etc. 

### Q6. Why traditional corporate insurers will support FIX with their data?

It would seem impossible that traditional corporate insurers would support FIX with their data so that individual insurers will take their market shares. However, such support is not necessay for FIX to operate properly. As FIX starts with simple lines of business such as flight delay insurance, there is no need for help from traditional corporate insurers at the very beginning. When FIX includes more complciated lines of business such as auto insurance or home owner insurance, individual insurers could get data service or analytics from insuracne data vendors regarding the odds. 

The worst situation would be no data at all at the beginning for complciated insurance. But as more and more trial and errors, eventually FIX would have enough data contained in itself for individual insurers to use for pricing, reserving, etc. In other words, support from traditional corporate insurers can only accelerate the transition. It is not a necessary component.

Furthermore, the situation traditional corporate insurers are facing is a typical prisoner's dilemma. Imagine there are two traditional corporate insurers A and B. If both A and B choose not to support, after a while, the new market will not need any insurers like A and B. So, they lose an opportunity to generate revenue by providing support including data service and analytic service. If A choose to support but B does not. A earns the revenue by providing such support but B does not earn anything. If both A nad B choose to support. They both earn some revenue. So, providing support is always better than not. Also, if A starts supporting FIX earlier than B, A can build its reputation earlier than B, which is very advantageous when expanding in a new market. This also builds more customer stickness.

On top of that, the benefit of supporting FIX becomes obvious. First, it generates revenue for corporate insurers. Second, it helps corporate insurers adapt to the transition. Third, early participation via supporting the exchange earns corporate insurers more reputation and customer stickiness.

In a word, from a dynamic and strategic perspective, it is beneficial for traditional corporate insurers to support FIX with their data.

