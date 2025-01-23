"use client"

import { useState, useEffect } from "react"
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
    <div className="min-h-screen bg-gradient-to-br from-[#1a0b2e] via-[#1a0b2e] to-[#2c1250] text-white flex flex-col md:flex-row items-center justify-center p-4 md:space-x-12 lg:space-x-44">
      <ParticleBackground />
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
    // <motion.div
    //   className="mt-12 relative w-48 h-48"
    //   initial={{ opacity: 0 }}
    //   animate={{ opacity: 1 }}
    //   transition={{ delay: 1.1, duration: 0.5 }}
    // >
    //   <div className="absolute inset-0 grid grid-cols-3 gap-1">
    //     {[...Array(9)].map((_, index) => (
    //       <GameCell key={index} index={index} />
    //     ))}
    //   </div>
    //   <WinningLine />
    // </motion.div>

    <div className="relative">
      <CircularGlowingEffect />
      <motion.div
        className="mt-12 relative w-64 h-64 z-10"
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.5, duration: 0.8, type: "spring" }}
      >
        <div className="absolute inset-0 grid grid-cols-3 gap-2 p-4 bg-opacity-20 bg-purple-900 backdrop-blur-sm rounded-xl shadow-2xl">
          {[...Array(9)].map((_, index) => (
            <GameCell key={index} index={index} />
          ))}
        </div>
        <WinningLine />
      </motion.div>
    </div>
  )
}

function CircularGlowingEffect() {
  return (
    <div className="absolute inset-0 z-0">
      <div className="absolute inset-0 bg-gradient-to-r from-pink-500 via-purple-500 to-blue-500 rounded-full blur-3xl opacity-30 animate-pulse-glow" />
    </div>
  )
}


function GameCell({ index }: { index: number }) {
  const cellContent = [0, 4, 5, 7, 8].includes(index) ? "X" : [1, 2, 3, 6].includes(index) ? "O" : ""
  const cellColor = cellContent === "X" ? "text-red-400" : "text-pink-400"

  return (
    <motion.div
      className={`flex items-center justify-center text-5xl font-bold ${cellColor} bg-opacity-20 bg-purple-800 rounded-lg shadow-inner`}
      initial={{ scale: 0, rotateY: -180 }}
      animate={{ scale: 1, rotateY: 0 }}
      transition={{ delay: 1.3 + index * 0.1, duration: 0.5, type: "spring" }}
    >
      {cellContent}
    </motion.div>
  )

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
          transition={{ delay: 3.2, duration: 1.2, ease: "easeInOut" }}
        />
        <defs>
          <linearGradient id="lineGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#4ade80" />
            <stop offset="100%" stopColor="#3b82f6" />
          </linearGradient>
        </defs>
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
    <div className="mt-8 md:mt-0 z-10">
      <motion.h1
        className="text-5xl sm:text-7xl font-bold mb-4 text-center md:text-left "
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, type: "spring"  }}
      >
        <span className="text-transparent bg-clip-text bg-gradient-to-r from-pink-500 to-violet-500">
        Tic-Tac-Toe</span>
      </motion.h1>

      <motion.p
        className="text-xl sm:text-2xl mb-8 text-purple-300 text-center md:text-left ml-10"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
      >
        Classic game, modern twist
      </motion.p>

      <div className="space-y-4 w-full max-w-lg">
        <GameButton
          onClick={handleCreateGame}
          className="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700"
          initial={{ opacity: 0, x: -50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.5, duration: 0.5 }}
          aria-label="Create Room"
        >
          Create Room
        </GameButton>

        <AnimatePresence>
          <motion.div
            className="w-full overflow-hidden mb-10"
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
                className="w-full mb-2 py-2 px-4 bg-purple-900 bg-opacity-50 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-500 focus:ring-opacity-50 placeholder-purple-300"
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
          className="bg-gradient-to-r from-purple-500 to-indigo-600 hover:from-purple-600 hover:to-indigo-700"
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
      className={`w-full py-3 px-6 text-white rounded-lg transition-all duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-opacity-50 font-bold text-xl shadow-lg ${className}`}
      {...props}
    >
      {children}
    </motion.button>
  )
}

function ParticleBackground() {
  if (typeof window === "undefined") return null
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {[...Array(50)].map((_, i) => (
        <Particle key={i} />
      ))}
    </div>
  )
}

function Particle() {
  const randomPosition = () => ({
    x: Math.random() * window.innerWidth,
    y: Math.random() * window.innerHeight,
  })

  const [position, setPosition] = useState(randomPosition)

  useEffect(() => {
    const interval = setInterval(
      () => {
        setPosition(randomPosition())
      },
      Math.random() * 10000 + 5000,
    )

    return () => clearInterval(interval)
  }, [])

  return (
    <motion.div
      className="absolute w-1 h-1 bg-white rounded-full"
      style={{
        left: position.x,
        top: position.y,
      }}
      animate={{
        scale: [1, 1.5, 1],
        opacity: [0.2, 0.8, 0.2],
      }}
      transition={{
        duration: Math.random() * 2 + 1,
        repeat: Number.POSITIVE_INFINITY,
        ease: "easeInOut",
      }}
    />
  )
}



