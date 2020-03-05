import { useState, useEffect } from "react"

type WH = {
  width: number
  height: number
}

const getWindowSize = (): WH => {
  const { innerWidth: width, innerHeight: height } = window
  return { width, height }
}

export const useWindowSize = (): WH => {
  const [windowSize, setWindowSize] = useState<WH>(getWindowSize())

  useEffect(() => {
    const handleResize = () => setWindowSize(getWindowSize())
    window.addEventListener("resize", handleResize)
    return () => window.removeEventListener("resize", handleResize)
  }, [])

  return windowSize
}

export default useWindowSize
