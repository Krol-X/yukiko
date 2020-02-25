# author: Ethosa
import macros
import asyncdispatch
import sdl2


type
  ViewObj* = object of RootObj
    x*, y*: cint  ## View position in parent View or window.
    width*, height*: cint  ## View size.
    background*: SurfacePtr  ## View surface
    background_color*: uint32  ## View surface color.
    foreground*: uint32  ## Foreground color
    accent*: uint32  ## Accent color (e.g. for text)
    parent*: SurfacePtr  ## Parent View (or window)
    rect*: Rect  ## View rect (x, y, width, height)
    id*: int  ## View id, read-only
    in_view*: bool
    has_focus*: bool
    is_pressed*: bool
    on_click*: proc(x, y: cint)  ## called, when view clicked.
    on_hover*: proc()  ## called, when the mouse enter in view.
    on_out*: proc()  ## called, when the mouse out from view.
    on_focus*: proc()  ## called, when the view gets focus.
    on_unfocus*: proc()  ## called, when the view unfocused.
    on_press*: proc(x, y: cint)  ## called, when the view is pressed.
    on_release*: proc(x, y: cint)  ## called, when the view not pressed.
  ViewRef* = ref ViewObj


template viewInitializer*(name: untyped): untyped =
  var background = createRGBSurface(0, width, height, 32, 0, 0, 0, 0)
  background.fillRect(nil, 0xe0e0e0)
  `name`(
    width: width, height: height, x: x, y: y,
    background: background, foreground: 0x00000000,
    accent: 0x212121, parent: parent,
    background_color: 0xe0e0e0,
    rect: rect(x, y, width, height), id: 0,
    on_click: proc(x, y: cint) = discard,
    on_hover: proc() = discard, on_out: proc() = discard,
    on_focus: proc() = discard, on_unfocus: proc() = discard,
    on_press: proc(x, y: cint) = discard,
    on_release: proc(x, y: cint) = discard)


proc View*(width, height: cint, x: cint = 0, y: cint = 0,
           parent: SurfacePtr = nil): ViewRef =
  ## Creates a new ViewRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(ViewRef)


proc is_current(view: ViewRef, p: Point, views: seq[ViewRef]): Future[bool] {.async.} =
  for i in view.id+1 ..< views.len:
    if views[i].rect.contains(p):
      result = false
  result = true


method draw*(view: ViewRef) {.async, base.} =
  ## Draws view in view.parent.
  ##
  ## See also `draw proc <#draw,ViewRef,SurfacePtr>`_
  blitSurface(view.background, nil, view.parent, view.rect.addr)

method draw*(view: ViewRef, dst: SurfacePtr) {.async, base.} =
  ## Draws view in dst surface.
  ##
  ## See also `draw proc <#draw,ViewRef>`_
  blitSurface(view.background, nil, dst, view.rect.addr)

method event*(view: ViewRef, views: seq[ViewRef], event: Event) {.async, base.} =
  ## Handles events for this view.
  ##
  ## Arguments:
  ## -   ``views`` -- views sequence.
  ## -   ``event`` -- event obj.
  if event.kind == MouseButtonDown:
    let
      e = button event
      p = point[cint](e.x, e.y)
      current = await view.is_current(p, views)
    if view.rect.contains(p) and current:
      view.on_click(e.x, e.y)
      if not view.has_focus:
        view.has_focus = true
        view.on_focus()
      view.is_pressed = true
      view.on_press(e.x, e.y)
    elif view.has_focus:
      view.has_focus = false
      view.on_unfocus()
  elif event.kind == MouseButtonUp:
    let e = button event
    if view.is_pressed:
      view.is_pressed = false
      view.on_release(e.x, e.y)
  elif event.kind == MouseMotion:
    let
      e = motion event
      p = point[cint](e.x, e.y)
      current = await view.is_current(p, views)
    if view.rect.contains(p) and current:
      if not view.in_view:
        view.on_hover()
        view.in_view = true
      if view.is_pressed:
        view.on_press(e.x, e.y)
    elif view.in_view:
        view.on_out()
        view.in_view = false


proc move*(view: ViewRef, x, y: cint) {.async.} =
  ## Changes view position.
  ##
  ## Arguments:
  ## -   ``x`` -- new X position.
  ## -   ``y`` -- new Y position.
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
