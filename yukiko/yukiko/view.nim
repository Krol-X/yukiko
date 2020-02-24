# author: Ethosa
import macros
import asyncdispatch
import sdl2


type
  ViewObj = object
    x, y: cint  ## View position in parent View or window.
    width, height: cint  ## View size.
    background: SurfacePtr  ## View surface
    background_color: uint32  ## View surface color.
    foreground: uint32  ## Foreground color
    accent: uint32  ## Accent color (e.g. for text)
    parent: SurfacePtr  ## Parent View (or window)
    rect: Rect  ## View rect (x, y, width, height)
    id*: int  ## View id, read-only
    on_click*: proc(x, y: cint)  ## called, when view clicked.
  ViewRef* = ref ViewObj


proc View*(width, height: cint, x: cint = 0, y: cint = 0,
           parent: SurfacePtr = nil): ViewRef =
  ## Creates a new ViewRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``parent`` -- parent view.
  var background = createRGBSurface(0, width, height, 32, 0, 0, 0, 0)
  background.fillRect(nil, 0xe0e0e0)
  ViewRef(
    width: width, height: height, x: x, y: y,
    background: background, foreground: 0x00000000,
    accent: 0x212121, parent: parent,
    background_color: 0xe0e0e0,
    rect: rect(x, y, width, height), id: 0,
    on_click: proc(x, y: cint) = discard)


proc is_current(view: ViewRef, p: Point, views: seq[ViewRef]): Future[bool] {.async.} =
  for i in view.id+1 ..< views.len:
    if views[i].rect.contains(p):
      result = false
  result = true


proc draw*(view: ViewRef) {.async.} =
  blitSurface(view.background, nil, view.parent, view.rect.addr)
proc draw*(view: ViewRef, dst: SurfacePtr) {.async.} =
  blitSurface(view.background, nil, dst, view.rect.addr)

proc event*(view: ViewRef, views: seq[ViewRef], event: Event) {.async.} =
  if event.kind == MouseButtonDown:
    let
      e = button event
      p = point[cint](e.x, e.y)
      current = await view.is_current(p, views)
    if view.rect.contains(p) and current:
      view.on_click(e.x, e.y)

proc move*(view: ViewRef, x, y: cint) {.async.} =
  ## Changes view position.
  view.x = x
  view.y = y
  view.rect = rect(view.x, view.y, view.width, view.height)

proc getBackgroundColor*(view: ViewRef): Future[uint32] {.async.} =
  return view.background_color

proc setBackgroundColor*(view: ViewRef, color: uint32) {.async.} =
  ## Changes View's background color
  var background = createRGBSurface(0, view.width, view.height, 32, 0, 0, 0, 0)
  background.fillRect(nil, color)
  view.background = background

macro eventhandler*(view: ViewRef, prc: untyped): untyped =
  ## Adds a new proc in the event handler.
  if prc.kind == nnkProcDef:
    let proc_ident = newIdentNode $prc[0].toStrLit
    result = quote do:
      `prc`
      `view`.`proc_ident` = `proc_ident`
