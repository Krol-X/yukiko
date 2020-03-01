# author: Ethosa
import macros
import asyncdispatch
import sdl2
import sdl2/gfx

import ../utils/imageloader
import ../drawable/canvas


type
  ViewObj* = object of RootObj
    id*: int  ## View id, read-only
    x*, y*: cint  ## View position in parent View or window.
    width*, height*: cint  ## View size.
    background*: SurfacePtr  ## View surface
    saved_background*: SurfacePtr
    background_color*: uint32  ## View surface color.
    foreground*: uint32  ## Foreground color
    accent*: uint32  ## Accent color (e.g. for text)
    parent*: SurfacePtr  ## Parent View (or window)
    rect*: Rect  ## View rect (x, y, width, height)
    in_view*: bool  ## true, when the mouse in view area.
    has_focus*: bool
    is_pressed*: bool
    is_changed*: bool
    is_visible*: bool
    margin*: array[4, cint]
    on_click*: proc(x, y: cint): Future[void]  ## called, when view clicked.
    on_hover*: proc(): Future[void]  ## called, when the mouse enter in view.
    on_out*: proc(): Future[void]  ## called, when the mouse out from view.
    on_focus*: proc(): Future[void]  ## called, when the view gets focus.
    on_unfocus*: proc(): Future[void]  ## called, when the view unfocused.
    on_press*: proc(x, y: cint): Future[void]  ## called, when the view is pressed.
    on_release*: proc(x, y: cint): Future[void]  ## called, when the view not pressed.
    on_draw*: proc(): Future[void]  ## called, when the view is drawn.
  ViewRef* = ref ViewObj


template viewInitializer*(name: untyped): untyped =
  var
    background = createRGBSurface(
      0, width, height, 32,
      0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
    saved_background = createRGBSurface(
      0, width, height, 32,
      0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  background.fillRect(nil, 0xe0e0e0ff.uint32)
  saved_background.fillRect(nil, 0xe0e0e0ff.uint32)
  discard background.setSurfaceBlendMode(BlendMode_Blend)
  discard saved_background.setSurfaceBlendMode(BlendMode_Blend)
  result = `name`(
    width: width, height: height, x: x, y: y,
    background: background, foreground: 0x00000000,
    saved_background: saved_background,
    accent: 0x212121, parent: parent,
    background_color: 0xe0e0e0ff.uint32,
    rect: rect(x, y, width, height), id: 0,
    on_click: proc(x, y: cint) {.async.} = discard,
    on_hover: proc() {.async.} = discard,
    on_out: proc() {.async.} = discard,
    on_focus: proc() {.async.} = discard,
    on_unfocus: proc() {.async.} = discard,
    on_press: proc(x, y: cint) {.async.} = discard,
    on_release: proc(x, y: cint) {.async.} = discard,
    on_draw: proc() {.async.} = discard,
    is_visible: true)


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
      return false
  return true

method redraw*(view: ViewRef) {.async, base.} =
  ## Redraws or recalcs view, when it's changed.
  discard


method draw*(view: ViewRef, dst: SurfacePtr) {.async, base.} =
  ## Draws view in dst surface.
  ##
  ## See also `draw method <#draw.e,ViewRef>`_
  if view.is_visible:
    view.background.fillRect(nil, 0x00000000)
    blitSurface(view.saved_background, nil, view.background, nil)
    blitSurface(view.background, nil, dst, view.rect.addr)
  await view.on_draw()

method draw*(view: ViewRef) {.async, base, inline.} =
  ## Draws view in view.parent.
  ##
  ## See also `draw method <#draw.e,ViewRef,SurfacePtr>`_
  if view.is_visible:
    view.background.fillRect(nil, 0x00000000)
    blitSurface(view.saved_background, nil, view.background, nil)
    blitSurface(view.background, nil, view.parent, view.rect.addr)
  await view.on_draw()

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
    view.in_view = current
    if view.is_pressed:
      view.is_pressed = false
      await view.on_release(e.x, e.y)
    if view.in_view:
      await view.on_hover()
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
  view.saved_background = view.saved_background.zoomSurface(new_width, new_height, 0)
  view.background = view.background.zoomSurface(new_width, new_height, 0)
  view.is_changed = true
  view.width = width
  view.height = height
  view.rect = rect(view.x, view.y, view.width, view.height)

method rotate*(view: ViewRef, angle: cdouble) {.async, base.} =
  ## Rotates the view
  view.saved_background = view.saved_background.rotozoomSurface(angle, 1.0, 1)
  view.background = view.background.rotozoomSurface(angle, 1.0, 1)
  view.is_changed = true
  view.width = view.background.w
  view.height = view.background.h
  view.rect = rect(view.x, view.y, view.width, view.height)

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
  view.background_color = color
  view.background = createRGBSurface(
    0, view.width, view.height, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  view.saved_background = createRGBSurface(
    0, view.width, view.height, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  discard view.background.setSurfaceBlendMode(BlendMode_Blend)
  discard view.saved_background.setSurfaceBlendMode(BlendMode_Blend)
  view.background.fillRect(nil, color)
  view.saved_background.fillRect(nil, color)

method setBackgroundImage*(view: ViewRef, surface: SurfacePtr) {.async, base.} =
  ## Changes the view background
  ##
  ## Arguments:
  ## -   ``surface`` -- new image.
  view.background = surface
  view.saved_background = surface

method setBackgroundImageFromFile*(view: ViewRef, filename: cstring) {.async, base.} =
  ## Changes the view background image to image from a got file, if available.
  ##
  ## Arguments:
  ## -   ``filename`` -- image path.
  var image = await loadImageFromFile(filename)
  if image != nil:
    let
      neww = view.width.cdouble / image.w.cdouble
      newh = view.height.cdouble / image.h.cdouble
    image = zoomSurface(image, neww, newh, 1)
    await view.setBackgroundImage(image)

method setBackground*(view: ViewRef, canvas: CanvasRef) {.async, base.} =
  ## Changes the view's background.
  var surface = await canvas.getSurface()
  let
    neww = view.width.cdouble / surface.w.cdouble
    newh = view.height.cdouble / surface.h.cdouble
  surface = zoomSurface(surface, neww, newh, 1)
  await view.setBackgroundImage(surface)

method setMargin*(view: ViewRef, margin: cint) {.async, base.} =
  ## Changes the view's margin.
  ##
  ## Arguments:
  ## -   ``margin`` -- new margin (for left, top, right and bottom).
  ##
  ## See also `setMargin method <#setMargin.e,cint,cint,cint,cint>`_
  view.margin = [margin, margin, margin, margin]
  view.is_changed = true

method setMargin*(view: ViewRef, left, top, right, bottom: cint) {.async, base.} =
  ## Changes the view's margin.
  ##
  ## Arguments:
  ## -   ``left`` - new left margin.
  ## -   ``top`` - new top margin.
  ## -   ``right`` - new right margin.
  ## -   ``bottom`` - new bottom margin.
  ##
  ## See also `setMargin method <#setMargin.e,cint>`_
  view.margin = [left, top, right, bottom]
  view.is_changed = true

macro `@`*(view: ViewRef, name, stmtlist: untyped): untyped =
  ## This macro provides a convenient way to set view events.
  ##
  ## ..code-block::Nim
  ##   #Without this macro:
  ##   button.on_click = proc(x, y: cint) {.async.} =
  ##     echo x, ", ", y
  ##
  ##   #With this macro:
  ##   button@click:
  ##     echo x, ", ", y
  let
    proc_name: string = $name.toStrLit
    endname = newIdentNode("on_" & proc_name)
    x = newIdentNode("x")
    y = newIdentNode("y")
  case proc_name
  of "hover", "out", "focus", "unfocus", "draw":
    result = quote do:
      `view`.`endname` = proc() {.async.} =
        `stmtlist`
  else:
    result = quote do:
      `view`.`endname` = proc(`x`, `y`: cint) {.async.} =
        `stmtlist`
