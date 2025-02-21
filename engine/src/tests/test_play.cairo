#[cfg(test)]
mod tests {
    use dojo::event::EventStorageTest;
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };
    use starknet::{ContractAddress, contract_address_const, testing};

    use engine::systems::play::{play, IPlayDispatcher, IPlayDispatcherTrait};
    use engine::systems::start::{start, IStartDispatcher, IStartDispatcherTrait};
    use engine::systems::read_board::{read_board, IReadBoardDispatcher, IReadBoardDispatcherTrait};
    use engine::models::{Board, m_Board, Player, m_Player, Matchmaker, m_Matchmaker, Position};

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "engine", resources: [
                TestResource::Model(m_Board::TEST_CLASS_HASH),
                TestResource::Model(m_Player::TEST_CLASS_HASH),
                TestResource::Model(m_Matchmaker::TEST_CLASS_HASH),
                TestResource::Contract(play::TEST_CLASS_HASH),
                TestResource::Contract(start::TEST_CLASS_HASH),
                TestResource::Contract(read_board::TEST_CLASS_HASH),
                TestResource::Event(play::e_Marked::TEST_CLASS_HASH),
                TestResource::Event(play::e_Ended::TEST_CLASS_HASH),
                TestResource::Event(start::e_Created::TEST_CLASS_HASH),
                TestResource::Event(start::e_Started::TEST_CLASS_HASH),
            ].span()
        };

        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"engine", @"play")
                .with_writer_of([dojo::utils::bytearray_hash(@"engine")].span()),
            ContractDefTrait::new(@"engine", @"start")
                .with_writer_of([dojo::utils::bytearray_hash(@"engine")].span()),
            ContractDefTrait::new(@"engine", @"read_board")
                .with_writer_of([dojo::utils::bytearray_hash(@"engine")].span())
        ].span()
    }

    #[derive(Drop, Copy)]
    pub struct GameContext {
        pub world: WorldStorage,
        pub play_dispatcher: IPlayDispatcher,
        pub start_dispatcher: IStartDispatcher,
        pub board_dispatcher: IReadBoardDispatcher
    }

    fn setup_world() -> GameContext {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (play_contract, _) = world.dns(@"play").unwrap();
        let (start_contract, _) = world.dns(@"start").unwrap();
        let (board_contract, _) = world.dns(@"read_board").unwrap();
        let play_dispatcher = IPlayDispatcher { contract_address: play_contract };
        let start_dispatcher = IStartDispatcher { contract_address: start_contract };
        let board_dispatcher = IReadBoardDispatcher { contract_address: board_contract };

        GameContext { world, play_dispatcher, start_dispatcher, board_dispatcher }
    }

    fn init_default_game(dispatcher: IStartDispatcher) -> (ContractAddress, ContractAddress) {
        let player_1 = contract_address_const::<'PLAYER 1'>();
        let player_2 = contract_address_const::<'PLAYER 2'>();

        testing::set_contract_address(player_1);
        let match_id: u32 = 123456;
        dispatcher.start();
        testing::set_contract_address(player_2);
        dispatcher.join(match_id);

        (player_1, player_2)
    }

    /// Utility function that feigns a gameplay, allowing player 2 win
    fn feign_win(players: Array<ContractAddress>, context: GameContext) {
        let (mut available_positions, _, _) = context.board_dispatcher.read_board();

        // make five moves for both players to win a game
        // array pos at 1, 3 and 5 should win a game
        let player_moves: Array<usize> = array![4, 1, 0, 2, 8];
        let mut current_pos = 1; // Player 2 starts

        for move in player_moves {
            let current_player = *players.at(current_pos);
            let position = *available_positions.at(move);
            testing::set_contract_address(current_player);
            context.play_dispatcher.mark(position);
            current_pos = (current_pos + 1) % 2;
            println!("Player {:?}: marked at {} {}", current_player, position.i, position.j);
        };

        // game ended, player 2 wins
        let board: Board = context.world.read_model(123456);
        assert(board.winner == *players.at(1), 'FEIGN WIN ERROR');
    }

    /// TESTS

    #[test]
    fn test_play_mark_success() {
        let mut context = setup_world();
        let (_, player_2) = init_default_game(context.start_dispatcher);

        let (_, board_x, mut board_o) = context.board_dispatcher.read_board();
        println!("Board x length: {}", board_x.len());
        assert(board_o.len() == 0, 'INIT FAILURE');

        // play, say center
        testing::set_contract_address(player_2);
        let position = Position { i: 2, j: 2 };
        context.play_dispatcher.mark(position);
        let (_, _, mut board_o) = context.board_dispatcher.read_board();
        assert(board_o.pop_front().unwrap() == position, '1. MARK FAILED');
        let event = play::Marked { player: player_2, position, symbol: true };
        context.world.emit_event_test(@event);

        // next player
        let player: Player = context.world.read_model(player_2);
        assert(!player.turn, 'OUT OF TURN');
    }

    #[test]
    fn test_play_should_allow_a_player_win() {
        let mut context = setup_world();
        let (player_1, player_2) = init_default_game(context.start_dispatcher);
        feign_win(array![player_1, player_2], context);
        let event = play::Ended { match_id: 12345, winner: player_2, finished: true };
        context.world.emit_event_test(@event);
    }
    // #[test]
// #[should_panic(expected: 'Match no longer Active')]
// fn test_play_mark_should_panic_for_invalid_player() {
//     // From the code implementation, this error message is inevitable for this scenario
//     let context = setup_world();
//     let (_, _) = init_default_game(context.start_dispatcher);

    //     let invalid_player = contract_address_const::<'INVALID PLAYER'>();
//     testing::set_contract_address(invalid_player);
//     let position = Position { i: 2, j: 2 };
//     context.play_dispatcher.mark(position);
// }

    // #[test]
// #[should_panic(expected: 'Position already marked')]
// fn test_play_mark_should_panic_on_already_marked_position() {
//     let context = setup_world();
//     let (player_1, player_2) = init_default_game(context.start_dispatcher);
//     let position = Position { i: 2, j: 2 };
//     testing::set_contract_address(player_2);
//     context.play_dispatcher.mark(position);

    //     testing::set_contract_address(player_1);
//     context.play_dispatcher.mark(position); // should panic
// }

    // #[test]
// #[should_panic(expected: 'Not your turn')]
// fn test_play_should_panic_on_player_misturn() {
//     let context = setup_world();
//     let (player_1, player_2) = init_default_game(context.start_dispatcher);
//     let position = Position { i: 2, j: 2 };
//     testing::set_contract_address(player_2);
//     context.play_dispatcher.mark(position);

    //     let position = Position { i: 1, j: 1 };
//     testing::set_contract_address(player_1);
//     context.play_dispatcher.mark(position);

    //     let position = Position { i: 2, j: 1 };
//     context.play_dispatcher.mark(position);
// }

    // #[test]
// #[should_panic(expected: 'Match no longer Active')]
// fn test_play_should_panic_on_match_ended() {
//     let context = setup_world();
//     let (player_1, player_2) = init_default_game(context.start_dispatcher);
//     feign_win(array![player_1, player_2], context);
//     // since player 2 has won, let player 1 make a move
//     let position = Position { i: 3, j: 1 };
//     context.play_dispatcher.mark(position);
// }
}
