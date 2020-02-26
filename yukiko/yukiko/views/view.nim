# author: Ethosa
import macros
import asyncdispatch
import sdl2
import sdl2/gfx


type
  ViewObj* = object of RootObj
    x*, y*: cint  ## View position in parent View or window.
    width*, height*: cint  ## View size.
    background*: SurfacePtr  ## View surface
    saved_background*: SurfacePtr
    background_color*: uint32  ## View surface color.
    foreground*: uint32  ## Foreground color
    accent*: uint32  ## Accent color (e.g. for text)
    parent*: SurfacePtr  ## Parent View (or window)
    rect*: Rect  ## View rect (x, y, width, height)
    id*: int  ## View id, read-only
    in_view*: bool
    has_focus*: bool
    is_pressed*: bool
    is_changed*: bool
    on_click*: proc(x, y: cint): Future[void]  ## called, when view clicked.
    on_hover*: proc(): Future[void]  ## called, when the mouse enter in view.
    on_out*: proc(): Future[void]  ## called, when the mouse out from view.
    on_focus*: proc(): Future[void]  ## called, when the view gets focus.
    on_unfocus*: proc(): Future[void]  ## called, when the view unfocused.
    on_press*: proc(x, y: cint): Future[void]  ## called, when the view is pressed.
    on_release*: proc(x, y: cint): Future[void]  ## called, when the view not pressed.
  ViewRef* = ref ViewObj


template viewInitializer*(name: untyped): untyped =
  var background = createRGBSurface(0, width, height, 32, 0, 0, 0, 0)
  var background1 = createRGBSurface(0, width, height, 32, 0, 0, 0, 0)
  background.fillRect(nil, 0xe0e0e0)
  background1.fillRect(nil, 0xe0e0e0)
  result = `name`(
    width: width, height: height, x: x, y: y,
    background: background, foreground: 0x00000000,
    saved_background: background1,
    accent: 0x212121, parent: parent,
    background_color: 0xe0e0e0,
    rect: rect(x, y, width, height), id: 0,
    on_click: proc(x, y: cint) {.async.} = discard,
    on_hover: proc() {.async.} = discard,
    on_out: proc() {.async.} = discard,
    on_focus: proc() {.async.} = discard,
    on_unfocus: proc() {.async.} = discard,
    on_press: proc(x, y: cint) {.async.} = discard,
    on_release: proc(x, y: cint) {.async.} = discard)


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

method redraw*(view: ViewRef) {.async, base.} =
  ## Redraws or recalcs view, when it's changed.
  discard


method draw*(view: ViewRef, dst: SurfacePtr) {.async, base.} =
  ## Draws view in dst surface.
  ##
  ## See also `draw proc <#draw,ViewRef>`_
  blitSurface(view.background, nil, dst, view.rect.addr)

method draw*(view: ViewRef) {.async, base, inline.} =
  ## Draws view in view.parent.
  ##
  ## See also `draw proc <#draw,ViewRef,SurfacePtr>`_
  blitSurface(view.background, nil, view.parent, view.rect.addr)

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
      await view.on_click(e.x, e.y)
      if not view.has_focus:
        view.has_focus = true
        await view.on_focus()
      view.is_pressed = true
      await view.on_press(e.x, e.y)
    elif view.has_focus:
      view.has_focus = false
      await view.on_unfocus()
  elif event.kind == MouseButtonUp:
    let
      e = button event
      p = point[cint](e.x, e.y)
      current = await view.is_current(p, views)
    if current:
      view.in_view = false
    if view.is_pressed:
      view.is_pressed = false
      await view.on_release(e.x, e.y)
  elif event.kind == MouseMotion:
    let
      e = motion event
      p = point[cint](e.x, e.y)
      current = await view.is_current(p, views)
    if view.rect.contains(p) and current:
      if not view.in_view:
        await view.on_hover()
        view.in_view = true
      if view.is_pressed:
        await view.on_press(e.x, e.y)
    elif view.in_view:
      if not view.is_pressed:
        await view.on_out()
        view.in_view = false

method resize*(view: ViewRef, width, height: cint) {.async, base.} =
  ## Resizes the view.
  ##
  ## Arguments:
  ## -   ``width`` -- new width.
  ## -   ``height`` -- new height.
  var
    new_width: cdouble = width.cdouble / view.width.cdouble
    new_height: cdouble = height.cdouble / view.height.cdouble
  view.background = view.background.zoomSurface(new_width, new_height, 0)
  view.is_changed = true
  view.width = width
  view.height = height

method move*(view: ViewRef, x, y: cint) {.async, base.} =
  ## Changes view position.
  ##
  ## Arguments:
  ## -   ``x`` -- new X position.
  ## -   ``y`` -- new Y position.
  view.x = x
  view.y = y
  view.rect = rect(view.x, view.y, view.width, view.height)

method getBackgroundColor*(view: ViewRef): Future[uint32] {.async, base.} =
  ## Gets view background color.
  return view.background_color

method setBackgroundColor*(view: ViewRef, color: uint32) {.async, base.} =
  ## Changes View's background color
  view.background = createRGBSurface(0, view.width, view.height, 32, 0, 0, 0, 0)
  view.background.fillRect(nil, color)
  view.background_color = color
  blitSurface(view.background, nil, view.saved_background, nil)

macro eventhandler*(view: ViewRef, prc: untyped): untyped =
  ## Adds a new proc in the event handler.
  if prc.kind == nnkProcDef:
    let proc_ident = newIdentNode $prc[0].toStrLit
    result = quote do:
      `prc`
      `view`.`proc_ident` = `proc_ident`

macro `@`*(view: ViewRef, name, stmtlist: untyped): untyped =
  ## This macro provides a convenient way to use eventhandler pragma.
  ##
  ## ..code-block::Nim
  ##   # Without this macro:
  ##   proc on_click(x, y: cint) {.async, eventhandler: button.} =
  ##     echo x, ", ", y
  ##
  ##   # With this macro:
  ##   button@click:
  ##     echo x, ", ", y
  let
    proc_name: string = $name.toStrLit
    endname = newIdentNode("on_" & proc_name)
    x = newIdentNode("x")
    y = newIdentNode("y")
  case proc_name
  of "hover", "out", "focus", "unfocus":
    result = quote do:
      proc `endname`() {.async, eventhandler: `view`.} =
        `stmtlist`
  else:
    result = quote do:
      proc `endname`(`x`, `y`: cint) {.async, eventhandler: `view`.} =
        `stmtlist`
