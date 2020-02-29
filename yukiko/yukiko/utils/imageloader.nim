# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/image


proc loadImageFromFile*(filename: cstring): Future[SurfacePtr] {.async.} =
  var rw = rwFromFile(filename, "r")
  let
    ICO = isICO(rw).bool
    CUR = isCUR(rw).bool
    BMP = isBMP(rw).bool
    GIF = isGIF(rw).bool
    JPG = isJPG(rw).bool
    LBM = isLBM(rw).bool
    PCX = isPCX(rw).bool
    PNG = isPNG(rw).bool
    PNM = isPNM(rw).bool
    TIF = isTIF(rw).bool
    XCF = isXCF(rw).bool
    XPM = isXPM(rw).bool
    XV = isXV(rw).bool
    WEBP = isWEBP(rw).bool
  if ICO:
    return loadICO_RW(rw)
  elif CUR:
    return loadCUR_RW(rw)
  elif BMP:
    return loadBMP_RW(rw)
  elif GIF:
    return loadGIF_RW(rw)
  elif JPG:
    return loadJPG_RW(rw)
  elif LBM:
    return loadLBM_RW(rw)
  elif PCX:
    return loadPCX_RW(rw)
  elif PNG:
    return loadPNG_RW(rw)
  elif PNM:
    return loadPNM_RW(rw)
  elif TIF:
    return loadTIF_RW(rw)
  elif XCF:
    return loadXCF_RW(rw)
  elif XPM:
    return loadXPM_RW(rw)
  elif XV:
    return loadXV_RW(rw)
  elif WEBP:
    return loadWEBP_RW(rw)
