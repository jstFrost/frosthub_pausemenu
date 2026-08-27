import { useSession } from '../../state/store'
import Panel from '../Panel'

const Unit = ({ value, label }) => (
  <div className="flex-1 text-center">
    <div className="text-[30px] font-bold leading-none tabular-nums">{String(value).padStart(2, '0')}</div>
    <div className="fh-meta mt-[6px]">{label}</div>
  </div>
)

const PlaytimePanel = () => {
  const { session } = useSession()
  const { locale: lang, player } = session

  const seconds = Number(player.playSeconds) || 0
  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)

  return (
    <Panel title={lang.playtime_title} delay="fh-d3">
      <div className="flex flex-1 items-center justify-center">
        <Unit value={days} label={lang.playtime_days} />
        <Unit value={hours} label={lang.playtime_hours} />
        <Unit value={minutes} label={lang.playtime_minutes} />
      </div>
    </Panel>
  )
}

export default PlaytimePanel
