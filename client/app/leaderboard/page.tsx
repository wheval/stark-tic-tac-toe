"use client"
import { ThemeProvider } from "next-themes"
import { Sun, Moon } from "lucide-react"
import { useTheme } from "next-themes"
import { useEffect, useState } from "react"

interface LeaderboardEntry {
  rank: number
  address: string
  totalPoints: number
  rewards: number
}

const leaderboardData: LeaderboardEntry[] = [
  { rank: 1, address: "0x053e...6f22", totalPoints: 100, rewards: 100 },
  { rank: 2, address: "0x1f2e...cdef", totalPoints: 75, rewards: 75 },
  { rank: 3, address: "0x9876...edcb", totalPoints: 50, rewards: 50 },
  { rank: 4, address: "0xabcd...56789", totalPoints: 25, rewards: 25 },
]

const ThemeToggle = () => {
  const { theme, setTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <button
      onClick={() => setTheme(theme === "light" ? "dark" : "light")}
      className="p-2 rounded-full bg-gray-200 dark:bg-[#112240] text-gray-800 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-[#1A1F2E] transition-colors duration-200"
    >
      {!mounted ? (
        <Moon size={24} /> // Default to dark theme icon
      ) : theme === "light" ? (
        <Moon size={24} />
      ) : (
        <Sun size={24} />
      )}
    </button>
  )
}

const MainContent = () => {
  const { theme } = useTheme()
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  if (!isMounted) {
    return null;
  }

  const currentTheme = isMounted ? theme : 'dark'
  const backgroundClass = currentTheme === 'light' 
    ? 'bg-gradient-to-br from-orange-300 via-amber-300 to-yellow-400' 
    : 'bg-gradient-to-br from-[#0a192f] via-[#0a192f] to-[#112240]'

  return (
    <div className={`${backgroundClass} min-h-screen transition-colors duration-300`}>
      <div className="container mx-auto px-4 py-12">
        <div className="max-w-5xl mx-auto">
          <div className="flex justify-between items-center mb-8">
            <h1 className="text-3xl font-bold text-gray-800 dark:text-white">Leaderboard</h1>
            <ThemeToggle />
          </div>
          <div className="p-8 rounded-2xl bg-white/10 dark:bg-[#112240]/50 backdrop-blur-sm">
            <LeaderboardTable />
          </div>
        </div>
      </div>
    </div>
  )
}

const LeaderboardTable = () => {
  return (
    <div className="overflow-hidden rounded-xl border border-gray-200 dark:border-gray-800">
      <table className="w-full">
        <thead className="bg-amber-100 dark:bg-[#1A1F2E]">
          <tr>
            <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase">
              Rank
            </th>
            <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase">
              Address
            </th>
            <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase">
              Total Points
            </th>
            <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase">
              Rewards
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 dark:divide-gray-800 bg-white/50 dark:bg-[#0A192F]/50">
          {leaderboardData.map((entry) => (
            <tr key={entry.rank} className="hover:bg-amber-50 dark:hover:bg-[#112240]">
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-700 dark:text-gray-200">
                {entry.rank}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-700 dark:text-gray-200">
                {entry.address.slice(0, 6)}...{entry.address.slice(-4)}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                {entry.totalPoints}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                ${entry.rewards}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default function LeaderboardPage() {
  return (
    <ThemeProvider attribute="class" defaultTheme="dark" enableSystem={false}>
      <MainContent />
    </ThemeProvider>
  )
}