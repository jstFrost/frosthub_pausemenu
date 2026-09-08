import NavRail from './NavRail'
import Masthead from './Masthead'
import IdentityPanel from './panels/IdentityPanel'
import AssetsPanel from './panels/AssetsPanel'
import PlaytimePanel from './panels/PlaytimePanel'
import ConnectPanel from './panels/ConnectPanel'

const Console = () => (
  <div className="w-[1120px] flex flex-col gap-[32px]">
    <Masthead />

    <div className="flex gap-[26px] items-stretch">
      <NavRail />
      <div className="flex-1 grid grid-cols-2 gap-[26px]">
        <IdentityPanel />
        <AssetsPanel />
        <PlaytimePanel />
        <ConnectPanel />
      </div>
    </div>
  </div>
)

export default Console
