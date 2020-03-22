# author: Ethosa
import asyncdispatch
import json
import sdl2
import sdl2/gfx

import view
import ../drawable/canvas


type
  PieChartObj = object of ViewRef
    data*: JsonNode
    canvas*: CanvasRef
  PieChartRef* = ref PieChartObj


proc PieChart*(width, height: cint, x: cint = 0, y: cint = 0,
               parent: SurfacePtr = nil, data = %*{}): PieChartRef =
  ## Creates a new PieChart object
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  viewInitializer(PieChartRef)
  result.data = data
  result.canvas = Canvas(width, height)


method draw*(view: PieChartRef, dst: SurfacePtr) {.async.} =
  if view.is_visible:
    await view.canvas.fill(0)
    var
      sum: int
      i: int16 = 0
    for key in view.data.keys():
      sum += view.data[key].getInt
    for key in view.data.keys():
      let finish = i + view.data[key].getInt.int16
      await view.canvas.filledPie(
        view.width.int16 div 2, view.height.int16 div 2,
        view.width.int16 div 2, (360 / sum * i.float).int16,
        (360 / sum * finish.float).int16,
        0x010203ff'u32 * view.data[key].getInt.uint32
        )
      i += view.data[key].getInt.int16
    view.background.fillRect(nil, 0)
    var surface = await view.canvas.getSurface
    blitSurface(view.saved_background, nil, view.background, nil)
    blitSurface(view.background, nil, dst, view.rect.addr)
    blitSurface(surface, nil, dst, view.rect.addr)
    discard
  await view.on_draw()
