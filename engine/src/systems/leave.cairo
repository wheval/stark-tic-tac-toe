use engine::models::{Position};
use starknet::ContractAddress;

#[starknet::interface]
pub trait ILeave<T> {
    fn leave(ref self: T);
}

#[dojo::contract]
pub mod leave {
    use super::{ILeave, Position};
    use starknet::{ContractAddress, get_caller_address};
    use engine::models::{Matchmaker, Board, Player};
    use engine::interface::{IVrfProviderDispatcher, IVrfProvider};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Ended {
        #[key]
        pub match_id: u32,
        pub winner: ContractAddress,
        pub finished: bool,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of ILeave<ContractState> {
        fn leave(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let player_info: Player = world.read_model(player);

            let board: Board = world.read_model(player_info.match_id);

            let mut winner: ContractAddress = board.x;
            if player == board.x {
                winner = board.o;
            }

            self.end(player_info.match_id, winner, false);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"engine")
        }

        fn end(ref self: ContractState, match_id: u32, winner: ContractAddress, finished: bool) {
            let mut world = self.world_default();

            let board: Board = world.read_model(match_id);

            let new_board = Board {
                match_id: board.match_id,
                x: board.x,
                o: board.o,
                empty: board.empty,
                winner,
                active: false,
                ready: true,
            };

            let player_x = Player { address: board.x, match_id: 0, marks: array![], turn: false };

            let player_o = Player { address: board.o, match_id: 0, marks: array![], turn: false };

            world.write_model(@new_board);
            world.write_model(@player_x);
            world.write_model(@player_o);
            world.emit_event(@Ended { match_id: board.match_id, winner, finished });
        }
    }
}