// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Presale is Ownable, ReentrancyGuard {
    constructor(address payable wallet, uint rate, IERC20 token, uint decimals) Ownable(_msgSender()) {
        require(rate > 0, "Presale rate must be greater than zero...");
        require(wallet != address(0), "Presale wallet must be another address...");
        require(address(token) != address(0), "Presale token address is wrong...");
        _rate = rate;
        _token = token;
        _wallet = wallet;
        _tokenDecimals = 18 - decimals;
    }
    mapping (address => uint) public _contributions;
    IERC20 public _token;
    uint private _tokenDecimals;
    address payable public _wallet;
    uint public _rate;
    uint public _weiRaised;
    uint public  endICO;
    uint public availableTokensICO;

    event TokenPurchased(address purchaser, address beneficiary, uint value, uint amount);
    event Refund(address receipient, uint amount);

    modifier icoActive() {
        require(endICO > 0 && endICO > block.timestamp && availableTokensICO > 0, "ICO must be active");
        _;
    }
    modifier icoNotActive() {
        require(endICO < block.timestamp, "ICO should not be active...");
        _;
    }
    function startICO(uint endDate) external onlyOwner icoNotActive {
        availableTokensICO = _token.balanceOf(address(this));
        require(endDate > block.timestamp, "Duration must be more than zero...");
        require(availableTokensICO > 0, "available ICOtokens must be more than zero...");
        endICO = endDate;
        _weiRaised = 0;
    }
    function _getTokensAmount(uint weiAmount) internal view returns(uint) {
        return (weiAmount * _rate) / (10 ** _tokenDecimals);
    }
    function stopICO() external onlyOwner icoActive {
        endICO = 0;
        forwardFunds();
    }
    function buyTokens(address beneficiary) external nonReentrant icoActive payable {
        uint weiAmount = msg.value;
        uint tokens = _getTokensAmount(weiAmount);
        require(availableTokensICO > tokens, "Not enough tokens...");
        _weiRaised += weiAmount;
        availableTokensICO -= tokens;
        _contributions[beneficiary] += weiAmount;

        emit TokenPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }
    function claimTokens() external icoNotActive nonReentrant {
        uint tokenAmount = _getTokensAmount(_contributions[_msgSender()]);
        require(tokenAmount > 0, "You dount have any contribution...");
        _contributions[_msgSender()] = 0;
        _token.transfer(_msgSender(), tokenAmount);
    }
    function forwardFunds() internal {
        _wallet.transfer(address(this).balance);
    }
    function withdraw() external onlyOwner icoNotActive {
        require(address(this).balance > 0, "Contract balance is zero...");
        _wallet.transfer(address(this).balance);

    }
    function checkContribution(address customer) public view returns(uint) {
        return _contributions[customer];
    }
    function setRate(uint newRate) external onlyOwner icoNotActive {
        _rate = newRate;
    }
    function setAvailableTokens(uint amount) external onlyOwner icoNotActive {
        availableTokensICO = amount;
    }
    function weiRaised() public view returns(uint) {
        return _weiRaised;
    }
    function newWallet(address payable _newWallet) external onlyOwner {
        _wallet = _newWallet;
    }
    function takeTokens(IERC20 tokenAddress) public onlyOwner {
        IERC20 tokenERC20 = tokenAddress;
        uint tokenAmount = tokenERC20.balanceOf(address(this));
        require(tokenAmount > 0, "Balance not enough...");
        tokenERC20.transfer(_wallet, tokenAmount);
        availableTokensICO = 0;
    }
}