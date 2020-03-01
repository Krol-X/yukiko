# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/gfx


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
