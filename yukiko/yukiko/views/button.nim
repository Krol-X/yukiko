# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/ttf

import ../yukikoEnums
import textview
import view

discard ttfInit()


type
  ButtonObj = object of ViewObj
    button_back: SurfacePtr
    gravity: array[2, Gravity]
    textview: TextViewRef
  ButtonRef* = ref ButtonObj


proc Button*(width, height: cint, x: cint = 0, y: cint = 0,
               font: cstring = "sans-serif", font_size: cint = 12,
               parent: SurfacePtr = nil): ButtonRef {.inline.} =
  ## Creates a new ButtonRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(ButtonRef)
  result.button_back = createRGBSurface(0, width, height, 32, 0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  result.button_back.fillRect(nil, 0xe0e0e0ff.uint32)
  result.gravity = [CENTER, CENTER]
  result.textview = TextView(width, height, x, y, font, font_size, parent)

proc calcBPos(button: ButtonRef) {.async.} =
  if button.gravity[0] == LEFT:
    await button.textview.move(button.x, button.textview.y)
  elif button.gravity[0] == CENTER:
    await button.textview.move(
      (button.width div 2 - button.textview.width div 2) + button.x, button.textview.y)
  elif button.gravity[0] == RIGHT:
    await button.textview.move(button.width - button.textview.width, button.textview.y)

  if button.gravity[1] == TOP:
    await button.textview.move(button.textview.x, button.y)
  elif button.gravity[1] == CENTER:
    var
      h: cint = button.textview.height
      y: cint = button.height div 2 - h div 2
    await button.textview.move(button.textview.x, button.y + y)
    y += button.textview.height
  elif button.gravity[1] == BOTTOM:
    var
      h: cint = button.textview.height
      y: cint = button.height - h
    await button.textview.move(button.textview.x, button.y + y)
    y += button.textview.height

method setText*(button: ButtonRef, text: cstring) {.async, base, inline.} =
  await button.textview.setText(text)
method setFont*(button: ButtonRef, font: cstring, size: cint) {.async, base, inline.} =
  await button.textview.setFont(font, size)
method setFontStyle*(button: ButtonRef, style: cint) {.async, base, inline.} =
  await button.textview.setFontStyle(style)
method setTextSize*(button: ButtonRef, size: cint) {.async, base, inline.} =
  await button.textview.setTextSize(size)
method setTextColor*(button: ButtonRef, color: uint32) {.async, base, inline.} =
  await button.textview.setTextColor(color)
method getText*(button: ButtonRef): Future[cstring] {.async, base, inline.} =
  return await button.textview.getText()

method draw*(button: ButtonRef, dst: SurfacePtr) {.async.} =
  ## Draws button in button.parent.
  if button.is_changed:
    button.is_changed = false
    await button.calcBPos()
  blitSurface(button.saved_background, nil, button.background, nil)
  if button.textview.is_changed:
    button.textview.is_changed = false
    await button.textview.redraw()
    button.is_changed = true
  await button.textview.draw(button.background)
  blitSurface(button.background, nil, dst, button.rect.addr)
  button.on_draw()

method draw*(button: ButtonRef) {.async, inline.} =
  await button.draw(button.parent)
