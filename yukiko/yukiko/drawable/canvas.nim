# author: Ethosa
import asyncdispatch
import math

import sdl2
import sdl2/gfx
import sdl2/image


type
  CanvasRef* = ref object
    content: SurfacePtr
    renderer: RendererPtr
    width, height: cint


proc Canvas*(width, height: cint): CanvasRef =
  var surface = createRGBSurface(
    0, width, height, 32, 0xFF000000.uint32,
    0x00FF0000, 0x0000FF00, 0x000000FF)
  surface.fillRect(nil, 0x00000000)
  result = CanvasRef(content: surface,
    renderer: createSoftwareRenderer(surface),
    width: width, height: height)

proc rgba2abgr(color: uint32): uint32 =
  let
    r = color shr 24 and 255
    g = color shr 16 and 255
    b = color shr 8 and 255
    a = color and 255
  result = (r) or (g shl 8) or (b shl 16) or (a shl 24)

proc setAt*(canvas: CanvasRef, x, y: int16, color: uint32) {.async, inline.} =
  canvas.renderer.pixelColor(x, y, rgba2abgr color)

proc hline*(canvas: CanvasRef, x1, x2, y: int16, color: uint32) {.async, inline.} =
  canvas.renderer.hlineColor(x1, x2, y, rgba2abgr color)

proc vline*(canvas: CanvasRef, x, y1, y2: int16, color: uint32) {.async, inline.} =
  canvas.renderer.hlineColor(x, y1, y2, rgba2abgr color)

proc rect*(canvas: CanvasRef, x1, y1, x2, y2: int16, color: uint32) {.async, inline.} =
  canvas.renderer.rectangleColor(x1, y1, x2, y2, rgba2abgr color)

proc roundRect*(canvas: CanvasRef, x1, y1, x2, y2, radius: int16,
                color: uint32) {.async, inline.} =
  canvas.renderer.roundedRectangleColor(x1, y1, x2, y2, radius, rgba2abgr color)

proc box*(canvas: CanvasRef, x1, y1, x2, y2: int16, color: uint32) {.async, inline.} =
  canvas.renderer.boxColor(x1, y1, x2, y2, rgba2abgr color)

proc roundBox*(canvas: CanvasRef, x1, y1, x2, y2, radius: int16,
                color: uint32) {.async, inline.} =
  canvas.renderer.roundedBoxColor(x1, y1, x2, y2, radius, rgba2abgr color)

proc line*(canvas: CanvasRef, x1, y1, x2, y2: int16, color: uint32) {.async, inline.} =
  canvas.renderer.lineColor(x1, y1, x2, y2, rgba2abgr color)

proc aaline*(canvas: CanvasRef, x1, y1, x2, y2: int16, color: uint32) {.async, inline.} =
  canvas.renderer.aalineColor(x1, y1, x2, y2, rgba2abgr color)

proc thick*(canvas: CanvasRef, x1, y1, x2, y2: int16,
            width: uint8, color: uint32) {.async, inline.} =
  canvas.renderer.thickLineColor(x1, y1, x2, y2, width, rgba2abgr color)

proc circle*(canvas: CanvasRef, x, y, radius: int16, color: uint32) {.async, inline.} =
  canvas.renderer.circleColor(x, y, radius, rgba2abgr color)

proc arc*(canvas: CanvasRef, x, y, rad, start, finish: int16,
          color: uint32) {.async, inline.} =
  canvas.renderer.arcColor(x, y, rad, start, finish, rgba2abgr color)

proc aacircle*(canvas: CanvasRef, x, y, rad: int16,
               color: uint32) {.async, inline.} =
  canvas.renderer.aacircleColor(x, y, rad, rgba2abgr color)

proc filledCircle*(canvas: CanvasRef, x, y, rad: int16,
                   color: uint32) {.async, inline.} =
  canvas.renderer.filledCircleColor(x, y, rad, rgba2abgr color)

proc ellipse*(canvas: CanvasRef, x, y, xr, yr: int16,
              color: uint32) {.async, inline.} =
  canvas.renderer.ellipseColor(x, y, xr, yr, rgba2abgr color)

proc aaellipse*(canvas: CanvasRef, x, y, xr, yr: int16,
              color: uint32) {.async, inline.} =
  canvas.renderer.aaellipseColor(x, y, xr, yr, rgba2abgr color)

proc filledellipse*(canvas: CanvasRef, x, y, xr, yr: int16,
              color: uint32) {.async, inline.} =
  canvas.renderer.filledEllipseColor(x, y, xr, yr, rgba2abgr color)

proc pie*(canvas: CanvasRef, x, y, rad, start, finish: int16;
          color: uint32) {.async, inline.} =
  canvas.renderer.pieColor(x, y, rad, start, finish, rgba2abgr color)

proc filledPie*(canvas: CanvasRef, x, y, rad, start, finish: int16;
                color: uint32) {.async, inline.} =
  canvas.renderer.filledPieColor(x, y, rad, start, finish, rgba2abgr color)

proc trigon*(canvas: CanvasRef, x1, y1, x2, y2, x3, y3: int16;
             color: uint32) {.async, inline.} =
  canvas.renderer.trigonColor(x1, y1, x2, y2, x3, y3, rgba2abgr color)

proc aatrigon*(canvas: CanvasRef, x1, y1, x2, y2, x3, y3: int16;
               color: uint32) {.async, inline.} =
  canvas.renderer.aatrigonColor(x1, y1, x2, y2, x3, y3, rgba2abgr color)

proc filledTrigon*(canvas: CanvasRef, x1, y1, x2, y2, x3, y3: int16;
                   color: uint32) {.async, inline.} =
  canvas.renderer.filledTrigonColor(x1, y1, x2, y2, x3, y3, rgba2abgr color)

proc getSurface*(canvas: CanvasRef): Future[SurfacePtr] {.async.} =
  return canvas.content

proc saveToFile*(canvas: CanvasRef, filename: cstring) {.async.} =
  discard savePNG(canvas.content, filename)

# End of binding.


proc distance(x1, y1, x2, y2: int16): float {.inline.} =
  let a: int = (x2 - x1).int * (x2 - x1).int
  let b: int = (y2 - y1).int * (y2 - y1).int
  return math.sqrt((a + b).float)

proc lineardistance(x, y: int16, pos1, pos2, pos3, dist: float): float {.inline.} =
  return (pos1*x.float + pos2*y.float + pos3) * dist

proc normalize(value, minimum, maximum: float): float {.inline.} =
  if value <= minimum:
    return 0.0
  elif value >= maximum:
    return 1.0
  else:
    return value / maximum

proc normalizeColor(color: float): float {.inline.} =
  if color <= 0.0:
    return 0.0
  elif color >= 255.0:
    return 255.0
  else:
    return color

proc lerpColor(one, two: uint32, lerpv: float): uint32 {.inline.} =
  let
    a1 = one shr 24 and 255
    b1 = one shr 16 and 255
    g1 = one shr 8 and 255
    r1 = one and 255

    a2 = two shr 24 and 255
    b2 = two shr 16 and 255
    g2 = two shr 8 and 255
    r2 = two and 255

    p: float = 1.0 - lerpv

    r = normalizeColor(r1.float * p + r2.float * lerpv).uint32
    g = normalizeColor(g1.float * p + g2.float * lerpv).uint32
    b = normalizeColor(b1.float * p + b2.float * lerpv).uint32
    a = normalizeColor(a1.float * p + a2.float * lerpv).uint32
  result = (r) or (g shl 8) or (b shl 16) or (a shl 24)

proc radialgradient*(canvas: CanvasRef, cx, cy, radius: int16, color1, color2: uint32) {.async.} =
  ## Draws the radial gradient on the canvas.
  let
    clr1 = rgba2abgr color1
    clr2 = rgba2abgr color2
  for y in 0..<canvas.content.h:
    for x in 0..<canvas.content.w:
      let
        xt = x.int16
        yt = y.int16
        dist = distance(cx, cy, xt, yt)
        norm = normalize(dist, 0.0, radius.float)
        color = lerpColor(clr1, clr2, norm)
      canvas.renderer.pixelColor(xt, yt, color)

proc hrgradient*(canvas: CanvasRef, xpos: int16, color1, color2: uint32) {.async.} =
  ## Draws the horizontal reflected gradient on the canvas.
  let
    clr1 = rgba2abgr color1
    clr2 = rgba2abgr color2
  for y in 0..<canvas.content.h:
    for x in 0..<canvas.content.w:
      let
        xt = x.int16
        yt = y.int16
        dist = distance(xpos, yt, xt, yt)
        norm = normalize(dist, 0.0, canvas.content.w.float)
        color = lerpColor(clr1, clr2, norm)
      canvas.renderer.pixelColor(xt, yt, color)

proc hgradient*(canvas: CanvasRef, color1, color2: uint32) {.async, inline.} =
  ## Draws the horizontal gradient on the canvas.
  await canvas.hrgradient(canvas.content.w.int16, color1, color2)

proc vrgradient*(canvas: CanvasRef, ypos: int16, color1, color2: uint32) {.async.} =
  ## Draws the vertical reflected gradient on the canvas.
  let
    clr1 = rgba2abgr color1
    clr2 = rgba2abgr color2
  for y in 0..<canvas.content.h:
    for x in 0..<canvas.content.w:
      let
        xt = x.int16
        yt = y.int16
        dist = distance(xt, ypos, xt, yt)
        norm = normalize(dist, 0.0, canvas.content.h.float)
        color = lerpColor(clr1, clr2, norm)
      canvas.renderer.pixelColor(xt, yt, color)

proc vgradient*(canvas: CanvasRef, color1, color2: uint32) {.async, inline.} =
  ## Draws the vertical gradient on the canvas.
  await canvas.vrgradient(canvas.content.h.int16, color1, color2)

proc lineargradient*(canvas: CanvasRef, x1, y1, x2, y2: int,
                     color1, color2: uint32) {.async.} =
  ## Draws the linear gradient on the canvas.
  let
    clr1 = rgba2abgr color1
    clr2 = rgba2abgr color2
    pos1: float = (y2 - y1).float
    pos2: float = (x2 - x1).float
    pos3: float = (x2*y1 - y2*x1).float
    dist: float = 1.0 / math.sqrt(pos1*pos1 + pos2*pos2)
    ul = lineardistance(0.int16, 0.int16, pos1, pos2, pos3, dist)
    ur = lineardistance((canvas.content.w-1).int16, 0.int16, pos1, pos2, pos3, dist)
  for y in 0..<canvas.content.h:
    for x in 0..<canvas.content.w:
      let
        d = lineardistance(x.int16, y.int16, pos1, pos2, pos3, dist)
        ratio = 0.5 + 0.5 * d / canvas.content.w.float
        norm =
          if ul > ur:
            normalize(1.0 - ratio, 0.0, 1.0)
          else:
            normalize(ratio, 0.0, 1.0)
        newcolor = lerpColor(clr1, clr2, norm)
      canvas.renderer.pixelColor(x.int16, y.int16, newcolor)

proc fill*(canvas: CanvasRef, color: uint32) {.async, inline.} =
  await canvas.rect(0, 0, canvas.width.int16, canvas.height.int16, rgba2abgr color)
