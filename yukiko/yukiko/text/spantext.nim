# author: Ethosa
import sdl2
import sdl2/ttf

discard ttfInit()


type
  SpanSymObj* = ref object  ## span symbol.
    symbol*: string  ## unicode character
    foreground*: uint32  ## foreground color
    background*: uint32  ## background color
    style*: cint  ## font style
    font*: FontPtr  ## SDL2_ttf Font pointer
    size*: cint  ## font size.
  SpanTextObj* = seq[SpanSymObj]

var
  defaultFont*: cstring = ""
  defaultFontSize*: cint = 12
  defaultFontPtr*: FontPtr = openFont(defaultFont, defaultFontSize)


proc spansym*(c: char, font: FontPtr): SpanSymObj =
  ## Creates a new SpanSym object.
  ##
  ## ..code-block::Nim
  ##   var spantext = spansym'A'
  return SpanSymObj(
    symbol: $c, foreground: 0x333333.uint32,
    background: 0xeeeeeeff.uint32, style: TTF_STYLE_NORMAL,
    font: font, size: defaultFontSize)

proc spansym*(c: char): SpanSymObj =
  ## Creates a new SpanSym object.
  ##
  ## ..code-block::Nim
  ##   var spantext = spansym'A'
  return SpanSymObj(
    symbol: $c, foreground: 0x333333.uint32,
    background: 0xeeeeeeff.uint32, style: TTF_STYLE_NORMAL,
    font: defaultFontPtr, size: defaultFontSize)

proc span*(text: string): SpanTextObj =
  ## Creates a new SpanText object.
  ##
  ## ..code-block::Nim
  ##   var spantext = span"hello world"
  var font = openFont(defaultFont, defaultFontSize)
  result = @[]
  for c in text:
    result.add spansym(c, font)

proc `$`*(spantext: SpanTextObj): string =
  result = ""
  for s in spantext:
    result &= s.symbol

proc setText*(spantext: var SpanTextObj, text: string) =
  ## Changes text of SpanText
  if text.len > spantext.len:
    var i = 0
    for s in spantext:
      s.symbol = $text[i]
      inc i
    while i < text.len:
      spantext.add spansym(text[i], defaultFontPtr)
      inc i
  else:
    var i = 0
    for s in spantext:
      s.symbol = $text[i]
      inc i
    while i < spantext.len:
      discard spantext.pop

proc setFont*(spantext: SpanTextObj, font_name: cstring, size: cint) =
  ## Changes font of all chars.
  ##
  ## Arguments:
  ## -   ``font_name`` -- new font.
  ## -   ``size`` -- font size.
  var font = openFont(font_name, size)
  for s in spantext:
    s.font.close()
    s.font = font
proc setFont*(sym: SpanSymObj, font_name: cstring, size: cint) =
  ## Changes font of character.
  ##
  ## Arguments:
  ## -   ``font_name`` -- new font.
  ## -   ``size`` -- font size.
  sym.font.close()
  sym.font = openFont(font_name, size)
  sym.size = size

proc setForegroundColor*(spantext: SpanTextObj, color: uint32) =
  ## Changes chars color
  for s in spantext:
    s.foreground = color
proc setForegroundColor*(sym: SpanSymObj, color: uint32) =
  ## Changes character color
  sym.foreground = color

proc setFontStyle*(spantext: SpanTextObj, style: cint) =
  ## Changes font style for all characters.
  for s in spantext:
    s.font.setFontStyle(style)
    s.style = style
proc setFontStyle*(sym: SpanSymObj, style: cint) =
  ## Changes font style for character.
  sym.font.setFontStyle(style)
  sym.style = style

proc setBackgroundColor*(spantext: SpanTextObj, color: uint32) =
  ## Changes background for all chars.
  for s in spantext:
    s.background = color
proc setBackgroundColor*(sym: SpanSymObj, color: uint32) =
  ## Changes background for character.
  sym.background = color

proc parseColor(clr: int): Color =
  return color((clr shr 16) and 255, (clr shr 8) and 255,
               clr and 255, (clr shr 24) and 255)

proc render*(spantext: SpanTextObj, width, height: cint): SurfacePtr =
  var x, y, w, h: cint = 0
  result = createRGBSurface(
    0, width, height, 32,
    0xFF000000.uint32, 0x00FF0000.uint32, 0x0000FF00.uint32, 0x000000FF.uint32)
  result.fillRect(nil, 0)
  for s in spantext:
    discard sizeUtf8(s.font, s.symbol, w.addr, h.addr)
    if s.symbol == "\n":
      x = 0
      y += h-1
      continue
    var
      background = createRGBSurface(
        0, w, h, 32,
        0xFF000000.uint32, 0x00FF0000.uint32, 0x0000FF00.uint32, 0x000000FF.uint32)
      rendered = renderUtf8Blended(
        s.font, s.symbol.cstring, parseColor(s.foreground.int))
      r = rect(x, y, w, h)
    background.fillRect(nil, s.background)
    background.blitSurface(nil, result, r.addr)
    rendered.blitSurface(nil, result, r.addr)
    x += w
