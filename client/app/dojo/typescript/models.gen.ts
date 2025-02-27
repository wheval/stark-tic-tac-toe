import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { BigNumberish } from 'starknet';

// Type definition for `engine::models::Board` struct
export interface Board {
	match_id: BigNumberish;
	x: string;
	o: string;
	empty: Array<Position>;
	winner: string;
	active: boolean;
	ready: boolean;
}

// Type definition for `engine::models::BoardValue` struct
export interface BoardValue {
	x: string;
	o: string;
	empty: Array<Position>;
	winner: string;
	active: boolean;
	ready: boolean;
}

// Type definition for `engine::models::Matchmaker` struct
export interface Matchmaker {
	server: BigNumberish;
	last_board: BigNumberish;
	last_board_ready: boolean;
}

// Type definition for `engine::models::MatchmakerValue` struct
export interface MatchmakerValue {
	last_board: BigNumberish;
	last_board_ready: boolean;
}

// Type definition for `engine::models::Player` struct
export interface Player {
	address: string;
	match_id: BigNumberish;
	marks: Array<Position>;
	turn: boolean;
}

// Type definition for `engine::models::PlayerValue` struct
export interface PlayerValue {
	match_id: BigNumberish;
	marks: Array<Position>;
	turn: boolean;
}

// Type definition for `engine::models::Position` struct
export interface Position {
	i: BigNumberish;
	j: BigNumberish;
}

// Type definition for `engine::systems::play::play::Ended` struct
export interface Ended {
	match_id: BigNumberish;
	winner: string;
	finished: boolean;
}

// Type definition for `engine::systems::play::play::EndedValue` struct
export interface EndedValue {
	winner: string;
	finished: boolean;
}

// Type definition for `engine::systems::play::play::Marked` struct
export interface Marked {
	player: string;
	position: Position;
	symbol: boolean;
}

// Type definition for `engine::systems::play::play::MarkedValue` struct
export interface MarkedValue {
	position: Position;
	symbol: boolean;
}

// Type definition for `engine::systems::start::start::Created` struct
export interface Created {
	match_id: BigNumberish;
	server: BigNumberish;
}

// Type definition for `engine::systems::start::start::CreatedValue` struct
export interface CreatedValue {
	server: BigNumberish;
}

// Type definition for `engine::systems::start::start::Started` struct
export interface Started {
	match_id: BigNumberish;
	x: string;
	o: string;
}

// Type definition for `engine::systems::start::start::StartedValue` struct
export interface StartedValue {
	x: string;
	o: string;
}

export interface SchemaType extends ISchemaType {
	engine: {
		Board: Board,
		BoardValue: BoardValue,
		Matchmaker: Matchmaker,
		MatchmakerValue: MatchmakerValue,
		Player: Player,
		PlayerValue: PlayerValue,
		Position: Position,
		Ended: Ended,
		EndedValue: EndedValue,
		Marked: Marked,
		MarkedValue: MarkedValue,
		Created: Created,
		CreatedValue: CreatedValue,
		Started: Started,
		StartedValue: StartedValue,
	},
}
export const schema: SchemaType = {
	engine: {
		Board: {
			match_id: 0,
			x: "",
			o: "",
			empty: [{ i: 0, j: 0, }],
			winner: "",
			active: false,
			ready: false,
		},
		BoardValue: {
			x: "",
			o: "",
			empty: [{ i: 0, j: 0, }],
			winner: "",
			active: false,
			ready: false,
		},
		Matchmaker: {
			server: 0,
			last_board: 0,
			last_board_ready: false,
		},
		MatchmakerValue: {
			last_board: 0,
			last_board_ready: false,
		},
		Player: {
			address: "",
			match_id: 0,
			marks: [{ i: 0, j: 0, }],
			turn: false,
		},
		PlayerValue: {
			match_id: 0,
			marks: [{ i: 0, j: 0, }],
			turn: false,
		},
		Position: {
			i: 0,
			j: 0,
		},
		Ended: {
			match_id: 0,
			winner: "",
			finished: false,
		},
		EndedValue: {
			winner: "",
			finished: false,
		},
		Marked: {
			player: "",
		position: { i: 0, j: 0, },
			symbol: false,
		},
		MarkedValue: {
		position: { i: 0, j: 0, },
			symbol: false,
		},
		Created: {
			match_id: 0,
			server: 0,
		},
		CreatedValue: {
			server: 0,
		},
		Started: {
			match_id: 0,
			x: "",
			o: "",
		},
		StartedValue: {
			x: "",
			o: "",
		},
	},
};
export enum ModelsMapping {
	Board = 'engine-Board',
	BoardValue = 'engine-BoardValue',
	Matchmaker = 'engine-Matchmaker',
	MatchmakerValue = 'engine-MatchmakerValue',
	Player = 'engine-Player',
	PlayerValue = 'engine-PlayerValue',
	Position = 'engine-Position',
	Ended = 'engine-Ended',
	EndedValue = 'engine-EndedValue',
	Marked = 'engine-Marked',
	MarkedValue = 'engine-MarkedValue',
	Created = 'engine-Created',
	CreatedValue = 'engine-CreatedValue',
	Started = 'engine-Started',
	StartedValue = 'engine-StartedValue',
}