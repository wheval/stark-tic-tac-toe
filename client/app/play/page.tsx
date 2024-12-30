"use client"
import { useState } from 'react';
import { motion } from 'framer-motion';

interface SquareProps {
  value: string | null;
  onClick: () => void;
  winningSquare: boolean;
}

const Square: React.FC<SquareProps> = ({ value, onClick, winningSquare }) => (
  <motion.button
    onClick={onClick}
    className={`w-24 h-24 border border-gray-600 text-4xl font-bold flex items-center justify-center
      ${winningSquare ? 'bg-emerald-900/20' : 'hover:bg-gray-800/50'}`}
    whileHover={{ scale: 0.95 }}
    whileTap={{ scale: 0.9 }}
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
  >
    {value && (
      <motion.span
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        className={value === 'X' ? 'text-emerald-400' : 'text-purple-400'}
      >
        {value}
      </motion.span>
    )}
  </motion.button>
);

const TicTacToe = () => {
  const [squares, setSquares] = useState<(string | null)[]>(Array(9).fill(null));
  const [xIsNext, setXIsNext] = useState(true);
  
  const calculateWinner = (squares: (string | null)[]) => {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], 
      [0, 3, 6], [1, 4, 7], [2, 5, 8], 
      [0, 4, 8], [2, 4, 6] 
    ];
    
    for (const [a, b, c] of lines) {
      if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
        return { winner: squares[a], line: [a, b, c] };
      }
    }
    return null;
  };

  const winner = calculateWinner(squares);
  const isDraw = !winner && squares.every(square => square !== null);
  
  const handleClick = (i: number) => {
    if (squares[i] || calculateWinner(squares)) return;
    
    const newSquares = squares.slice();
    newSquares[i] = xIsNext ? 'X' : 'O';
    setSquares(newSquares);
    setXIsNext(!xIsNext);
  };

  const resetGame = () => {
    setSquares(Array(9).fill(null));
    setXIsNext(true);
  };

  return (
    <div className="min-h-screen bg-gray-900 flex items-center justify-center">
      <div className="flex flex-col items-center gap-8">
        <motion.h1 
          className="text-4xl font-bold text-gray-100"
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
        >
          Tic Tac Toe
        </motion.h1>
        
        <div className="grid grid-cols-3 gap-2">
          {squares.map((square, i) => (
            <Square
              key={i}
              value={square}
              onClick={() => handleClick(i)}
              winningSquare={winner?.line?.includes(i) ?? false}
            />
          ))}
        </div>
        
        <motion.div 
          className="h-8 text-xl text-gray-100"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          key={winner?.winner || isDraw ? 'result' : 'next'}
        >
          {winner ? 
            `Winner: ${winner.winner}` : 
            isDraw ? 
              'Draw!' : 
              `Next player: ${xIsNext ? 'X' : 'O'}`
          }
        </motion.div>
        
        <motion.button
          onClick={resetGame}
          className="px-4 py-2 bg-gray-800 text-gray-100 rounded-lg hover:bg-gray-700"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Reset Game
        </motion.button>
      </div>
    </div>
  );
};

export default TicTacToe;