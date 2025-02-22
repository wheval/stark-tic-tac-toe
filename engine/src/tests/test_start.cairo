#[cfg(test)]
mod tests {
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage};
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };
    use starknet::{ContractAddress, contract_address_const, testing};

    use engine::systems::play::{play, IPlayDispatcher};
    use engine::systems::start::{start, IStartDispatcher, IStartDispatcherTrait};
    use engine::systems::read_board::{read_board, IReadBoardDispatcher};
    use engine::models::{Board, m_Board, Player, m_Player, Matchmaker, m_Matchmaker};

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "engine",
            resources: [
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
            ]
            .span(),
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
                .with_writer_of([dojo::utils::bytearray_hash(@"engine")].span()),
        ]
        .span()
    }

    #[derive(Drop, Copy)]
    pub struct GameContext {
        pub world: WorldStorage,
        pub play_dispatcher: IPlayDispatcher,
        pub start_dispatcher: IStartDispatcher,
        pub board_dispatcher: IReadBoardDispatcher,
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

    /// TESTS

    #[test]
    fn test_start_creates_new_match() {
        // Case when no pending board exists so that start creates a new match
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        testing::set_contract_address(player1);
        context.start_dispatcher.start();

        // The public start function uses a hardcoded match_id 123456 when creating a new board
        let board: Board = context.world.read_model(123456);
        // Board.x is set to the caller
        assert(board.x == player1, 'P1 not X');
        // Board.ready flag is false, since we're waiting for a second player
        assert(!board.ready, 'Board not ready');

        // Check matchmaker state recorded under key 1
        let matchmaker: Matchmaker = context.world.read_model(1);
        assert(matchmaker.last_board == 123456, 'Last board error');
        assert(!matchmaker.last_board_ready, 'Last flag error');
    }

    #[test]
    fn test_start_join_existing_match() {
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        let player2 = contract_address_const::<'PLAYER2'>();

        // Player1 creates a board using start.
        testing::set_contract_address(player1);
        context.start_dispatcher.start();

        // Player2 then joins the board using join.
        testing::set_contract_address(player2);
        context.start_dispatcher.join(123456);

        // Read board to confirm player2 was added as O and board is updated.
        let board: Board = context.world.read_model(123456);
        assert(board.o == player2, 'P2 not O');
        assert(board.ready, 'Board not ready');

        // Check the matchmaker is updated to mark the board ready.
        let matchmaker: Matchmaker = context.world.read_model(1);
        assert(matchmaker.last_board_ready, 'Last flag false');
    }

    #[test]
    fn test_start_private_creates_match() {
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        testing::set_contract_address(player1);
        context.start_dispatcher.start_private();

        // For private matches, the match_id is generated dynamically.
        // We use the matchmaker state to retrieve the last generated match id.
        let matchmaker: Matchmaker = context.world.read_model(1);
        let match_id = matchmaker.last_board;
        let board: Board = context.world.read_model(match_id);
        // Private match assigns the caller as X and marks the board as immediately ready.
        assert(board.x == player1, 'P1 not X');
        assert(board.ready, 'Board not ready');

        // Read player info
        let player_info: Player = context.world.read_model(match_id);
        // In private mode the starting player does not take the turn immediately.
        assert(!player_info.turn, 'Turn flag error');
    }

    #[test]
    fn test_multiple_private_games() {
        let mut context = setup_world();

        let player1 = contract_address_const::<'PLAYER1'>();
        testing::set_contract_address(player1);
        context.start_dispatcher.start_private();
        let matchmaker1: Matchmaker = context.world.read_model(1);
        let match_id1 = matchmaker1.last_board;

        // Simulate a new private game by setting a different caller.
        let player3 = contract_address_const::<'PLAYER3'>();
        testing::set_contract_address(player3);
        context.start_dispatcher.start_private();
        let matchmaker2: Matchmaker = context.world.read_model(1);
        let match_id2 = matchmaker2.last_board;

        // They must differ.
        assert(match_id1 != match_id2, 'Match id eq');
    }

    #[test]
    fn test_start_after_full_match() {
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        let player2 = contract_address_const::<'PLAYER2'>();
        let player3 = contract_address_const::<'PLAYER3'>();

        // First game: p1 starts and p2 joins.
        testing::set_contract_address(player1);
        context.start_dispatcher.start();
        testing::set_contract_address(player2);
        context.start_dispatcher.join(123456);

        // Now board is full; next start should create a new board.
        testing::set_contract_address(player3);
        context.start_dispatcher.start();
        let board: Board = context.world.read_model(123456);
        // New board should now have p3 as X with ready false.
        assert(board.x == player3, 'P3 not X');
        assert(!board.ready, 'Flag err');

        let matchmaker: Matchmaker = context.world.read_model(1);
        assert(matchmaker.last_board == 123456, 'Bad bid');
        assert(!matchmaker.last_board_ready, 'Bad flag');
    }
    #[test]
    fn test_join_invalid_board() {
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        testing::set_contract_address(player1);
        // Call join() for a match id that was never created.
        context.start_dispatcher.join(999999);
        let board: Board = context.world.read_model(999999);
        // Expect board.x remains zero address.
        let zero_address: ContractAddress = 0.try_into().unwrap();
        assert(board.x == zero_address, 'X zero');
        assert(board.o == player1, 'P1 not O');
        assert(board.ready, 'Not ready');
    }

    #[test]
    fn test_start_twice_same_player() {
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        testing::set_contract_address(player1);
        context.start_dispatcher.start();
        // Second call by same player triggers join branch.
        context.start_dispatcher.start();

        let board: Board = context.world.read_model(123456);
        // Since join() is called, board.o should be set to player1 and ready true.
        assert(board.x == player1, 'P1 as X');
        assert(board.o == player1, 'P1 as O');
        assert(board.ready, 'Not ready');
    }

    #[test]
    fn test_start_private_same_player_twice() {
        let mut context = setup_world();
        let player1 = contract_address_const::<'PLAYER1'>();
        testing::set_contract_address(player1);
        context.start_dispatcher.start_private();
        let matchmaker1: Matchmaker = context.world.read_model(1);
        let match_id1 = matchmaker1.last_board;
        // Second private game call.
        context.start_dispatcher.start_private();
        let matchmaker2: Matchmaker = context.world.read_model(1);
        let match_id2 = matchmaker2.last_board;

        assert(match_id1 != match_id2, 'Id coll');
    }
}