'use client';

import { createContext, useContext, useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';

type Theme = 'vanilla' | 'dark' | 'neon' | 'nature';

interface ThemeContextType {
  theme: Theme;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const searchParams = useSearchParams();
  const [theme, setTheme] = useState<Theme>('vanilla');

  useEffect(() => {
    const themeParam = searchParams.get('theme') as Theme;
    if (themeParam && ['vanilla', 'dark', 'neon', 'nature'].includes(themeParam)) {
      setTheme(themeParam);
    }
  }, [searchParams]);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}