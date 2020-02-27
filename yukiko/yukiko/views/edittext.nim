# author: Ethosa
import strutils
import asyncdispatch
import sdl2
import sdl2/ttf

import view
import textview


type
  EditTextObj = object of TextViewObj
    hint_color*: uint32
    hint*: cstring
  EditTextRef* = ref EditTextObj


proc EditText*(width, height: cint, x: cint = 0, y: cint = 0,
               font: cstring = "sans-serif", font_size: cint = 12,
               parent: SurfacePtr = nil): EditTextRef {.inline.} =
  ## Creates a new EditTextRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(EditTextRef)
  result.font = openFont(font, font_size)
  result.font_name = font
  result.font_size = font_size
  result.style = TTF_STYLE_NORMAL
  result.hint = "Edit text ..."
  result.hint_color = 0x434343

# method setHint*(edittext: EditTextRef, hint: cstring) {.async, base.} =
#   edittext.hint = 

method event*(edittext: EditTextRef, views: seq[ViewRef], event: Event) {.async.} =
  await procCall edittext.ViewRef.event(views, event)
  if edittext.has_focus and event.kind == TextInput:
    let
      e = text event
      text = await edittext.getText()
      res = e.text
    var i = 0
    while res[i] != '\x00':
      inc i
    await edittext.setText($text & join(res[0..i]))
  elif edittext.has_focus and event.kind == KeyDown:
    if event.key.keysym.sym == 13:
      let text = await edittext.getText()
      await edittext.setText($text & "\n")
    elif event.key.keysym.sym == 8:
      let text = await edittext.getText()
      await edittext.setText(($text)[0..^2])
