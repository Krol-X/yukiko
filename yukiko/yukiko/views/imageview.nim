# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/gfx

import view
import ../yukikoEnums
import ../utils/imageloader


type
  ImageViewObj = object of ViewObj
    content: SurfacePtr  ## Loaded image.
  ImageViewRef* = ref ImageViewObj

proc ImageView*(width, height: cint, x: cint = 0, y: cint = 0,
                parent: SurfacePtr = nil): ImageViewRef =
  ## Creates a new ImageView object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(ImageViewRef)
  result.content = createRGBSurface(
    0, width, height, 32,
    0xFF000000.uint32, 0x00FF0000.uint32, 0x0000FF00.uint32, 0x000000FF.uint32)
  result.content.fillRect(nil, 0x00000000)


method setImage*(imageview: ImageViewRef, image_path: cstring,
                 mode: ImageMode = FILL_XY) {.async, base.} =
  ## Loads a new image in the ImageView object.
  ##
  ## Arguments:
  ## -   ``image_path`` -- image path.
  var
    neww, newh: cdouble = 0.0
    r: Rect
    image = await loadImageFromFile(image_path)
  if image == nil:
    return
  case mode:
  of FILL_XY:
    neww = imageview.width.cdouble / image.w.cdouble
    newh = imageview.height.cdouble / image.h.cdouble
    image = zoomSurface(image, neww, newh, 1)
  of ICENTER:
    var
      w = image.w
      h = image.h
    while w > imageview.width:
      dec w
    while h > imageview.height:
      dec h
    neww = w.cdouble / image.w.cdouble
    newh = h.cdouble / image.h.cdouble
    image = zoomSurface(image, neww, newh, 1)
    r = rect(
      imageview.width div 2 - w div 2,
      imageview.height div 2 - h div 2,
      image.w, image.h)
  of CENTER_CROP:
    r = rect(
      imageview.width div 2 - image.w div 2,
      imageview.height div 2 - image.h div 2,
      image.w, image.h)
  of ILEFT:
    r = rect(
      0, imageview.height div 2 - image.h div 2,
      image.w, image.h)
  of IRIGHT:
    r = rect(
      imageview.width - image.w, imageview.height div 2 - image.h div 2,
      image.w, image.h)
  of ITOP:
    r = rect(
      imageview.width div 2 - image.w div 2, 0,
      image.w, image.h)
  of IBOTTOM:
    r = rect(
      imageview.width div 2 - image.w div 2, imageview.height - image.h,
      image.w, image.h)
  blitSurface(image, nil, imageview.content, r.addr)
  imageview.is_changed = true

method getImage*(imageview: ImageViewRef): Future[SurfacePtr] {.async, base.} =
  ## Returns the imageview image.
  return imageview.content

method draw*(imageview: ImageViewRef, dst: SurfacePtr) {.async.} =
  ## Draws ImageView on the dst surface.
  blitSurface(imageview.saved_background, nil, imageview.background, nil)
  blitSurface(imageview.content, nil, imageview.background, nil)
  blitSurface(imageview.background, nil, dst, imageview.rect.addr)

method draw*(imageview: ImageViewRef) {.async, inline.} =
  ## Draws ImageView on the parent surface.
  await imageview.draw(imageview.parent)

method flip*(imageview: ImageViewRef, x, y: bool) {.async, base.} =
  ## Flips the ImageView by x and y, if available.
  if x and y:
    imageview.content = zoomSurface(imageview.content, -1.0, -1.0, 1)
  elif x:
    imageview.content = zoomSurface(imageview.content, -1.0, 1.0, 1)
  elif y:
    imageview.content = zoomSurface(imageview.content, 1.0, -1.0, 1)
