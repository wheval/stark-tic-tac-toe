#[cfg(test)]
mod tests {
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };

    use engine::systems::actions::{actions, IActionsDispatcher, IActionsDispatcherTrait};
    use engine::models::{Matchmaker, Board, Player, Position, m_Matchmaker, m_Board, m_Player};
    use actions::{e_Created, e_Started, e_Marked, e_Ended};

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "engine",
            resources: [
                TestResource::Model(m_Matchmaker::TEST_CLASS_HASH),
                TestResource::Model(m_Board::TEST_CLASS_HASH),
                TestResource::Model(m_Player::TEST_CLASS_HASH),
                TestResource::Event(e_Created::TEST_CLASS_HASH),
                TestResource::Event(e_Started::TEST_CLASS_HASH),
                TestResource::Event(e_Marked::TEST_CLASS_HASH),
                TestResource::Event(e_Ended::TEST_CLASS_HASH),
                TestResource::Contract(actions::TEST_CLASS_HASH),
            ]
                .span(),
        };

        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"engine", @"actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"engine")].span())
        ]
            .span()
    }


    #[test]
    fn test_start() {
        // let caller = starknet::contract_address_const::<0x0>();
        // let ndef = namespace_def();

        // let mut world = spawn_test_world([ndef].span());
        // world.sync_perms_and_inits(contract_defs());

        // let mut position: Position = world.read_model(caller);
    }

    #[test]
    fn test_start_private() {

    }

    #[test]
    fn test_join() {

    }

    #[test]
    fn test_mark() {

    }

    #[test]
    fn test_leave() {

    }

    #[test]
    fn test_read_board() {

    }
}

//     #[test]
//     fn test_world_test_set() {
//         // Initialize test environment
//         let caller = starknet::contract_address_const::<0x0>();
//         let ndef = namespace_def();

//         // Register the resources.
//         let mut world = spawn_test_world([ndef].span());

//         // Ensures permissions and initializations are synced.
//         world.sync_perms_and_inits(contract_defs());

//         // Test initial position
//         let mut position: Position = world.read_model(caller);
//         assert(position.vec.x == 0 && position.vec.y == 0, 'initial position wrong');

//         // Test write_model_test
//         position.vec.x = 122;
//         position.vec.y = 88;

//         world.write_model_test(@position);

//         let mut position: Position = world.read_model(caller);
//         assert(position.vec.y == 88, 'write_value_from_id failed');

//         // Test model deletion
//         world.erase_model(@position);
//         let position: Position = world.read_model(caller);
//         assert(position.vec.x == 0 && position.vec.y == 0, 'erase_model failed');
//     }

//     #[test]
//     #[available_gas(30000000)]
//     fn test_move() {
//         let caller = starknet::contract_address_const::<0x0>();

//         let ndef = namespace_def();
//         let mut world = spawn_test_world([ndef].span());
//         world.sync_perms_and_inits(contract_defs());

//         let (contract_address, _) = world.dns(@"actions").unwrap();
//         let actions_system = IActionsDispatcher { contract_address };

//         actions_system.spawn();
//         let initial_moves: Moves = world.read_model(caller);
//         let initial_position: Position = world.read_model(caller);

//         assert(
//             initial_position.vec.x == 10 && initial_position.vec.y == 10, 'wrong initial position',
//         );

//         actions_system.move(Direction::Right(()));

//         let moves: Moves = world.read_model(caller);
//         let right_dir_felt: felt252 = Direction::Right(()).into();

//         assert(moves.remaining == initial_moves.remaining - 1, 'moves is wrong');
//         assert(moves.last_direction.into() == right_dir_felt, 'last direction is wrong');

//         let new_position: Position = world.read_model(caller);
//         assert(new_position.vec.x == initial_position.vec.x + 1, 'position x is wrong');
//         assert(new_position.vec.y == initial_position.vec.y, 'position y is wrong');
//     }
// }
