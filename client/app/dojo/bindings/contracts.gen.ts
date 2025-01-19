import { DojoProvider } from "@dojoengine/core";
import { Account, AccountInterface, BigNumberish } from "starknet";
import * as models from "./models.gen";

export function setupWorld(provider: DojoProvider) {

	const actions_start = async (snAccount: Account | AccountInterface) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions",
					entrypoint: "start",
					calldata: [],
				},
				"engine",
			);
		} catch (error) {
			console.error(error);
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
			console.error(error);
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
			console.error(error);
		}
	};

	const actions_mark = async (snAccount: Account | AccountInterface, position: models.Position) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions",
					entrypoint: "mark",
					calldata: [position],
				},
				"engine",
			);
		} catch (error) {
			console.error(error);
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
			console.error(error);
		}
	};

	const actions_readBoard = async () => {
		try {
			return await provider.call("engine", {
				contractName: "actions",
				entrypoint: "read_board",
				calldata: [],
			});
		} catch (error) {
			console.error(error);
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