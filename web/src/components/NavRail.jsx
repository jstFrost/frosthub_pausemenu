import { useSession } from '../state/store'
import { callNui } from '../lib/nuiClient'
import { IconHome, IconMap, IconSettings, IconExit } from './icons'

const NavRail = () => {
  const { session, dispatch } = useSession()
  const lang = session.locale

  const close = () => {
    callNui('close')
    dispatch({ type: 'closed' })
  }

  const items = [
    { id: 'home', label: lang.nav_home, Icon: IconHome, active: true },
    { id: 'map', label: lang.nav_map, Icon: IconMap, action: 'openMap' },
    { id: 'settings', label: lang.nav_settings, Icon: IconSettings, action: 'openSettings' },
    { id: 'exit', label: lang.nav_exit, Icon: IconExit, action: 'leave' },
  ]

  return (
    <nav className="fh-panel fh-rail-in w-[232px] shrink-0 py-[18px] flex flex-col">
      <span className="fh-eyebrow px-[16px] mb-[12px]">{lang.nav_title}</span>

      {items.map(({ id, label, Icon, active, action }) => (
        <button
          key={id}
          className={`fh-nav-item ${active ? 'is-active' : ''}`}
          onClick={action ? () => callNui(action) : undefined}
        >
          <Icon />
          <span>{label}</span>
        </button>
      ))}

      <div className="mt-auto px-[16px] pt-[18px]">
        <button onClick={close} className="flex items-center gap-[10px]">
          <span
            className="px-[11px] py-[4px] text-[11px] font-bold tracking-[2px]"
            style={{
              color: 'var(--accent)',
              border: '1px solid var(--accent)',
              clipPath: 'polygon(0 0, calc(100% - 6px) 0, 100% 6px, 100% 100%, 6px 100%, 0 calc(100% - 6px))',
            }}
          >
            ESC
          </span>
          <span className="fh-meta">{lang.footer_close}</span>
        </button>
      </div>
    </nav>
  )
}

export default NavRail
