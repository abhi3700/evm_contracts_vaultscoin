## Features
* The initial stable coin will have a symbol of "AUDC" and a name of "AUD Stablecoin"
* The initial stablecoin will be an ERC20 compatible token
* By depositing collateral, a user will open a vault or increase the debt in their existing vault
	- A vault has: an amount of collateral on deposit, an amount of AUDC minted against that collateral, and a collateral ratio (calculated on demand, not stored)
	- If a user's vault collateral ratio drops below 100% (ie the price of AUD/ETH increases), depositing into the vault will not mint more AUDC
	- If a user's vault collateral ratio is over 100% (the price of AUD/ETH dropped) they are still required to repay all the AUDC minted to withdraw 100% of their collateral.
	- There is one vault per collateral type
* A user must be able to deposit ether and receive some amount of AUDC in return. Depositing ether will open a new vault for a new user, or increase the debt in an existing vault.
* A user must be able to repay an amount AUDC and receive some amount of their collateral in return. Repaying all the AUDC debt outstanding will not return more collateral than the user deposited.
	- The amount of collateral that a user can withdraw per AUDC repaid depends on the current AUD/ETH price.
* A user must be able to retrieve an estimate of how much AUDC a given amount of collateral would mint
* A user must be able to retrieve an estimated amount of AUDC required to retrieve their collateral on deposit