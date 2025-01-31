import { DojoProvider } from "@dojoengine/core";
import { Account, AccountInterface, BigNumberish } from "starknet";
import * as models from "./models.gen";

export function setupWorld(provider: DojoProvider) {

    const actions_start = async (snAccount: Account | AccountInterface) => {
		try {
			return await provider.execute(
				snAccount,
				[
					{
						contractName: "actions",
						entrypoint: "start",
						calldata: [],
					}
				],
				"engine"
			);
		} catch (error) {
			console.error("Error in actions_start:", error);
			throw error;
		}
	};	
	

    const actions_startPrivate = async (snAccount: Account | AccountInterface) => {
        try {
            return await provider.execute(
                snAccount,
                {
                    contractName: "actions",
                    entrypoint: "start_private",
                    calldata: [],
                },
                "engine",
            );
        } catch (error) {
            console.error("Error in actions_startPrivate:", error);
            throw error;
        }
    };

    const actions_join = async (snAccount: Account | AccountInterface, matchId: BigNumberish) => {
        try {
            return await provider.execute(
                snAccount,
                {
                    contractName: "actions",
                    entrypoint: "join",
                    calldata: [matchId],
                },
                "engine",
            );
        } catch (error) {
            console.error("Error in actions_join:", error);
            throw error;
        }
    };

    const actions_mark = async (snAccount: Account | AccountInterface, position: models.Position) => {
        try {
            return await provider.execute(
                snAccount,
                {
                    contractName: "actions",
                    entrypoint: "mark",
                    calldata: [position.i.toString(), position.j.toString()],
                },
                "engine",
            );
        } catch (error) {
            console.error("Error in actions_mark:", error);
            throw error;
        }
    };

    const actions_leave = async (snAccount: Account | AccountInterface) => {
        try {
            return await provider.execute(
                snAccount,
                {
                    contractName: "actions",
                    entrypoint: "leave",
                    calldata: [],
                },
                "engine",
            );
        } catch (error) {
            console.error("Error in actions_leave:", error);
            throw error;
        }
    };

    const actions_readBoard = async () => {
		try {
			return await provider.call("actions", {
				contractName: "actions",
				entrypoint: "read_board",
				calldata: []
			});
		} catch (error) {
			console.error("Error in actions_readBoard:", error);
			throw error;
		}
	};

    return {
        actions: {
            start: actions_start,
            startPrivate: actions_startPrivate,
            join: actions_join,
            mark: actions_mark,
            leave: actions_leave,
            readBoard: actions_readBoard,
        },
    };
}
