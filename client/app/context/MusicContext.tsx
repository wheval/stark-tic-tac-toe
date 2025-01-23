"use client";

import React, { createContext, useState, useContext, useEffect, useRef } from "react";

interface MusicContextType {
  isPlaying: boolean;
  toggleMusic: () => void;
  musicPath: string;
}

const MusicContext = createContext<MusicContextType | undefined>(undefined);

export const MusicProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isPlaying, setIsPlaying] = useState(false); // Start with audio paused
  const audioRef = useRef<HTMLAudioElement | null>(null);

  const musicPath = "/audio/music-for-puzzle-game-146738.mp3";

  const toggleMusic = () => {
    setIsPlaying((prev) => !prev);
  };

  useEffect(() => {
    if (audioRef.current) {
      if (isPlaying) {
        audioRef.current.play().catch((error) => {
          console.error("Audio playback failed:", error);
        });
      } else {
        audioRef.current.pause();
      }
    }
  }, [isPlaying]);

  return (
    <MusicContext.Provider value={{ isPlaying, toggleMusic, musicPath }}>
      <audio ref={audioRef} src={musicPath} loop />
      {children}
    </MusicContext.Provider>
  );
};

export const useMusic = () => {
  const context = useContext(MusicContext);
  if (!context) {
    throw new Error("useMusic must be used within a MusicProvider");
  }
  return context;
};
