import { useEffect, useState } from 'react'

const DESIGN_HEIGHT = 1080
const MIN_SCALE = 0.8
const MAX_SCALE = 2

// Clamped so a small windowed client does not shrink the 10px labels into
// something unreadable, and an oversized one does not blow the stage up.
const stageScale = () =>
  Math.min(MAX_SCALE, Math.max(MIN_SCALE, window.innerHeight / DESIGN_HEIGHT))

export function useStageScale() {
  const [scale, setScale] = useState(stageScale)

  useEffect(() => {
    const update = () => setScale(stageScale())
    update()
    window.addEventListener('resize', update)
    return () => window.removeEventListener('resize', update)
  }, [])

  return scale
}
