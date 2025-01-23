"use client"

import type React from "react"
import { createContext, useState, useContext, useEffect, useRef } from "react"

interface MusicContextType {
  isPlaying: boolean
  toggleMusic: () => void
  musicPath: string
}

const MusicContext = createContext<MusicContextType | undefined>(undefined)

export const MusicProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isPlaying, setIsPlaying] = useState(false)
  const audioRef = useRef<HTMLAudioElement | null>(null)

  const musicPath = "/audio/music-for-puzzle-game-146738.mp3"

  const attemptPlay = async () => {
    if (audioRef.current) {
      try {
        await audioRef.current.play()
        setIsPlaying(true)
      } catch (error) {
        console.error("Autoplay failed:", error)
        setIsPlaying(false)
      }
    }
  }

  const toggleMusic = async () => {
    if (audioRef.current) {
      if (isPlaying) {
        audioRef.current.pause()
        setIsPlaying(false)
      } else {
        try {
          await audioRef.current.play()
          setIsPlaying(true)
        } catch (error) {
          console.error("Playback failed:", error)
        }
      }
    }
  }

  useEffect(() => {
    attemptPlay()
  }, [])

  useEffect(() => {
    const audioElement = audioRef.current
    if (audioElement) {
      const handleEnded = () => setIsPlaying(false)
      audioElement.addEventListener("ended", handleEnded)
      return () => {
        audioElement.removeEventListener("ended", handleEnded)
      }
    }
  }, [])

  return (
    <MusicContext.Provider value={{ isPlaying, toggleMusic, musicPath }}>
      <audio ref={audioRef} src={musicPath} loop />
      {children}
    </MusicContext.Provider>
  )
}

export const useMusic = () => {
  const context = useContext(MusicContext)
  if (!context) {
    throw new Error("useMusic must be used within a MusicProvider")
  }
  return context
}

