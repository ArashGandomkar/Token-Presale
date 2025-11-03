// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20 is Context, IERC20Metadata, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowance;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) Ownable(_msgSender()) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = 1000000 * (10 ** decimals());
        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function name() public view override returns(string memory) {
        return _name;
    }
    function symbol() public view override returns(string memory) {
        return _symbol;
    }
    function decimals() public pure override returns(uint8) {
        return 18;
    }
    function totalSupply() public view override returns(uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns(uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns(uint256) {
        return _allowance[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal  {
        require(from != address(0), "ERC20 Transfer from zero account not allowed.");
        require(to != address(0), "ERC20 Transfer to zero account not allowed.");
        uint256 balanceAcoount = _balances[from];
        require(balanceAcoount >= amount,"Not enough tokens.");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Mint to the zero address is not acceptable.");
        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }
    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Burn from the zero address is not acceptable.");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Not enough tokens.");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal  {
        require(owner != address(0));
        require(spender != address(0));
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        address spender = _msgSender();
        uint256 currentAllowance = _allowance[from][spender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(from, spender, currentAllowance - amount);
        _transfer(from, to, amount);
        emit Approval(from, spender, amount);
        return true;
    } 
}