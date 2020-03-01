# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/ttf

import view
import ../text/spantext

discard ttfInit()


type
  TextViewObj* = object of ViewObj
    text*: cstring
    font*: FontPtr
    font_name*: cstring
    font_size*: cint
    style*: cint
  TextViewRef* = ref TextViewObj


proc TextView*(width, height: cint, x: cint = 0, y: cint = 0,
               font: cstring = "sans-serif", font_size: cint = 12,
               parent: SurfacePtr = nil): TextViewRef {.inline.} =
  ## Creates a new TextViewRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(TextViewRef)
  result.font = openFont(font, font_size)
  result.font_name = font
  result.font_size = font_size
  result.style = TTF_STYLE_NORMAL


proc parseColor*(clr: int): Future[Color] {.async, inline.} =
  return color((clr shr 16) and 255, (clr shr 8) and 255,
               clr and 255, (clr shr 24) and 255)


method setText*(textview: TextViewRef, text: cstring) {.async, base.} =
  ## Redraws the TextView's text.
  ##
  ## Arguments:
  ## -   ``text`` -- new text.
  textview.text = text
  textview.background.fillRect(nil, 0x00000000)
  blitSurface(textview.saved_background, nil, textview.background, nil)
  var rendered = textview.font.renderUtf8BlendedWrapped(
    text, await parseColor(textview.accent.int), 1024)
  var w, h: cint = 0
  discard sizeUtf8(textview.font, text, w.addr, h.addr)
  var rect = rect(textview.x, textview.y, w, h)
  blitSurface(rendered, nil, textview.background, rect.addr)
  textview.is_changed = true

method setText*(textview: TextViewRef, text: SpanTextObj) {.async, base.} =
  ## Redraws the TextView's text.
  ##
  ## Arguments:
  ## -   ``text`` -- new text.
  textview.text = $text
  textview.background.fillRect(nil, 0x00000000)
  blitSurface(textview.saved_background, nil, textview.background, nil)
  var
    rendered = text.render()
    rect = rect(textview.x, textview.y, rendered.w, rendered.h)
  blitSurface(rendered, nil, textview.background, rect.addr)
  textview.is_changed = true


method setFont*(textview: TextViewRef, font: cstring, size: cint) {.async, base.} =
  ## Changes the font in current textview.
  ##
  ## Arguments:
  ## -   ``font`` -- font path, e.g. "fonts/arial.ttf".
  ## -   ``size`` -- font size.
  textview.font = openFont(font, size)
  await textview.setText(textview.text)


method setFontStyle*(textview: TextViewRef, style: cint) {.async, base.} =
  ## Changes the font style.
  ##
  ## Arguments:
  ## -   ``style`` -- new font style.
  textview.style = style
  textview.font.setFontStyle(style)
  await textview.setText(textview.text)


method setTextSize*(textview: TextViewRef, size: cint) {.async, base.} =
  ## Changes the size for textview's font.
  ##
  ## Arguments:
  ## -   ``size`` -- new size.
  textview.font_size = size
  textview.font = openFont(textview.font_name, size)
  await textview.setText(textview.text)


method setTextColor*(textview: TextViewRef, color: uint32) {.async, base.} =
  ## Changes the color for textview.
  ##
  ## Arguments:
  ## -   ``color`` -- new color.
  textview.accent = color
  await textview.setText(textview.text)


method getText*(textview: TextViewRef): Future[cstring] {.async, base.} =
  return textview.text
