use starknet::{ContractAddress, contract_address_const};

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use openzeppelin::utils::serde::SerializedAppend;

use erc20::erc20::{IERC20Dispatcher,IERC20DispatcherTrait};

fn NAME() -> ByteArray {
    "TicTacToeERC20"
}

fn SYMBOL() -> ByteArray {
    "TicTacToe"
}

fn MINT_TO() -> ContractAddress {
    contract_address_const::<'MINT'>()
}

fn __deploy_contract__() -> (ContractAddress, IERC20Dispatcher) {
    let contract_class = declare("erc20").unwrap().contract_class();

    // constructor call data
    let mut calldata: Array<felt252> = array![];

    calldata.append_serde(NAME()); // name
    calldata.append_serde(SYMBOL()); // symbol
    calldata.append_serde(5); // decimals
    calldata.append_serde(100); // initial_supply
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
