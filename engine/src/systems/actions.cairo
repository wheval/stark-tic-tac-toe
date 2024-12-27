// use dojo_starter::models::{Direction, Position};

// // define the interface
// #[starknet::interface]
// trait IActions<T> {
//     fn spawn(ref self: T);
//     fn move(ref self: T, direction: Direction);
// }

// // dojo decorator
// #[dojo::contract]
// pub mod actions {
//     use super::{IActions, Direction, Position, next_position};
//     use starknet::{ContractAddress, get_caller_address};
//     use dojo_starter::models::{Vec2, Moves, DirectionsAvailable};

//     use dojo::model::{ModelStorage, ModelValueStorage};
//     use dojo::event::EventStorage;

//     #[derive(Copy, Drop, Serde)]
//     #[dojo::event]
//     pub struct Moved {
//         #[key]
//         pub player: ContractAddress,
//         pub direction: Direction,
//     }

//     #[abi(embed_v0)]
//     impl ActionsImpl of IActions<ContractState> {
//         fn spawn(ref self: ContractState) {
//             // Get the default world.
//             let mut world = self.world_default();

//             // Get the address of the current caller, possibly the player's address.
//             let player = get_caller_address();
//             // Retrieve the player's current position from the world.
//             let position: Position = world.read_model(player);

//             // Update the world state with the new data.

//             // 1. Move the player's position 10 units in both the x and y direction.
//             let new_position = Position {
//                 player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
//             };

//             // Write the new position to the world.
//             world.write_model(@new_position);

//             // 2. Set the player's remaining moves to 100.
//             let moves = Moves {
//                 player, remaining: 100, last_direction: Direction::None(()), can_move: true
//             };

//             // Write the new moves to the world.
//             world.write_model(@moves);
//         }

//         // Implementation of the move function for the ContractState struct.
//         fn move(ref self: ContractState, direction: Direction) {
//             // Get the address of the current caller, possibly the player's address.

//             let mut world = self.world_default();

//             let player = get_caller_address();

//             // Retrieve the player's current position and moves data from the world.
//             let position: Position = world.read_model(player);
//             let mut moves: Moves = world.read_model(player);

//             // Deduct one from the player's remaining moves.
//             moves.remaining -= 1;

//             // Update the last direction the player moved in.
//             moves.last_direction = direction;

//             // Calculate the player's next position based on the provided direction.
//             let next = next_position(position, direction);

//             // Write the new position to the world.
//             world.write_model(@next);

//             // Write the new moves to the world.
//             world.write_model(@moves);

//             // Emit an event to the world to notify about the player's move.
//             world.emit_event(@Moved { player, direction });
//         }
//     }

//     #[generate_trait]
//     impl InternalImpl of InternalTrait {
//         /// Use the default namespace "dojo_starter". This function is handy since the ByteArray
//         /// can't be const.
//         fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
//             self.world(@"dojo_starter")
//         }
//     }
// }

// // Define function like this:
// fn next_position(mut position: Position, direction: Direction) -> Position {
//     match direction {
//         Direction::None => { return position; },
//         Direction::Left => { position.vec.x -= 1; },
//         Direction::Right => { position.vec.x += 1; },
//         Direction::Up => { position.vec.y -= 1; },
//         Direction::Down => { position.vec.y += 1; },
//     };
//     position
// }

use engine::models::{Position};

#[starknet::interface]
trait IActions<T> {
    fn start(ref self: T);
    fn start_private(ref self: T);
    fn join(ref self: T, match_id: u32);
    fn mark(ref self: T, position: Position);
    fn leave(ref self: T);
    fn read_board(self: @T) -> Map<Position, bool>;
}

#[dojo::contract]
pub mod actions {
    use super::{IActions, Position};
    use starknet::{ContractAddress, get_caller_address};
    use engine::models::{Matchmaker, Board, Player};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    use openzeppelin::utils::serde::SerializedAppend;


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

            if matchmaker.last_board_ready {
                let zero_address: ContractAddress = 0.try_into().unwrap();
                let match_id = matchmaker.last_board + 1;
                let mut empty_board: Array<Position> = array![];
                for i in 1..4_u8 {
                    for j in 1..4_u8 {
                        empty_board.append_serde(Position { i, j });
                    }
                }

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
        fn start_private(ref self: T) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let matchmaker: Matchmaker = world.read_model(1);

            let zero_address: ContractAddress = 0.try_into().unwrap();
            let match_id = matchmaker.last_board + 1;
            let mut empty_board: Array<Position> = array![];
            for i in 1..4_u8 {
                for j in 1..4_u8 {
                    empty_board.append_serde(Position { i, j });
                }
            }

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
        fn join(ref self: T, match_id: u32) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let matchmaker: Matchmaker = world.read_model(1);

            let board: Board = world.read_model(match_id);

            let zero_address: ContractAddress = 0.try_into().unwrap();
            assert(board.x != zero_address, "Match not found");

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
        fn mark(ref self: ContractState, position: Position) {}
        fn leave(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let player_info: Player = world.read_model(player);

            let board: Board = world.read_model(player_info.match_id);

            let mut winner: ContractAddress = board.x;
            if player = board.x {
                winner = board.o;
            }

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
            world.emit_event(@Ended { match_id: board.match_id, winner, finished: false });
        }
        fn read_board(self: @ContractState) -> Map<Position, u8> {
            let mut world = self.world_default();
            let player = get_caller_address();
            let board: Board = world.read_model(player);

            let player_x: Player = world.read_model(board.x);
            let player_o: Player = world.read_model(board.o);

            let board_empty = board.empty;
            let board_x = player_x.marks;
            let board_o = player_o.marks;

            let mut board_map: Map<Position, u8> = map![];
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"engine")
        }
    }
}
