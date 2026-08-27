import { useSession } from './state/store'
import { useNuiEvent } from './hooks/useNuiEvent'
import { useStageScale } from './hooks/useStageScale'
import Console from './components/Console'

function App() {
  useNuiEvent()
  const { session } = useSession()
  const scale = useStageScale()

  if (!session.open) return null

  const t = session.theme
  const themeVars = {
    '--accent': t.accent,
    '--accent-soft': t.accentSoft,
    '--panel-bg': t.panelBg,
    '--panel-border': t.panelBorder,
    '--text-primary': t.textPrimary,
    '--text-secondary': t.textSecondary,
    '--fh-scale': scale,
  }

  const isSide = session.view === 'side'

  return (
    <div className="w-full h-full relative overflow-hidden" style={themeVars}>
      <div className={`absolute inset-0 ${isSide ? 'fh-scrim-side' : 'fh-scrim-center'}`} />
      <div
        className="fh-accent-glow absolute pointer-events-none"
        style={isSide
          ? { width: '150vh', height: '150vh', left: '-45vh', top: '50%', transform: 'translateY(-50%)' }
          : { width: '190vh', height: '190vh', left: '50%', top: '50%', transform: 'translate(-50%, -50%)' }}
      />

      <div className={`absolute inset-0 flex items-center ${isSide ? 'justify-start' : 'justify-center'}`}>
        <div className="fh-stage" style={isSide ? { marginLeft: '5vw' } : undefined}>
          <Console />
        </div>
      </div>
    </div>
  )
}

export default App
