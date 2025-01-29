'use client';

import { useState, useEffect } from 'react';
import { Account, RpcProvider, ec, stark } from 'starknet';
import { DojoProvider } from "@dojoengine/core";
import { DojoService } from '../dojo/services/dojoServices';
import { useGameStore, Position } from '../stores/state';
import worldABI from '../../WORLD_ABI.json';

export default function PlayPage() {
    const [account, setAccount] = useState<Account | null>(null);
    const [dojoService, setDojoService] = useState<DojoService | null>(null);
    const gameStore = useGameStore();

    useEffect(() => {
        setupStarknet();
    }, []);

    const setupStarknet = async () => {
        try {
            
            const manifest = {
                world: {
                    address: process.env.NEXT_PUBLIC_WORLD_ADDRESS,
                    abi: worldABI
                }
            };
            
            const rpcProvider = new RpcProvider({
                nodeUrl: process.env.NEXT_PUBLIC_STARKNET_RPC_URL || 'https://starknet-goerli.public.blastapi.io/rpc/v0_6'
            });

            const rpcUrl = process.env.NEXT_PUBLIC_STARKNET_RPC_URL || 'https://starknet-goerli.public.blastapi.io/rpc/v0_6';

            const privateKey = stark.randomAddress();
            
            const publicKey = ec.starkCurve.getStarkKey(privateKey);
            
            const account = new Account(
                rpcProvider, 
                publicKey, 
                privateKey
            );
            setAccount(account);

            const dojoProvider = new DojoProvider(
                manifest, 
                rpcUrl
            );

            const service = new DojoService(dojoProvider, account);
            setDojoService(service);

            gameStore.setAddress(account.address);
        } catch (error) {
            console.error('Starknet setup error:', error);
        }
    };

    const handleStart = async () => {
        if (!dojoService) {
            alert('Please wait for account setup');
            return;
        }
        await dojoService.start();
    };

    const handleJoin = async () => {
        if (!dojoService) {
            alert('Please wait for account setup');
            return;
        }
        await dojoService.join(1);
    };

    const handleMark = async () => {
        if (!dojoService) {
            alert('Please wait for account setup');
            return;
        }
        
        const position: Position = { i: 1, j: 1 };
        await dojoService.mark(position);
    };

    const handleReadBoard = async () => {
        if (!dojoService) {
            alert('Please wait for account setup');
            return;
        }
        
        const [empty, x, o] = await dojoService.readBoard();
        console.log('Board state:', { empty, x, o });
    };

    return (
        <div className="p-6 max-w-md mx-auto">
            <h1 className="text-2xl font-bold mb-4">Tic Tac Toe - Dojo Test</h1>

            <div className="space-y-4">
                <div>
                    <p>Account: {account?.address || 'Not Connected'}</p>
                </div>

                <div className="grid grid-cols-2 gap-4">
                    <button 
                        onClick={handleStart} 
                        className="bg-green-500 text-white px-4 py-2 rounded disabled:opacity-50"
                        disabled={!dojoService}
                    >
                        Start Match
                    </button>

                    <button 
                        onClick={handleJoin} 
                        className="bg-blue-500 text-white px-4 py-2 rounded disabled:opacity-50"
                        disabled={!dojoService}
                    >
                        Join Match
                    </button>

                    <button 
                        onClick={handleMark} 
                        className="bg-red-500 text-white px-4 py-2 rounded disabled:opacity-50"
                        disabled={!dojoService}
                    >
                        Mark Position (1,1)
                    </button>

                    <button 
                        onClick={handleReadBoard} 
                        className="bg-purple-500 text-white px-4 py-2 rounded disabled:opacity-50"
                        disabled={!dojoService}
                    >
                        Read Board
                    </button>
                </div>

                <div className="mt-4 p-4 bg-gray-100 rounded">
                    <h2 className="font-bold mb-2">Current Board State:</h2>
                    <pre className="text-sm">
                        {JSON.stringify({
                            emptySquares: gameStore.emptySquares,
                            xSquares: gameStore.xSquares,
                            oSquares: gameStore.oSquares
                        }, null, 2)}
                    </pre>
                </div>
            </div>
        </div>
    );
}