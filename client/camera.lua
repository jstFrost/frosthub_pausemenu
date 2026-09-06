FrostCam = {}

local activeCam = nil

function FrostCam.Exists()
    return activeCam ~= nil
end

function FrostCam.Start()
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end

    local settings = Config.Camera
    local ped = PlayerPedId()
    local anchor = GetOffsetFromEntityInWorldCoords(ped, 0.5, settings.distance, 0.0)

    local newCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(newCam, anchor.x, anchor.y, anchor.z + settings.height)
    SetCamFov(newCam, 38.0)
    SetCamRot(newCam, 0.0, 0.0, GetEntityHeading(ped) + 180.0)
    SetCamUseShallowDofMode(newCam, true)
    SetCamNearDof(newCam, 1.2)
    SetCamFarDof(newCam, 12.0)
    SetCamDofStrength(newCam, 1.0)
    SetCamDofMaxNearInFocusDistance(newCam, 1.0)

    if FrostCam.Exists() then
        SetCamActiveWithInterp(newCam, activeCam, settings.transitionMs, true, true)
        Wait(settings.transitionMs)
        DestroyCam(activeCam, false)
    else
        SetCamActive(newCam, true)
    end

    activeCam = newCam
    RenderScriptCams(true, true, 1350, true, false)
    TaskLookAtCoord(ped, anchor.x, anchor.y, anchor.z, 5000, 1, 1)

    CreateThread(function()
        while FrostCam.Exists() do
            SetUseHiDof()
            Wait(0)
        end
    end)
end

-- `instant` skips the blend, for teardown paths (resource stop) where the
-- interpolation would never get the frames it needs to finish.
function FrostCam.Stop(instant)
    if not activeCam then return end
    RenderScriptCams(false, true, instant and 0 or 1250, true, false)
    DestroyCam(activeCam, false)
    activeCam = nil
end
