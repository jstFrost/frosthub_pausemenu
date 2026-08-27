import { useEffect, useState } from 'react'

const DESIGN_HEIGHT = 1080

export function useStageScale() {
  const [scale, setScale] = useState(() => window.innerHeight / DESIGN_HEIGHT)

  useEffect(() => {
    const update = () => setScale(window.innerHeight / DESIGN_HEIGHT)
    update()
    window.addEventListener('resize', update)
    return () => window.removeEventListener('resize', update)
  }, [])

  return scale
}
