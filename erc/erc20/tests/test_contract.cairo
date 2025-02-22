use starknet::{ContractAddress, contract_address_const};
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address};
use openzeppelin::utils::serde::SerializedAppend;
use erc20::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

fn NAME() -> ByteArray {
    "TicTacToeERC20"
}

fn SYMBOL() -> ByteArray {
    "$TICTACTOE"
}

fn MINT_TO() -> ContractAddress {
    contract_address_const::<'MINT'>()
}

fn RECIPIENT() -> ContractAddress {
    contract_address_const::<'RECIPIENT'>()
}

fn SPENDER() -> ContractAddress {
    contract_address_const::<'SPENDER'>()
}

fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}

fn DECIMALS() -> u8 {
    18
}

fn INITIAL_SUPLY() -> u256 {
    10000
}

fn __deploy_contract__() -> (ContractAddress, IERC20Dispatcher) {
    let contract_class = declare("erc20").unwrap().contract_class();

    // constructor call data
    let mut calldata: Array<felt252> = array![];

    calldata.append_serde(NAME()); // name
    calldata.append_serde(SYMBOL()); // symbol
    calldata.append_serde(DECIMALS()); // decimals
    calldata.append_serde(INITIAL_SUPLY()); // initial_supply
    calldata.append_serde(MINT_TO()); // mint_to

    let (address, _) = contract_class.deploy(@calldata).unwrap();
    (address, IERC20Dispatcher { contract_address: address })
}


#[test]
fn test_name() {
    let (_, erc2Dispatcher) = __deploy_contract__();
    let name = erc2Dispatcher.name();
    assert(name == NAME(), 'Invalid name');
}


#[test]
fn test_symbol() {
    let (_, erc2Dispatcher) = __deploy_contract__();
    let symbol = erc2Dispatcher.symbol();
    assert(symbol == SYMBOL(), 'Invalid symbol');
}

#[test]
fn test_decimals() {
    let (_, erc2Dispatcher) = __deploy_contract__();
    let decimals = erc2Dispatcher.decimals();
    assert(decimals == DECIMALS(), 'Invalid decimals');
}

#[test]
fn test_total_supply() {
    let (_, erc2Dispatcher) = __deploy_contract__();
    let supply = erc2Dispatcher.total_supply();
    assert(supply == INITIAL_SUPLY(), 'Invalid supply');
}

#[test]
fn test_balance() {
    let (_, erc2Dispatcher) = __deploy_contract__();
    let balance = erc2Dispatcher.balance_of(MINT_TO());
    assert(balance == INITIAL_SUPLY(), 'Invalid balance');
}

#[test]
#[ignore]
fn test_approve() {
    let (contract_address, erc2Dispatcher) = __deploy_contract__();

    let amount: u256 = 1000;
    start_cheat_caller_address(contract_address, OWNER());
    erc2Dispatcher.approve(SPENDER(), amount);

    assert(erc2Dispatcher.allowance(OWNER(), SPENDER()) > 0, 'Incorrect Allowance');
    assert(erc2Dispatcher.allowance(OWNER(), SPENDER()) == 1000, 'Incorrect Allowance');
}

#[test]
#[ignore]
fn test_transfer() {
    let (contract_address, erc2Dispatcher) = __deploy_contract__();

    let amount: u256 = 5000;

    start_cheat_caller_address(contract_address, MINT_TO());
    let _ = erc2Dispatcher.transfer(RECIPIENT(), amount);

    assert(erc2Dispatcher.balance_of(MINT_TO()) == amount, 'Balance of mint_to not 5000');
    assert(erc2Dispatcher.balance_of(RECIPIENT()) == amount, 'Balance of recipient not 5000');
}


#[test]
#[ignore]
fn test_transfer_from() {
    let (contract_address, erc2Dispatcher) = __deploy_contract__();

    let amount: u256 = 5000;

    start_cheat_caller_address(contract_address, MINT_TO());
    let _ = erc2Dispatcher.transfer(RECIPIENT(), amount);

    assert(erc2Dispatcher.balance_of(MINT_TO()) == amount, 'Balance of mint_to not 5000');
    assert(erc2Dispatcher.balance_of(RECIPIENT()) == amount, 'Balance of recipient not 5000');
}
