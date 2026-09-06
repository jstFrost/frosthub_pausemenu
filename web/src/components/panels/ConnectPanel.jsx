import { useSession } from '../../state/store'
import Panel from '../Panel'
import { IconDiscord, IconStore } from '../icons'

const ConnectPanel = () => {
  const { session } = useSession()
  const { locale: lang, links } = session

  const open = (url) => url && window.invokeNative && window.invokeNative('openUrl', url)

  const entries = [
    { id: 'discord', label: lang.connect_discord, Icon: IconDiscord, url: links.discord },
    { id: 'store', label: lang.connect_store, Icon: IconStore, url: links.store },
  ]

  return (
    <Panel title={lang.connect_title} delay="fh-d4">
      <p className="text-[12px] leading-[1.5] mb-[14px]" style={{ color: 'var(--text-secondary)' }}>
        {lang.connect_description}
      </p>
      <div className="mt-auto flex gap-[14px]">
        {entries.map(({ id, label, Icon, url }) => (
          <button key={id} onClick={() => open(url)} className="flex items-center gap-[9px]">
            <span className="fh-round">
              <Icon />
            </span>
            <span className="fh-meta">{label}</span>
          </button>
        ))}
      </div>
    </Panel>
  )
}

export default ConnectPanel
