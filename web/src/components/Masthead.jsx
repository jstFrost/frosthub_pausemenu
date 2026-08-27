import { useSession } from '../state/store'
import { IconPin } from './icons'
import logo from '../assets/frosthub-logo.svg'

const Masthead = () => {
  const { session } = useSession()

  return (
    <header className="flex items-center gap-[16px] fh-in">
      <img src={logo} alt="" className="w-[42px] h-[42px]" />
      <div className="leading-none">
        <div className="text-[19px] font-bold tracking-[3px] uppercase">{session.serverName}</div>
        <div className="flex items-center gap-[5px] mt-[5px]" style={{ color: 'var(--text-secondary)' }}>
          <IconPin style={{ width: 12, height: 12, color: 'var(--accent)' }} />
          <span className="fh-meta">{session.street}</span>
        </div>
      </div>
    </header>
  )
}

export default Masthead
