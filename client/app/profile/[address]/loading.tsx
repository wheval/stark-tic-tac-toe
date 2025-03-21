export default function Loading() {
    return (
      <div className="min-h-screen bg-gradient-to-br from-orange-300 via-amber-300 to-yellow-400 dark:from-[#0a192f] dark:via-[#0a192f] dark:to-[#112240] flex items-center justify-center">
        <div className="bg-white/80 dark:bg-[#112240]/80 p-8 rounded-xl shadow-lg text-center">
          <div
            className="inline-block h-12 w-12 animate-spin rounded-full border-4 border-solid border-orange-500 dark:border-red-500 border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
            role="status"
          >
            <span className="!absolute !-m-px !h-px !w-px !overflow-hidden !whitespace-nowrap !border-0 !p-0 ![clip:rect(0,0,0,0)]">
              Loading...
            </span>
          </div>
          <h2 className="mt-4 text-xl font-semibold">Loading Profile...</h2>
        </div>
      </div>
    );
  }
  