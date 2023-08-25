**Issue category**
High

**Issue title**
`getEntitlementOnDeath()` calculates wrong value

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L292-L302

**Impact**
Beneficiaries recieve incorrect amount of funds

**Description**
Imagine a user has created a Trust and added Beneficiaries. Imagine that `block.timestamp` has crossed the deadline and one of the users
calls singleTransfer to transfer ERC20 tokens. This in turn invokes the `getEntitlementOnDeath()` function.

The `getEntitlementOnDeath()` is supposed to send the calculate the number of tokens the Beneficiaries should recieve but it does
some complex math operations and in the end only transfer a fraction of the value to the Beneficiaries.

**Recommendations to fix**
Update the logic to directly check the current allowance and see if the Beneficairy was already paid.

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---
**Issue category**
High

**Issue title**
Beneficiaries added via `addToMyTrustBeneficiaries` can never recieve the funds

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L178-L183

**Impact**
Beneficiaries added via `addToMyTrustBeneficiaries` can never recieve the funds.

**Description**
Imagine a user has created a Trust and added Beneficiaries. Now he/she plans to add more Beneficiaries via the `addToMyTrustBeneficiaries`.
New Beneficiaries are added as part of the function but the `beneficiaryCount` of the current Struct is never updated.

For Example: Users creates a Trust with 5 Beneficiaries. Later on adds 3 more Beneficiaries to it. The `beneficiaryCount` is never updated.
As a result, even though there are new Beneficiaries bulkTransfers get the old `beneficiaryCount` and loop through it.

**Recommendations to fix**
Update the `beneficiaryCount` in the `addToMyTrustBeneficiaries` function

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---
**Issue category**
Low

**Issue title**
Token and NFT approval not reset post `deleteTrust()`

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L159

**Impact**
No direct security impact but approvals post deleteTrust are not revoked.

**Description**
Once a user creates a Trust and decides to delete it later on, the approvals provided earlier should be revoked. Even though there is no direct
impact of security risk. But providing approval to a contract post deletting is not a good practice.

**Recommendations to fix**
Revoke approvals via Frontend app

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---
**Issue category**
Low

**Issue title**
Follow CEI pattern

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L232-L238
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L245-L257

**Impact**
Not following CEI pattern may expose it to vulnerbilties like Reentrancy and Cross Function Reentrancy.

**Description**
The functions `transferHelper` and `bulkTransfers` do not follow CEI pattern. The update happens post the for loop, If 
an user is able to make a call and exploit Reentrnacy in this case.

**Recommendations to fix**
Follow CEI Pattern

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---
**Issue category**
Low

**Issue title**
Floating Pragma Solidity Version

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L2

**Impact**
An outdated compiler version that might introduce bugs that affect the contract system negatively.

**Description**
Contracts should be deployed with the same compiler version and flags that they have been tested with thoroughly. Locking the pragma helps to ensure that contracts do not accidentally get deployed using, for example, an outdated compiler version that might introduce bugs that affect the contract system negatively.

Reference - https://swcregistry.io/docs/SWC-103

**Recommendations to fix**
Consider upgrading all contracts to Solidity version 0.8.16 at a minimum, but ideally to the latest version.

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---

**Issue category**
Low

**Issue title**
Ownable: Does not implement 2-Step-Process for transferring ownership

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L8

**Impact**
Ownership of the contract can easily be lost when making a mistake when transferring ownership.

**Description**
The contracts Trustee.sol does not implement a 2-Step-Process for transferring ownership.
So ownership of the contract can easily be lost when making a mistake when transferring ownership.

Since the privileged roles have critical function roles assigned to them. Assigning the ownership to a wrong user can be disastrous.
So Consider using the Ownable2Step contract from OZ (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) instead.

The way it works is there is a transferOwnership to transfer the ownership and acceptOwnership to accept the ownership. Refer the above Ownable2Step.sol for more details.

**Recommendations to fix**
Implement 2-Step-Process for transferring ownership.

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---

**Issue category**
Low

**Issue title**
Missing `address(0)` checks

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L148

**Impact**
The recipient of a tokens or NFTs may be address(0), leading to lost assets.

**Description**
when setting the state varaibles, the 0 address is not being checked in any of the contracts.

**Recommendations to fix**
When setting an address variable, always make sure the value is not zero.

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---

**Issue category**
Low

**Issue title**
Events not emitted for important state changes and not indexed

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L215-L229

**Impact**
offchain tools cannot index it

**Description**
When changing state variables events are not emitted.

Events are an important feature in smart contracts and are primarily used to facilitate the communication and interaction between smart contracts and external entities, such as user interfaces and off-chain applications

**Recommendations to fix**
Emit an event when setting or updating an important state variable. Please make sure they are indexed if needed.

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---

**Issue category**
Informational

**Issue title**
redundant check for `creditBeneficiary` in `TransferHelper`

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L245

**Impact**
redundant check for creditBeneficiary in TransferHelper

**Description**
The internal function `transferHelper` is being called as part of `bulkTransfers` and `singleTransfer` which already have a check for creditBeneficiary modifier.
The check for creditBeneficiary is also present in transferHelper which makes it redeundant.

**Recommendations to fix**
Either remove the check from both bulkTransfers and singleTransfer function or from the TransferHelper internal function.

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---

**Issue category**
Informational

**Issue title**
`subscriptionPrice` and `pricePerBeneficiary` are defined but never collected from user

**Where**
https://github.com/AuditoneCodebase/CTF_challenge_4.8.2023/blob/5d60d3063af56dea7aa12f076a5858373a1069bc/Trustee.sol#L58-L59

**Impact**
`subscriptionPrice` and `pricePerBeneficiary` is never collected from user. Basically they are using the service for free

**Description**
`subscriptionPrice` and `pricePerBeneficiary` have a function to be updated but they are never used in the code to transfer this amount to the owner via `msg.value`.
As a result, these fees are never collected from the user using the service.

**Recommendations to fix**
Add the missing code to collect the fee

**Additional context**
Add any other context about the problem here.

**Comments by AuditOne**
AuditOne team can comment here

---
