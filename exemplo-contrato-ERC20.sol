// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract TokenRio is ERC20 {
    //constructor() ERC20("Token Rio", "RIO"){}
    //só com esse constructor ja iri funcionar.

    uint256 private _totalSupply;

    //guarda os saldos de cada usuario
    mapping(address => uint256) private _balances;

    //permição pra corretoras moverem o dinheiro.
    //endereço => endereço => quantidade
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint256 initialSupply) ERC20("TokenRio", "RIO"){
        _mint(msg.sender, initialSupply);
    }

    //obs:
    //override: serve pra sobreescrever a função herdada de ERC20

    function decimals() public override pure returns(uint8){
        return 6;
    }

    function totalSupply() public override view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public override view returns(uint256){
        return _balances[_owner];
    }

    function transfer(address to, uint256 amount) public override returns(bool){
        _transfer(msg.sender, to, amount);
        return true;
    }

    //função pra uma plataforma tipo pancakeswap transferir para conta
    function transferFrom(address from, address to, uint256 amount) public override returns(bool){
        uint256 currentAllowance = _allowances[to][msg.sender];

        require (currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns(bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    //função pra aumentar as permissões da pancakewapc
    function increaseAllowance(address spender, uint256 addedValue) public override returns(bool){
        _approve(msg.sender, spender, _allowances[msg.sender][spender] += addedValue);
        return true;
    }

    //função pra diminuir as permissões da pancakewapc
    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns(bool){
        uint256 currentAllowance = _allowances[msg.sender][spender];

        //verifica se é maior que 0
        require(currentAllowance >= subtractedValue, "ERC20: decrease allowance below zero");

        unchecked{
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    //"_" antes do nome d função para indicar q é privada
    //from quem ta enviando
    //to quem vai receber
    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exeeds balance");

        unchecked{
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    //                  pessoal         pancakeswap     quantidade
    function _approve(address owner, address spender, uint256 amount) internal override {
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal override {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

}
