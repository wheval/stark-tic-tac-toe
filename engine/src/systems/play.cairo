use engine::models::{Position};

#[starknet::interface]
pub trait IPlay<T> {
    fn mark(ref self: T, position: Position);
}

#[dojo::contract]
pub mod play {
    use super::{IPlay, Position, array_contains_position};
    use starknet::{ContractAddress, get_caller_address};
    use engine::models::{Board, Player};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

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
    impl ActionsImpl of IPlay<ContractState> {
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
