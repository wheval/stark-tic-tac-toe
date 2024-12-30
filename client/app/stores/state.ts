import { create } from 'zustand';

type Position = {
    i: number,
    j: number
}

type Store = {
    address: string,
    matchId: number,
    // true if X, false if O
    me: boolean,
    emptySquares: Position[],
    xSquares: Position[],
    oSquares: Position[],
}

export const useGameStore = create<Store>()((set) => ({
    address: '',
    matchId: 0,
    me: true,
    emptySquares: [
        {i: 1, j: 1},
        {i: 1, j: 2},
        {i: 1, j: 3},
        {i: 2, j: 1},
        {i: 2, j: 2},
        {i: 2, j: 3},
        {i: 3, j: 1},
        {i: 3, j: 2},
        {i: 3, j: 3},
    ],
    xSquares: [],
    oSquares: [],
    setAddress: (address: string) => set({address}),
    setMatchId: (matchId: number) => set({matchId}),
    setMe: (me: boolean) => set({me}),
    markX: (pos: Position) => {
        set((state) => ({
            emptySquares: state.emptySquares.filter(
                (square) => square.i !== pos.i || square.j !== pos.j
            ),
            xSquares: [...state.xSquares, pos],
        }));
    },
    markO: (pos: Position) => {
        set((state) => ({
            emptySquares: state.emptySquares.filter(
                (square) => square.i !== pos.i || square.j !== pos.j
            ),
            oSquares: [...state.oSquares, pos],
        }));
    },
}))