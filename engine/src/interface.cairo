#[starknet::interface]
pub trait IVrfProvider<TContractState> {
    fn request_random(self: @TContractState, caller: ContractAddress, source: Source);
    fn consume_random(ref self: TContractState, source: Source) -> felt252;
}