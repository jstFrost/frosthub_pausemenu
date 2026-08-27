import { useSession } from '../../state/store'
import Panel from '../Panel'
import DataRow from '../DataRow'

const IdentityPanel = () => {
  const { session } = useSession()
  const { locale: lang, player } = session

  return (
    <Panel title={lang.identity_title} delay="fh-d1">
      <div className="mb-[12px] pl-[11px] border-l-2" style={{ borderColor: 'var(--accent)' }}>
        <div className="text-[20px] font-bold leading-tight tracking-[1px] uppercase">{player.name || '—'}</div>
        <div className="fh-meta mt-[3px]">
          {lang.identity_id} {String(player.source ?? '—').padStart(2, '0')}
        </div>
      </div>

      <DataRow label={lang.identity_job} value={player.job} />
      {player.gang && <DataRow label={lang.identity_gang} value={player.gang} />}
    </Panel>
  )
}

export default IdentityPanel
