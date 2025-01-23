"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"

export default function TicTacToeLanding() {
  const [gameId, setGameId] = useState("")
  const [showJoinDialog, setShowJoinDialog] = useState(false)

  const handleCreateGame = () => {
    console.log("Create custom game")
  }

  const handleJoinGame = () => {
    if (showJoinDialog) {
      console.log("Join game:", gameId)
      setShowJoinDialog(false)
      setGameId("")
    } else {
      setShowJoinDialog(true)
    }
  }

  const handleRandomMatch = () => {
    console.log("Random matchmaking")
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0a192f] via-[#0a192f] to-[#112240] text-white flex flex-col md:flex-row items-center justify-center p-4 md:space-x-12 lg:space-x-44">
      <GameBoard />
      <GameControls
        gameId={gameId}
        setGameId={setGameId}
        showJoinDialog={showJoinDialog}
        handleCreateGame={handleCreateGame}
        handleJoinGame={handleJoinGame}
        handleRandomMatch={handleRandomMatch}
      />
    </div>
  )
}

function GameBoard() {
  return (
    <motion.div
      className="mt-12 relative w-48 h-48"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 1.1, duration: 0.5 }}
    >
      <div className="absolute inset-0 grid grid-cols-3 gap-1">
        {[...Array(9)].map((_, index) => (
          <GameCell key={index} index={index} />
        ))}
      </div>
      <WinningLine />
    </motion.div>
  )
}

function GameCell({ index }: { index: number }) {
  if ([0, 4, 5, 7, 8].includes(index)) {
    return (
      <motion.span
        className="flex items-center justify-center text-5xl font-bold mt-3 text-red-600"
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ delay: 1.3 + index * 0.1, duration: 0.3 }}
      >
        X
      </motion.span>
    )
  } else if ([1, 2, 3, 6].includes(index)) {
    return (
      <motion.span
        className="flex items-center justify-center text-5xl font-bold mt-3 text-pink-400 animate-pulse-slow"
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ delay: 1.3 + index * 0.1, duration: 0.3 }}
      >
        O
      </motion.span>
    )
  }
  return <div className="flex items-center justify-center text-5xl font-bold mt-3" />
}

function WinningLine() {
  return (
    <motion.div
      className="absolute top-0 left-0 w-full h-full"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 3.2, duration: 0.5 }}
    >
      <svg className="w-full h-full">
        <motion.line
          x1="0"
          y1="0"
          x2="100%"
          y2="100%"
          stroke="#4ade80"
          strokeWidth="4"
          strokeLinecap="round"
          initial={{ pathLength: 0 }}
          animate={{ pathLength: 1 }}
          transition={{ delay: 3.2, duration: 0.8 }}
        />
      </svg>
    </motion.div>
  )
}

function GameControls({
  gameId,
  setGameId,
  showJoinDialog,
  handleCreateGame,
  handleJoinGame,
  handleRandomMatch,
}: {
  gameId: string
  setGameId: (id: string) => void
  showJoinDialog: boolean
  handleCreateGame: () => void
  handleJoinGame: () => void
  handleRandomMatch: () => void
}) {
  return (
    <div className="mt-8 md:mt-0">
      <motion.h1
        className="text-4xl sm:text-6xl font-bold mb-4 text-center md:text-left text-transparent bg-clip-text bg-gradient-to-r from-red-400 to-red-600"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        Tic-Tac-Toe
      </motion.h1>

      <motion.p
        className="text-xl sm:text-2xl mb-8 text-red-300 text-center md:text-left"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
      >
        Classic game, modern twist
      </motion.p>

      <div className="space-y-4 w-full max-w-lg">
        <GameButton
          onClick={handleCreateGame}
          className="bg-red-500 hover:bg-red-700"
          initial={{ opacity: 0, x: -50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.5, duration: 0.5 }}
          aria-label="Create Room"
        >
          Create Room
        </GameButton>

        <AnimatePresence>
          <motion.div
            className="w-full overflow-hidden"
            initial={showJoinDialog ? { height: 0 } : { height: "auto" }}
            animate={showJoinDialog ? { height: "auto" } : { height: 0 }}
            transition={{ duration: 0.3 }}
          >
            {showJoinDialog && (
              <input
                type="text"
                placeholder="Enter Game ID"
                value={gameId}
                onChange={(e) => setGameId(e.target.value)}
                className="w-full mb-2 py-2 px-4 bg-[#2d3748] text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-500 focus:ring-opacity-50"
                autoFocus
              />
            )}
          </motion.div>
        </AnimatePresence>

        <GameButton
          onClick={handleJoinGame}
          className="bg-pink-600 hover:bg-pink-700"
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.7, duration: 0.5 }}
          aria-label={showJoinDialog ? "Join Game" : "Join Room"}
        >
          {showJoinDialog ? "Join" : "Join Room"}
        </GameButton>

        <GameButton
          onClick={handleRandomMatch}
          className="bg-red-600 hover:bg-red-700"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9, duration: 0.5 }}
          aria-label="Play Random Match"
        >
          Play
        </GameButton>
      </div>
    </div>
  )
}

function GameButton({ children, className, ...props }: React.ComponentProps<typeof motion.button>) {
  return (
    <motion.button
      className={`w-full py-3 px-6 text-white rounded-lg transition-all duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-opacity-50 font-bold text-2xl ${className}`}
      {...props}
    >
      {children}
    </motion.button>
  )
}

