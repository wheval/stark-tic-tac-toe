use engine::models::{Position};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IActions<T> {
    fn start(ref self: T);
    fn start_private(ref self: T);
    fn join(ref self: T, match_id: u32);
    fn mark(ref self: T, position: Position);
    fn leave(ref self: T);
    fn read_board(self: @T) -> (Array<Position>, Array<Position>, Array<Position>);
}

#[starknet::interface]
pub trait IVrfProvider<TContractState> {
    fn request_random(self: @TContractState, caller: ContractAddress, source: Source);
    fn consume_random(ref self: TContractState, source: Source) -> felt252;
}

#[derive(Drop, Copy, Clone, Serde)]
pub enum Source {
    Nonce: ContractAddress,
    Salt: felt252,
}

#[dojo::contract]
pub mod actions {
    use super::{IActions, Position, array_contains_position, IVrfProviderDispatcher, IVrfProvider, Source};
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

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Marked {
        #[key]
        pub player: ContractAddress,
        pub position: Position,
        pub symbol: bool,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Ended {
        #[key]
        pub match_id: u32,
        pub winner: ContractAddress,
        pub finished: bool,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn start(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let matchmaker: Matchmaker = world.read_model(1);

            let VRF_PROVIDER_ADDRESS: ContractAddress = 0x051fea4450da9d6aee758bdeba88b2f665bcbf549d2c61421aa724e9ac0ced8f.try_into().unwrap();

            let vrf_provider = IVrfProviderDispatcher { contract_address: VRF_PROVIDER_ADDRESS };

            if matchmaker.last_board_ready || matchmaker.last_board == 0 {
                let zero_address: ContractAddress = 0.try_into().unwrap();
                let random_value = vrf_provider.consume_random(Source::Nonce(player));
                let match_id: u32 = (random_value % 1000000);
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

            let matchmaker: Matchmaker = world.read_model(1);

            let VRF_PROVIDER_ADDRESS: ContractAddress = 0x051fea4450da9d6aee758bdeba88b2f665bcbf549d2c61421aa724e9ac0ced8f.try_into().unwrap();

            let vrf_provider = IVrfProviderDispatcher { contract_address: VRF_PROVIDER_ADDRESS };

            let zero_address: ContractAddress = 0.try_into().unwrap();

            let random_value = vrf_provider.consume_random(Source::Nonce(player));
            let match_id: u32 = (random_value % 1000000); 
            
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
        fn mark(ref self: ContractState, position: Position) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let player_info: Player = world.read_model(player);
            let board: Board = world.read_model(player_info.match_id);

            assert(board.active, 'Match no longer active');
            assert(board.ready, 'Match not ready');
            assert(board.x == player || board.o == player, 'Not in this match');
            assert(player_info.turn, 'Not your turn');
            assert(array_contains_position(@board.empty, position), 'Position already marked');

            let mut player_x: Player = world.read_model(board.x);
            let mut player_o: Player = world.read_model(board.o);

            let board_empty = board.empty;
            let mut board_x = player_x.marks;
            let mut board_o = player_o.marks;

            let mut empty_board: Array<Position> = array![];
            for pos in board_empty {
                if pos != position {
                    empty_board.append(pos);
                }
            };

            if player == board.x {
                board_x.append(position);
                player_x =
                    Player {
                        address: player_x.address,
                        match_id: player_x.match_id,
                        marks: board_x,
                        turn: false,
                    };
                player_o =
                    Player {
                        address: player_o.address,
                        match_id: player_o.match_id,
                        marks: board_o,
                        turn: true,
                    };
                world.write_model(@player_o);
                world.write_model(@player_x);
            } else {
                board_o.append(position);
                player_o =
                    Player {
                        address: player_o.address,
                        match_id: player_o.match_id,
                        marks: board_o,
                        turn: false,
                    };
                player_x =
                    Player {
                        address: player_x.address,
                        match_id: player_x.match_id,
                        marks: board_x,
                        turn: true,
                    };
                world.write_model(@player_x);
                world.write_model(@player_o);
            }

            let new_board = Board {
                match_id: board.match_id,
                x: board.x,
                o: board.o,
                empty: empty_board,
                winner: board.winner,
                active: board.active,
                ready: board.ready,
            };

            world.write_model(@new_board);
            world.emit_event(@Marked { player, position, symbol: player == board.x });

            let updated_player: Player = world.read_model(player);

            if array_contains_position(@updated_player.marks, Position { i: position.i, j: 1 })
                && array_contains_position(@updated_player.marks, Position { i: position.i, j: 2 })
                && array_contains_position(
                    @updated_player.marks, Position { i: position.i, j: 3 },
                ) {
                self.end(updated_player.match_id, player, true);
            } else if array_contains_position(
                @updated_player.marks, Position { i: 1, j: position.j },
            )
                && array_contains_position(@updated_player.marks, Position { i: 2, j: position.j })
                && array_contains_position(
                    @updated_player.marks, Position { i: 3, j: position.j },
                ) {
                self.end(updated_player.match_id, player, true);
            };

            if position.i == position.j {
                if array_contains_position(@updated_player.marks, Position { i: 1, j: 1 })
                    && array_contains_position(@updated_player.marks, Position { i: 2, j: 2 })
                    && array_contains_position(@updated_player.marks, Position { i: 3, j: 3 }) {
                    self.end(updated_player.match_id, player, true);
                };
            } else if position.i + position.j == 4 {
                if array_contains_position(@updated_player.marks, Position { i: 1, j: 3 })
                    && array_contains_position(@updated_player.marks, Position { i: 2, j: 2 })
                    && array_contains_position(@updated_player.marks, Position { i: 3, j: 1 }) {
                    self.end(updated_player.match_id, player, true);
                };
            };

            let zero_address: ContractAddress = 0.try_into().unwrap();

            if new_board.empty.len() == 0 {
                self.end(updated_player.match_id, zero_address, true);
            };
        }
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
        fn read_board(self: @ContractState) -> (Array<Position>, Array<Position>, Array<Position>) {
            let mut world = self.world_default();
            let player = get_caller_address();
            let player_info: Player = world.read_model(player);
            let board: Board = world.read_model(player_info.match_id);

            let player_x: Player = world.read_model(board.x);
            let player_o: Player = world.read_model(board.o);

            let board_empty = board.empty;
            let board_x = player_x.marks;
            let board_o = player_o.marks;

            (board_empty, board_x, board_o)
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

pub fn array_contains_position(array: @Array<Position>, position: Position) -> bool {
    let mut res = false;
    for i in 0..array.len() {
        if array[i] == @position {
            res = true;
            break;
        }
    };
    res
}

#[cfg(test)]
mod actions_test {
    use super::{array_contains_position, Position};

    #[test]
    fn test_array_contains_position() {
        let array = array![Position { i: 1, j: 1 }, Position { i: 1, j: 2 }];
        let position1 = Position { i: 1, j: 1 };
        let position2 = Position { i: 2, j: 2 };
        assert(array_contains_position(@array, position1), 'Position not found');
        assert(!array_contains_position(@array, position2), 'Position found');
    }
}
