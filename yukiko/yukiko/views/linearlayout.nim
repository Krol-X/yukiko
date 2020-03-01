# author: Ethosa
import asyncdispatch
import sdl2

import ../yukikoEnums
import view


type
  LinearLayoutObj* = object of ViewObj
    gravity*: array[2, Gravity]
    orientation*: Orientation
    views*: seq[ViewRef]
  LinearLayoutRef* = ref LinearLayoutObj


proc LinearLayout*(width, height: cint, x: cint = 0, y: cint = 0,
           parent: SurfacePtr = nil): LinearLayoutRef {.inline.} =
  ## Creates a new LinearLayoutRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(LinearLayoutRef)
  result.gravity = [LEFT, TOP]
  result.orientation = VERTICAL


proc calcPosV(layout: LinearLayoutRef) {.async.} =
  ## Calcs views positions (only for VERTICAL orientation.)
  if layout.gravity[0] == LEFT:
    for view in layout.views:
      await view.move(view.margin[0], view.y)
  elif layout.gravity[0] == CENTER:
    for view in layout.views:
      await view.move(
        (layout.width div 2 - view.width div 2), view.y)
  elif layout.gravity[0] == RIGHT:
    for view in layout.views:
      await view.move(layout.width - view.width - view.margin[2], view.y)

  var h: cint = 0
  if layout.gravity[1] == TOP:
    var y: cint = 0
    for view in layout.views:
      await view.move(view.x, y + view.margin[1])
      y += view.height + view.margin[1] + view.margin[3]
  elif layout.gravity[1] == CENTER:
    for view in layout.views:
      h += view.height
    var y: cint = layout.height div 2 - h div 2
    for view in layout.views:
      await view.move(view.x, y + view.margin[1])
      y += view.height + view.margin[1] + view.margin[3]
  elif layout.gravity[1] == BOTTOM:
    for view in layout.views:
      h += view.height + view.margin[1] + view.margin[3]
    var y: cint = layout.height - h
    for view in layout.views:
      await view.move(view.x, y + view.margin[1])
      y += view.height + view.margin[1] + view.margin[3]

proc calcPosH(layout: LinearLayoutRef) {.async.} =
  ## Calcs views positions (only for HORIZONTAL orientation.)
  var w: cint = 0
  if layout.gravity[0] == LEFT:
    var x: cint = 0
    for view in layout.views:
      await view.move(x + view.margin[0], view.y)
      x += view.width + view.margin[0] + view.margin[2]
  elif layout.gravity[0] == CENTER:
    for view in layout.views:
      w += view.width + view.margin[0] + view.margin[2]
    var x: cint = layout.width div 2 - w div 2
    for view in layout.views:
      await view.move(x + view.margin[0], view.y)
      x += view.width + view.margin[0] + view.margin[2]
  elif layout.gravity[0] == RIGHT:
    for view in layout.views:
      w += view.width + view.margin[0] + view.margin[2]
    var x: cint = layout.width - w
    for view in layout.views:
      await view.move(x + view.margin[0], view.y)
      x += view.width + view.margin[0] + view.margin[2]

  if layout.gravity[1] == TOP:
    for view in layout.views:
      await view.move(view.x, view.margin[1])
  elif layout.gravity[1] == CENTER:
    for view in layout.views:
      await view.move(view.x, (layout.height div 2 - view.height div 2))
  elif layout.gravity[1] == BOTTOM:
    for view in layout.views:
      await view.move(view.x, layout.height - view.height - view.margin[1])

proc recalc(layout: LinearLayoutRef) {.async, inline.} =
  if layout.orientation == VERTICAL:
    await layout.calcPosV()
  else:
    await layout.calcPosH()


proc setGravityX*(layout: LinearLayoutRef, g: Gravity) {.async.} =
  ## Changes layout gravity at X coord.
  layout.gravity[0] = g
  await layout.recalc()

proc setGravityY*(layout: LinearLayoutRef, g: Gravity) {.async.} =
  ## Changes layout gravity at Y coord.
  layout.gravity[1] = g
  await layout.recalc()

proc setOrientation*(layout: LinearLayoutRef, o: Orientation) {.async.} =
  ## Changes layout orientation.
  ## ``o`` can be `VERTICAL` or `HORIZONTAL`.
  layout.orientation = o
  await layout.recalc()

method addView*(layout: LinearLayoutRef, view: ViewRef) {.async, base.} =
  ## Adds view in layout
  layout.views.add view
  await layout.recalc()

method draw*(layout: LinearLayoutRef, dst: SurfacePtr) {.async.} =
  ## Draws layout in layout.parent.
  if layout.is_visible:
    if layout.is_changed:
      layout.is_changed = false
      await layout.recalc()
    layout.background.fillRect(nil, 0x00000000)
    blitSurface(layout.saved_background, nil, layout.background, nil)
    for view in layout.views:
      if view.is_changed:
        view.is_changed = false
        await view.redraw()
        layout.is_changed = true
      await view.draw(layout.background)
    blitSurface(layout.background, nil, dst, layout.rect.addr)
    await layout.on_draw()

method draw*(layout: LinearLayoutRef) {.async, inline.} =
  ## Draws layout in layout.parent.
  await layout.draw(layout.parent)

method event*(layout: LinearLayoutRef, views: seq[ViewRef], event: Event) {.async.} =
  ## Handles user input.
  await procCall layout.ViewRef.event(views, event)
  for view in layout.views:
    await view.event(views, event)
