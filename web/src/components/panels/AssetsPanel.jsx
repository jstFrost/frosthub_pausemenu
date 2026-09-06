import { useSession } from '../../state/store'
import { formatMoney } from '../../lib/format'
import Panel from '../Panel'
import DataRow from '../DataRow'

const AssetsPanel = () => {
  const { session } = useSession()
  const { locale: lang, player, currency } = session

  const cash = Number(player.cash) || 0
  const bank = Number(player.bank) || 0

  return (
    <Panel title={lang.assets_title} delay="fh-d2">
      <div className="mb-[12px] pl-[11px] border-l-2" style={{ borderColor: 'var(--accent)' }}>
        <div className="text-[20px] font-bold leading-tight tracking-[0.5px]">{formatMoney(cash + bank, currency)}</div>
        <div className="fh-meta mt-[3px]">{lang.assets_total}</div>
      </div>

      <DataRow label={lang.assets_cash} value={formatMoney(cash, currency)} accent />
      <DataRow label={lang.assets_bank} value={formatMoney(bank, currency)} />
    </Panel>
  )
}

export default AssetsPanel
