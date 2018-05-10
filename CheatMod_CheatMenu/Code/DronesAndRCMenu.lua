function ChoGGi.DronesAndRCMenu_LoadingScreenPreClose()
  --ChoGGi.AddAction(Menu,Action,Key,Des,Icon)

  local iconD = "ShowAll.tga"
  local iconRC = "HostGame.tga"

  ChoGGi.AddAction(
    "Expanded CM/Drones/Work Radius RC Rover",
    ChoGGi.SetRoverWorkRadius,
    nil,
    "Change RC drone radius.",
    "DisableRMMaps.tga"
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Work Radius DroneHub",
    ChoGGi.SetDroneHubWorkRadius,
    nil,
    "Change DroneHub drone radius.",
    "DisableRMMaps.tga"
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Rock To Concrete Speed",
    ChoGGi.SetRockToConcreteSpeed,
    nil,
    "How long it takes drones to convert rock to concrete.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Move Speed",
    ChoGGi.SetDroneMoveSpeed,
    nil,
    "How fast drones will move.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Change Amount Of Drones In Hub",
    ChoGGi.SetDroneAmountDroneHub,
    "Shift-D",
    "Select a DroneHub then change the amount of drones in said hub (dependent on prefab amount).",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/DroneFactory Build Speed",
    ChoGGi.SetDroneFactoryBuildSpeed,
    nil,
    "Change how fast drone factories build drones.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Gravity",
    ChoGGi.SetGravityDrones,
    nil,
    "Change gravity of Drones.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Battery Infinite",
    ChoGGi.DroneBatteryInfinite_Toggle,
    nil,
    function()
      local des = ChoGGi.NumRetBool(Consts.DroneMoveBatteryUse,"(Disabled)","(Enabled)")
      return des .. " Drone Battery Infinite."
    end,
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Build Speed",
    ChoGGi.DroneBuildSpeed_Toggle,
    nil,
    function()
      local des = ""
      if Consts.DroneConstructAmount == 999900 then
        des = "(Enabled)"
      else
        des = "(Disabled)"
      end
      return des .. " Instant build/repair when resources are ready."
    end,
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Meteor Malfunction",
    ChoGGi.DroneMeteorMalfunction_Toggle,
    nil,
    function()
      local des = ChoGGi.NumRetBool(Consts.DroneMeteorMalfunctionChance,"(Disabled)","(Enabled)")
      return des .. " Drones will not malfunction when close to a meteor impact site."
    end,
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Recharge Time",
    ChoGGi.DroneRechargeTime_Toggle,
    nil,
    function()
      local des = ChoGGi.NumRetBool(Consts.DroneRechargeTime,"(Disabled)","(Enabled)")
      return des .. " Faster Drone Recharge."
    end,
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Repair Supply Leak Speed",
    ChoGGi.DroneRepairSupplyLeak_Toggle,
    nil,
    function()
      local des = ChoGGi.NumRetBool(Consts.DroneRepairSupplyLeak,"(Disabled)","(Enabled)")
      return des .. " Faster Drone fix supply leak."
    end,
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drone Carry Amount",
    ChoGGi.SetDroneCarryAmount,
    nil,
    "Change amount drones can carry.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drones Per Drone Hub",
    ChoGGi.SetDronesPerDroneHub,
    nil,
    "Change amount of drones Drone Hubs will command.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Drones/Drones Per RC Rover",
    ChoGGi.SetDronesPerRCRover,
    nil,
    "Change amount of drones RC Rovers will command.",
    iconD
  )

  -------------Shuttles
  ChoGGi.AddAction(
    "Expanded CM/Shuttles/Set ShuttleHub Shuttle Amount",
    ChoGGi.SetShuttleHubCapacity,
    nil,
    "Change amount of shuttles per shuttlehub.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Shuttles/Set Capacity",
    ChoGGi.SetShuttleCapacity,
    nil,
    "Change capacity of shuttles.",
    "scale_gizmo.tga"
  )

  ChoGGi.AddAction(
    "Expanded CM/Shuttles/Set Speed",
    ChoGGi.SetShuttleSpeed,
    nil,
    "Change speed of shuttles.",
    "move_gizmo.tga"
  )

  -------------RCs
  ChoGGi.AddAction(
    "Expanded CM/Rovers/Set Charging Distance",
    ChoGGi.SetRoverChargeRadius,
    nil,
    "Distance from power lines that rovers can charge.",
    iconRC
  )

  ChoGGi.AddAction(
    "Expanded CM/Rovers/RC Move Speed",
    ChoGGi.SetRCMoveSpeed,
    nil,
    "How fast RCs will move.",
    "move_gizmo.tga"
  )

  ChoGGi.AddAction(
    "Expanded CM/Rovers/RC Gravity",
    ChoGGi.SetGravityRC,
    nil,
    "Change gravity of RCs.",
    iconD
  )

  ChoGGi.AddAction(
    "Expanded CM/Rovers/RC Rover Drone Recharge Free",
    ChoGGi.RCRoverDroneRechargeFree_Toggle,
    nil,
    function()
      local des = ChoGGi.NumRetBool(Consts.RCRoverDroneRechargeCost,"(Disabled)","(Enabled)")
      return des .. " No more draining Rover Battery when recharging drones."
    end,
    iconRC
  )

  ChoGGi.AddAction(
    "Expanded CM/Rovers/RC Transport Instant Transfer",
    ChoGGi.RCTransportInstantTransfer_Toggle,
    nil,
    function()
      local des = ChoGGi.NumRetBool(Consts.RCRoverTransferResourceWorkTime,"(Disabled)","(Enabled)")
      return des .. " RC Rover quick Transfer/Gather resources."
    end,
    "Mirror.tga"
  )

  ChoGGi.AddAction(
    "Expanded CM/Rovers/RC Transport Storage Capacity",
    ChoGGi.SetRCTransportStorageCapacity,
    nil,
    "Change amount of resources RC Transports can carry.",
    "scale_gizmo.tga"
  )

end
