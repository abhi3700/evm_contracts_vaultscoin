// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import './interfaces/ICoin.sol';
import "hardhat/console.sol";

/**
 * @notice A Vault contract
 */

contract Vault is Ownable, Pausable, ReentrancyGuard {

    using SafeMath for uint256;
    // using SafeERC20 for ICoin;

    // ==========State variables====================================
    ICoin public token;
    uint256 tokenPerETH;             // rate per ETH, calculated inside a function here.

    // Struct definition
    struct Vault {
        uint256 collateralAmount; // The amount of collateral held by the vault contract
        uint256 debtAmount; // The amount of stable coin that was minted against the collateral
    }

    mapping (address => Vault) public vaultBalances;

    // ==========Events=============================================
    event Deposited(address indexed depositor, uint256 collateralDeposited, uint256 amountMinted);
    event DepositMintDebtAmtFailed(address indexed depositor, uint256 collateralDeposited, uint256 amountMinted);
    event Withdrawn(address indexed withdrawer, uint256 collateralWithdrawn, uint256 amountBurned);
    event WithdrawTransferETHFailed(address indexed withdrawer, uint256 collateralWithdrawn, uint256 amountBurned);
    // ==========Constructor========================================
    constructor(
        ICoin _token,
        uint256 tokenPerETHVal      // 10_000 say for 1 ETH -> 10,000 AUDC tokens
    ) {
        require(address(_token) != address(0), "Invalid address");
        
        token = _token;
        tokenPerETH = tokenPerETHVal.mul(1e18);  /*10_000 * 10 ** 18;*/        // Testing: 1 ETH -> 10,000 AUDC tokens.
    }

    // ==========Functions==========================================
    /// @notice Allows a user to deposit ETH collateral in exchange for some amount of stablecoin
    /// @param amountToDeposit deposit the amount of ether the user sent in the transaction. Unit: wei
    function deposit(uint256 amountToDeposit) external payable whenNotPaused nonReentrant {
        require(msg.sender != address(0));
        require( msg.value > 0 && msg.value == amountToDeposit, "amount transferred must be positive and equal to parsed amount");

        // debtAmount calc
        // NOTE: assumption has been made
        uint256 nda = _getTokenAmount(msg.value);        // new debt amount minted

        uint256 ca = vaultBalances[msg.sender].collateralAmount;     // stored collateral amount
        uint256 da = vaultBalances[msg.sender].debtAmount;           // stored debt amount

        // update the collateral, debt amounts
        vaultBalances[msg.sender].collateralAmount = ca.add(msg.value);
        vaultBalances[msg.sender].debtAmount = da.add(nda);

        // mint debt amount corresponding to deposited ETH
        bool success = token.mint(msg.sender, nda);
        if(success) {
            emit Deposited(msg.sender, msg.value.div(1e18), nda);                   // show in ETH for events    
        } else {
            emit DepositMintDebtAmtFailed(msg.sender, msg.value.div(1e18), nda);    // show in ETH for events        
            revert("Token Minting of debt amount failed during deposit.");
        }
    }

    // -------------------------------------------------------------
    /// @notice Allows a user to withdraw up to 100% of the collateral they have on deposit
    /// @dev This cannot allow a user to withdraw more than they put in
    /// @param repaymentAmount  the amount of stablecoin that a user is repaying to redeem their collateral for. Unit: ETH i.e. don't multiply with decimals. E.g. if 50 AUDC, then parse 50
    function withdraw(uint256 repaymentAmount) external whenNotPaused nonReentrant {
        require(msg.sender != address(0));

        // read amounts
        uint256 ca = vaultBalances[msg.sender].collateralAmount;     // stored collateral amount
        uint256 da = vaultBalances[msg.sender].debtAmount;           // stored debt amount

        require(repaymentAmount <= da, "repayment amount must be less than stored debt amount");

        // calc ETH for repayment amount
        uint256 transferAmt = _getETHAmount(repaymentAmount);

        // update the collateral, debt amounts
        vaultBalances[msg.sender].collateralAmount = ca.sub(transferAmt);
        vaultBalances[msg.sender].debtAmount = da.sub(repaymentAmount);

        // TODO: burn tokens

        // transfer ETH (in wei) corresponding to repayment amount
        (bool sent, /*bytes memory data*/) = msg.sender.call{value: transferAmt.mul(1e18)}("");     // in wei
        if(sent) {
            emit Withdrawn(msg.sender, transferAmt, repaymentAmount);
        } else {
            emit WithdrawTransferETHFailed(msg.sender, transferAmt, repaymentAmount);
            revert("ETH Token Transfer failed during withdraw.");
        }
    }

    // -------------------------------------------------------------
    /// @notice Returns the details of a vault
    /// @param userAddress  the address of the vault owner
    /// @return vault the vault details
    function getVault(address userAddress) external view returns(Vault memory vault) {
        return vaultBalances[userAddress];
    }
    
    // -------------------------------------------------------------
    /// @notice Returns an estimate of how much collateral could be withdrawn for a given amount of stablecoin
    /// @param repaymentAmount  the amount of stable coin that would be repaid. E.g. 50 AUDC, then parse 50 here
    /// @return collateralAmount the estimated amount of a vault's collateral that would be returned  unit --> ETH
    function estimateCollateralAmount(uint256 repaymentAmount) external view returns(uint256 collateralAmount) {
        return _getETHAmount(repaymentAmount);
    }
    
    // -------------------------------------------------------------
    /// @notice Returns an estimate on how much stable coin could be minted at the current rate
    /// @param depositAmount the amount of ETH that would be deposited. Unit: wei
    /// @return tokenAmount  the estimated amount of stablecoin that would be minted. Unit: ETH
    function estimateTokenAmount(uint256 depositAmount) external view returns(uint256 tokenAmount) {
        return _getTokenAmount(depositAmount);
    }
    
    // -------------------------------------------------------------
    /// @dev Override to extend the way in which ether is converted to tokens.
    /// @param _weiAmount Value in wei to be converted into tokens
    /// @return Number of tokens that can be purchased with the specified _weiAmount. Unit: ETH
    function _getTokenAmount( uint256 _weiAmount ) 
            internal view 
            returns (uint256)
    {
        // For 1 ETH tokens, (10^18/10^18) * (10_000 * 10^18)/10^18
        return (_weiAmount.div(1e18)).mul(tokenPerETH.div(1e18));
    }

    // -------------------------------------------------------------
    /**
    * @dev Override to extend the way in which tokens is converted to ETH.
    * @param tokenAmt token amount. E.g. 50 AUDC, then parse 50 here
    * @return Number of tokens in ETH for given token qty. Unit: ETH
    */
    function _getETHAmount( uint256 tokenAmt ) 
            internal view 
            returns (uint256)
    {
        // For 50 AUDC tokens, 50 * 10^18 / (10_000 * 10^18)
        return tokenAmt.mul(1e18).div(tokenPerETH);
    }

}
