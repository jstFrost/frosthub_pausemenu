/* eslint-disable react-refresh/only-export-components */
import { createContext, useContext, useReducer } from 'react'

const defaultTheme = {
  accent: '#d4e83a',
  accentSoft: 'rgba(212, 232, 58, 0.15)',
  panelBg: 'rgba(10, 12, 10, 0.72)',
  panelBorder: 'rgba(212, 232, 58, 0.25)',
  textPrimary: '#f2f4ec',
  textSecondary: 'rgba(242, 244, 236, 0.6)',
}

const defaultCurrency = {
  locale: 'en-US',
  symbol: '$',
  decimals: 2,
}

export const initialSession = {
  open: false,
  view: null,
  theme: defaultTheme,
  currency: defaultCurrency,
  locale: {},
  links: {},
  serverName: 'FROST HUB',
  player: {},
  street: 'Unknown location',
}

function sessionReducer(state, action) {
  switch (action.type) {
    case 'sync':
      return {
        ...state,
        open: !!action.payload.open,
        view: action.payload.view ?? state.view,
        theme: action.payload.theme && Object.keys(action.payload.theme).length ? action.payload.theme : state.theme,
        currency: action.payload.currency ?? state.currency,
        locale: action.payload.locale ?? state.locale,
        links: action.payload.links ?? state.links,
        serverName: action.payload.serverName ?? state.serverName,
        player: action.payload.player ?? state.player,
        street: action.payload.street ?? state.street,
      }
    case 'closed':
      return { ...state, open: false }
    default:
      return state
  }
}

const SessionContext = createContext(null)

export function SessionProvider({ children }) {
  const [session, dispatch] = useReducer(sessionReducer, initialSession)
  return (
    <SessionContext.Provider value={{ session, dispatch }}>
      {children}
    </SessionContext.Provider>
  )
}

export function useSession() {
  const ctx = useContext(SessionContext)
  if (!ctx) throw new Error('useSession must be used within a SessionProvider')
  return ctx
}
