import { useEffect } from 'react'
import { useSession } from '../state/store'
import { callNui } from '../lib/nuiClient'

export function useNuiEvent() {
  const { dispatch } = useSession()

  useEffect(() => {
    const onMessage = (event) => {
      const data = event.data
      if (!data || typeof data.open === 'undefined') return

      if (data.open) {
        dispatch({ type: 'sync', payload: data })
      } else {
        dispatch({ type: 'closed' })
      }
    }

    window.addEventListener('message', onMessage)
    return () => window.removeEventListener('message', onMessage)
  }, [dispatch])

  useEffect(() => {
    const onKeyDown = (event) => {
      if (event.key !== 'Escape') return
      callNui('close')
      dispatch({ type: 'closed' })
    }

    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [dispatch])
}
