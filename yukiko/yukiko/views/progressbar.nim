# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/gfx

import view
import ../utils/imageloader


type
  ProgressBarObj = object of ViewRef
    progress: cint
    maximum: cint
    progress_s: SurfacePtr
  ProgressBarRef* = ref ProgressBarObj


proc ProgressBar*(width, height: cint, x: cint = 0, y: cint = 0,
                  parent: SurfacePtr = nil, progress: cint = 0,
                  maximum: cint = 100): ProgressBarRef =
  ## Creates a new ProgressBar object
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  ## -   ``progress`` -- current progress.
  ## -   ``maximum`` -- maximum progress.
  viewInitializer(ProgressBarRef)
  if progress < maximum:
    result.progress = progress
    result.maximum = maximum
  else:
    result.progress = 0
    result.maximum = 100
  result.progress_s = createRGBSurface(
    0, width, height, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  result.progress_s.fillRect(nil, 0x33333377)

method setProgress*(progressbar: ProgressBarRef,
                    progress: cint) {.async, base.} =
  ## Changes the current ProgressBar progress, if available.
  if progress < progressbar.maximum:
    progressbar.progress = progress

method getProgress*(progressbar: ProgressBarRef): Future[cint] {.async, base.} =
  return progressbar.progress

method setMaximum*(progressbar: ProgressBarRef, maximum: cint) {.async, base.} =
  ## Changes the ProgressBar maximum value, if available.
  if maximum > progressbar.progress:
    progressbar.maximum = maximum

method getMaximum*(progressbar: ProgressBarRef): Future[cint] {.async, base.} =
  return progressbar.maximum

method setProgressColor*(progressbar: ProgressBarRef,
                         color: uint32) {.async, base.} =
  ## Changes the progress color.
  progressbar.progress_s.fillRect(nil, color)

method setProgressImage*(progressbar: ProgressBarRef,
                         surface: SurfacePtr) {.async, base.} =
  ## Changes the progress image.
  progressbar.progress_s = surface

method setProgressImageFromFile*(progressbar: ProgressBarRef,
                                 filename: cstring) {.async, base.} =
  ## Changes the progress image.
  var image = await loadImageFromFile(filename)
  if image != nil:
    let
      neww = progressbar.width.cdouble / image.w.cdouble
      newh = progressbar.height.cdouble / image.h.cdouble
    image = zoomSurface(image, neww, newh, 1)
    await progressbar.setProgressImage(image)


method draw*(progressbar: ProgressBarRef, dst: SurfacePtr) {.async.} =
  ## Draws the ProgressBar in the dst surface.
  if progressbar.is_visible:
    let
      progress = progressbar.progress / progressbar.maximum
      width = (progress * progressbar.width.float).cint
    var r = rect(0, 0, width, progressbar.height)
    progressbar.background.fillRect(nil, 0x00000000)
    blitSurface(progressbar.background, nil, dst, progressbar.rect.addr)
    blitSurface(progressbar.progress_s, r.addr, dst, progressbar.rect.addr)
    await progressbar.on_draw()

method draw*(progressbar: ProgressBarRef) {.async, inline.} =
  ## Draws the ProgressBar in the parent surface.
  await progressbar.draw(progressbar.parent)
