"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Moon, Sun } from "lucide-react";

interface SquareProps {
  value: string | null;
  onClick: () => void;
  winningSquare: boolean;
}

const Square: React.FC<SquareProps> = ({ value, onClick, winningSquare }) => (
  <motion.button
    onClick={onClick}
    className={`w-20 h-20 md:w-24 md:h-24 border-4 text-4xl font-bold flex items-center justify-center rounded-lg shadow-lg
      ${
        winningSquare
          ? "bg-yellow-300 border-yellow-500 text-orange-700 dark:bg-gray-900 dark:border-slate-300 dark:text-orange-200"
          : "bg-white border-orange-500 hover:bg-orange-100 dark:bg-[#0a192f] dark:border-red-700 dark:hover:bg-gray-800"
      }`}
    whileHover={{ scale: 1.05 }}
    whileTap={{ scale: 0.95 }}
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
  >
    {value && (
      <motion.span
        initial={{ scale: 0, rotate: -180 }}
        animate={{ scale: 1, rotate: 0 }}
        className={
          value === "X"
            ? "text-blue-600 dark:text-blue-400"
            : "text-red-600 dark:text-red-400"
        }
      >
        {value}
      </motion.span>
    )}
  </motion.button>
);

const TicTacToe = () => {
  const [squares, setSquares] = useState<(string | null)[]>(
    Array(9).fill(null)
  );
  const [xIsNext, setXIsNext] = useState(true);
  const [xScore, setXScore] = useState(0);
  const [oScore, setOScore] = useState(0);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [showWinnerAlert, setShowWinnerAlert] = useState<string | null>(null);

  const calculateWinner = (squares: (string | null)[]) => {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (const [a, b, c] of lines) {
      if (
        squares[a] &&
        squares[a] === squares[b] &&
        squares[a] === squares[c]
      ) {
        return { winner: squares[a], line: [a, b, c] };
      }
    }
    return null;
  };

  const winner = calculateWinner(squares);
  const isDraw = !winner && squares.every((square) => square !== null);

  const handleClick = (i: number) => {
    if (squares[i] || winner) return;

    const newSquares = squares.slice();
    newSquares[i] = xIsNext ? "X" : "O";
    setSquares(newSquares);
    setXIsNext(!xIsNext);

    const gameWinner = calculateWinner(newSquares);
    if (gameWinner) {
      setShowWinnerAlert(`Winner: ${gameWinner.winner}`);
      if (gameWinner.winner === "X") {
        setXScore((prev) => prev + 1);
      } else {
        setOScore((prev) => prev + 1);
      }
    } else if (newSquares.every((square) => square !== null)) {
      setShowWinnerAlert("It's a Draw!");
    }
  };

  const resetGame = () => {
    setSquares(Array(9).fill(null));
    setXIsNext(true);
    setShowWinnerAlert(null);
  };

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode);
    document.documentElement.classList.toggle("dark");
  };

  useEffect(() => {
    const prefersDark = window.matchMedia(
      "(prefers-color-scheme: dark)"
    ).matches;
    setIsDarkMode(prefersDark);

    if (prefersDark) {
      document.documentElement.classList.add("dark");
    }
  }, []);

  useEffect(() => {
    if (!showWinnerAlert) return;
    const timeout = setTimeout(() => setShowWinnerAlert(null), 3000);
    return () => clearTimeout(timeout);
  }, [showWinnerAlert]);

  return (
    <div className="min-h-screen">
      <div className="bg-gradient-to-br from-orange-300 via-amber-300 to-yellow-400 dark:from-[#0a192f] dark:via-[#0a192f] dark:to-[#112240] text-gray-900 dark:text-gray-100 transition-colors duration-300 min-h-screen">
        <div className="container mx-auto px-4 py-8 flex flex-col items-center justify-center min-h-screen">
          <motion.h1
            className="text-4xl md:text-6xl font-bold mb-8 text-transparent bg-clip-text bg-gradient-to-r from-orange-600 to-amber-600 dark:from-red-500 dark:to-red-700"
            initial={{ y: -50, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
          >
            Tic Tac Toe
          </motion.h1>

          <motion.div
            className="grid grid-cols-3 gap-2 mb-8"
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
          >
            {squares.map((square, i) => (
              <Square
                key={i}
                value={square}
                onClick={() => handleClick(i)}
                winningSquare={winner?.line?.includes(i) ?? false}
              />
            ))}
          </motion.div>

          <AnimatePresence mode="wait">
            {showWinnerAlert && (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.8 }}
                className="bg-orange-500 dark:bg-red-600 text-gray-800 dark:text-gray-100 py-2 px-4 rounded-lg mb-4 font-bold text-lg shadow-lg"
              >
                {showWinnerAlert}
              </motion.div>
            )}
          </AnimatePresence>

          <motion.div className="flex justify-center space-x-8 mb-8">
            <div className="text-center">
              <span className="text-xl font-bold text-blue-700 dark:text-blue-400">
                X Score:
              </span>
              <motion.span
                key={xScore}
                className="ml-2 text-2xl"
                initial={{ scale: 1.5, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
              >
                {xScore}
              </motion.span>
            </div>
            <div className="text-center">
              <span className="text-xl font-bold text-red-700 dark:text-red-400">
                O Score:
              </span>
              <motion.span
                key={oScore}
                className="ml-2 text-2xl"
                initial={{ scale: 1.5, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
              >
                {oScore}
              </motion.span>
            </div>
          </motion.div>

          <motion.div
            className="h-8 text-xl text-gray-100"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            key={winner?.winner || isDraw ? "result" : "next"}
          >
            {winner
              ? `Winner: ${winner.winner}`
              : isDraw
              ? "Draw!"
              : `Next player: ${xIsNext ? "X" : "O"}`}
          </motion.div>

          <motion.button
            onClick={resetGame}
            className="px-6 py-3 bg-gradient-to-r from-orange-500 to-amber-500 dark:from-red-800 dark:to-red-500 text-white rounded-lg text-lg font-semibold shadow-lg hover:from-orange-600 hover:to-amber-600 dark:hover:from-red-500 dark:hover:to-red-800 transition-colors duration-300"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Reset Game
          </motion.button>

          <motion.button
            onClick={toggleTheme}
            className="mt-4 p-2 rounded-full bg-gray-200 dark:bg-gray-800 text-gray-800 dark:text-gray-200"
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
          >
            {isDarkMode ? <Sun size={24} /> : <Moon size={24} />}
          </motion.button>
        </div>
      </div>
    </div>
  );
};

export default TicTacToe;
