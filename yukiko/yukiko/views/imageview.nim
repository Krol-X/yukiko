# author: Ethosa
import macros
import asyncdispatch
import sdl2
import sdl2/gfx
import sdl2/image

import view
import ../yukikoEnums

discard image.init()


type
  ImageViewObj = object of ViewObj
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
  result.background.fillRect(nil, 0x00000000)
  result.saved_background.fillRect(nil, 0x00000000)
  result.background_color = 0x00000000


method setImage*(imageview: ImageViewRef, image_path: cstring, mode: ImageMode = FILL_XY) {.async, base.} =
  ## Loads a new image in the ImageView object.
  ##
  ## Arguments:
  ## -   ``image_path`` -- image path.
  var
    rw = rwFromFile(image_path, "r")
    png = isPNG(rw).bool
    jpg = isJPG(rw).bool
    bmp = isBMP(rw).bool
    image: SurfacePtr
    neww, newh: cdouble = 0.0
  if png:
    image = loadPNG_RW(rw)
  elif jpg:
    image = loadJPG_RW(rw)
  elif bmp:
    image = loadBMP_RW(rw)
  else:
    return
  case mode:
  of FILL_XY:
    neww = imageview.width.cdouble / image.w.cdouble
    newh = imageview.height.cdouble / image.h.cdouble
    image = zoomSurface(image, neww, newh, 1)
    blitSurface(image, nil, imageview.background, nil)
    blitSurface(image, nil, imageview.saved_background, nil)
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
    var r = rect(
      imageview.width div 2 - w div 2,
      imageview.height div 2 - h div 2,
      image.w, image.h)
    blitSurface(image, nil, imageview.background, r.addr)
    blitSurface(image, nil, imageview.saved_background, r.addr)
  of CENTER_CROP:
    var r = rect(
      imageview.width div 2 - image.w div 2,
      imageview.height div 2 - image.h div 2,
      image.w, image.h)
    blitSurface(image, nil, imageview.background, r.addr)
    blitSurface(image, nil, imageview.saved_background, r.addr)
  of ILEFT:
    var r = rect(
      0, imageview.height div 2 - image.h div 2,
      image.w, image.h)
    blitSurface(image, nil, imageview.background, r.addr)
    blitSurface(image, nil, imageview.saved_background, r.addr)
  of IRIGHT:
    var r = rect(
      imageview.width - image.w, imageview.height div 2 - image.h div 2,
      image.w, image.h)
    blitSurface(image, nil, imageview.background, r.addr)
    blitSurface(image, nil, imageview.saved_background, r.addr)
  of ITOP:
    var r = rect(
      imageview.width div 2 - image.w div 2, 0,
      image.w, image.h)
    blitSurface(image, nil, imageview.background, r.addr)
    blitSurface(image, nil, imageview.saved_background, r.addr)
  of IBOTTOM:
    var r = rect(
      imageview.width div 2 - image.w div 2, imageview.height - image.h,
      image.w, image.h)
    blitSurface(image, nil, imageview.background, r.addr)
    blitSurface(image, nil, imageview.saved_background, r.addr)
  imageview.is_changed = true
