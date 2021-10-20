//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import "hardhat/console.sol";

/**
 * @title AUDC ERC20 token
 */
contract Coin is ERC20, Ownable, Pausable {
	address public vaultCAddress;

    // ==========Constructor========================================
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    /**
     * @dev Throws if called by any account other than the owner.
     * 		Also, added vault contract address into permission for minting.
     */
    modifier onlyOwnerM() {
        require(owner() == _msgSender() || vaultCAddress == _msgSender(), "Ownable: caller is not the owner or vault address");
        _;
    }

    // ==========Functions==========================================
    /// @notice mint function
    /// @dev only by owner & vault address
    /// @param to receiver address
    /// @param amount mint amount
    function mint(address to, uint256 amount) external onlyOwnerM whenNotPaused {
        _mint(to, amount);
    }

    // -------------------------------------------------------------
    /// @notice burn function
    /// @param from token owner address
    /// @param amount mint amount
    function burn(address from, uint256 amount) external whenNotPaused {
        _burn(from, amount);
    }

    // -------------------------------------------------------------
    /// @notice set vault address
    /// @dev only done by owner
    /// @param account the vault contract address
    function setVaultCAddress(address account) external onlyOwner whenNotPaused {
    	require(isContract(account), "parsed address is not a contract");
    	vaultCAddress = account;
    }

    // -------------------------------------------------------------
    /// @notice check if an address is a contract
	function isContract(address account) public view returns (bool) {
	    uint32 size;
	    assembly {
	        size := extcodesize(account)
	    }
	    return (size > 0);
	}
}