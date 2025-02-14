use engine::models::{Position};

#[starknet::interface]
pub trait IStart<T> {
    fn start(ref self: T);
    fn start_private(ref self: T);
    fn join(ref self: T, match_id: u32);
}

#[dojo::contract]
pub mod start {
    use super::{IStart, Position};
    use starknet::{ContractAddress, get_caller_address};
    use engine::models::{Matchmaker, Board, Player};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Created {
        #[key]
        pub match_id: u32,
        pub server: u8,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Started {
        #[key]
        pub match_id: u32,
        pub x: ContractAddress,
        pub o: ContractAddress,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IStart<ContractState> {
        fn start(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let matchmaker: Matchmaker = world.read_model(1);

            if matchmaker.last_board_ready || matchmaker.last_board == 0 {
                let zero_address: ContractAddress = 0.try_into().unwrap();
                let match_id: u32 = 123456;
                let mut empty_board: Array<Position> = array![];
                for i in 1..4_u8 {
                    for j in 1..4_u8 {
                        empty_board.append(Position { i, j });
                    }
                };

                let board = Board {
                    match_id,
                    x: player,
                    o: zero_address,
                    empty: empty_board,
                    winner: zero_address,
                    active: true,
                    ready: false,
                };

                let player_info = Player {
                    address: player, match_id, marks: array![], turn: false,
                };

                world.write_model(@player_info);
                world.write_model(@board);
                world
                    .write_model(
                        @Matchmaker { server: 1, last_board: match_id, last_board_ready: false },
                    );
                world.emit_event(@Created { match_id, server: 1 });
            } else {
                let board: Board = world.read_model(matchmaker.last_board);

                let new_board = Board {
                    match_id: board.match_id,
                    x: board.x,
                    o: player,
                    empty: board.empty,
                    winner: board.winner,
                    active: board.active,
                    ready: true,
                };

                let player_info = Player {
                    address: player, match_id: board.match_id, marks: array![], turn: true,
                };

                world.write_model(@player_info);
                world.write_model(@new_board);
                world
                    .write_model(
                        @Matchmaker {
                            server: 1, last_board: matchmaker.last_board, last_board_ready: true,
                        },
                    );
                world.emit_event(@Started { match_id: board.match_id, x: board.x, o: player });
            }
        }
        fn start_private(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let zero_address: ContractAddress = 0.try_into().unwrap();

            let match_id: u32 = 123456;

            let mut empty_board: Array<Position> = array![];
            for i in 1..4_u8 {
                for j in 1..4_u8 {
                    empty_board.append(Position { i, j });
                }
            };

            let board = Board {
                match_id,
                x: player,
                o: zero_address,
                empty: empty_board,
                winner: zero_address,
                active: true,
                ready: true,
            };

            let player_info = Player { address: player, match_id, marks: array![], turn: false };

            world.write_model(@player_info);
            world.write_model(@board);
            world
                .write_model(
                    @Matchmaker { server: 1, last_board: match_id, last_board_ready: true },
                );
            world.emit_event(@Created { match_id, server: 1 });
        }
        fn join(ref self: ContractState, match_id: u32) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let matchmaker: Matchmaker = world.read_model(1);

            let board: Board = world.read_model(match_id);

            let new_board = Board {
                match_id,
                x: board.x,
                o: player,
                empty: board.empty,
                winner: board.winner,
                active: board.active,
                ready: true,
            };

            let player_info = Player {
                address: player, match_id: board.match_id, marks: array![], turn: true,
            };

            world.write_model(@player_info);
            world.write_model(@new_board);
            world
                .write_model(
                    @Matchmaker {
                        server: 1, last_board: matchmaker.last_board, last_board_ready: true,
                    },
                );
            world.emit_event(@Started { match_id: board.match_id, x: board.x, o: player });
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"engine")
        }
    }
}
