function OnMsg.Autorun()

  --if the menu order gets changed this won't work
  XTemplates.PGMenu[1][2][3][5].__condition = function(parent, context)
    --return Platform.steam or Platform.pc
    return Platform.steam or Platform.pc or Platform.linux or Platform.osx
  end

end

--return revision, or else you get a blank map on new game
MountPack("ChoGGi_BinAssets", "Packs/BinAssets.hpk")
return tonumber(dofile("ChoGGi_BinAssets/AssetsRevision.lua")) or 0
