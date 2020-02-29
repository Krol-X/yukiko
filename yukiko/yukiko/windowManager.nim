import asyncdispatch
import sdl2
import sdl2/image

import views/view
export view


discard sdl2.init(INIT_EVERYTHING)


type
  WindowManager* = ref object
    event: Event
    is_run: bool
    window: WindowPtr
    render: RendererPtr
    background_color: uint32
    views*: seq[ViewRef]


proc Window*(name: cstring, width: cint = 720, height: cint = 480): WindowManager =
  ## Creates a new window manager object.
  ##
  ## Arguments:
  ## -   ``name`` -- window name.
  ## -   ``width`` -- window width.
  ## -   ``height`` -- window height.
  var window = sdl2.createWindow(
    name, 100, 100, width, height, SDL_WINDOW_SHOWN)
  var render = sdl2.createRenderer(
    window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
  WindowManager(window: window, render: render,
    is_run: true, event: sdl2.defaultEvent,
    background_color: 0x000000, views: @[])


proc addView*(wm: WindowManager, views: varargs[ViewRef]) {.inline.} =
  ## Adds a new view(s) in window for render.
  for view in views:
    view.parent = wm.window.getSurface
    view.id = wm.views.len
    wm.views.add view


proc setBackgroundColor*(wm: WindowManager, color: uint32) {.async.} =
  ## Changes window background color.
  wm.background_color = color

proc setIcon*(wm: WindowManager, image_path: cstring) {.async.} =
  ## Changes window icon.
  var
    rw = rwFromFile(image_path, "r")
    image: SurfacePtr
  let
    png = isPNG(rw).bool
    jpg = isJPG(rw).bool
    bmp = isBMP(rw).bool
    ico = isICO(rw).bool
    webp = isWEBP(rw).bool
    gif = isGIF(rw).bool
    tif = isTIF(rw).bool
  if png:
    image = loadPNG_RW(rw)
  elif jpg:
    image = loadJPG_RW(rw)
  elif bmp:
    image = loadBMP_RW(rw)
  elif ico:
    image = loadICO_RW(rw)
  elif webp:
    image = loadWEBP_RW(rw)
  elif gif:
    image = loadGIF_RW(rw)
  elif tif:
    image = loadTIF_RW(rw)
  else:
    return
  wm.window.setIcon(image)

proc setTitle*(wm: WindowManager, title: cstring) {.async.} =
  wm.window.setTitle(title)


proc handleEvent(wm: WindowManager) {.async.} =
  ## Handles all window events.
  while pollEvent(wm.event):
    if wm.event.kind == QuitEvent:
      wm.is_run = false
      break
    for view in wm.views:
      await view.event(wm.views, wm.event)


proc draw(wm: WindowManager) {.async.} =
  wm.window.getSurface.fillRect(nil, wm.background_color)
  for view in wm.views:
    await view.draw wm.window.getSurface


proc startLoop*(wm: WindowManager) {.async.} =
  ## Starts loop and event handler.
  while wm.is_run:
    await wm.handleEvent()
    await wm.draw()
    discard wm.window.updateSurface()
  sdl2.destroy(wm.render)
  sdl2.destroy(wm.window)
