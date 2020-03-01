# author: Ethosa
import asyncdispatch
import sdl2
import view


type
  ScrollViewObj = object of ViewObj
    views: seq[ViewRef]
    scroll_thumb: SurfacePtr
    scroll_back: SurfacePtr
    scroll_size: cint
    scroll_width: cint
    swidth: cint
    sheight: cint
    minscrollh: cint
    show_scroller: bool
    sy: cint
    scroll_pressed: bool
  ScrollViewRef* = ref ScrollViewObj


proc ScrollView*(width, height: cint, x: cint = 0, y: cint = 0,
                 parent: SurfacePtr = nil, swidth: cint = 256, sheight: cint = 256): ScrollViewRef =
  viewInitializer(ScrollViewRef)
  result.scroll_size = 32
  result.scroll_width = 8
  result.swidth = swidth
  result.sheight = sheight
  result.minscrollh = 16
  result.show_scroller = true
  result.scroll_pressed = false
  result.sy = 0
  var h = (sheight / height * sheight.float).cint
  if h < result.minscrollh:
    h = result.minscrollh
  result.scroll_back = createRGBSurface(
    0, result.scroll_width, sheight, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  result.scroll_back.fillRect(nil, 0x33333355)
  result.scroll_thumb = createRGBSurface(
    0, result.scroll_width, h, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  result.scroll_thumb.fillRect(nil, 0x333333ff)


proc addView*(scroll: ScrollViewRef, view: ViewRef) {.async.} =
  ## Adds view in scroll
  scroll.views.add view

method draw*(scroll: ScrollViewRef, dst: SurfacePtr) {.async.} =
  ## Draws scroll in scroll.parent.
  if scroll.is_changed:
    scroll.is_changed = false
  blitSurface(scroll.saved_background, nil, scroll.background, nil)
  for view in scroll.views:
    if view.is_changed:
      view.is_changed = false
      await view.redraw()
      scroll.is_changed = true
    await view.draw(scroll.background)
  var
    r = rect(0, scroll.sy, scroll.swidth, scroll.sheight)
    sback = rect(
      scroll.swidth - scroll.scroll_width,
      0, scroll.scroll_width, scroll.sheight)
    sthumb = rect(
      scroll.swidth - scroll.scroll_width,
      scroll.sy div 2, scroll.scroll_width, scroll.sheight)

  blitSurface(scroll.background, r.addr, dst, scroll.rect.addr)
  blitSurface(scroll.scroll_back, nil, dst, sback.addr)
  blitSurface(scroll.scroll_thumb, nil, dst, sthumb.addr)

method event*(scroll: ScrollViewRef, views: seq[ViewRef], event: Event) {.async.} =
  await procCall scroll.ViewRef.event(views, event)
  if event.kind == MouseWheel and scroll.in_view:
    let
      e = wheel event
      scrolled = scroll.sy + -e.y*scroll.scroll_size
    if scrolled >= 0 and scrolled + scroll.sheight <= scroll.height:
      scroll.sy = scrolled
      scroll.is_changed = true
  elif event.kind == MouseMotion:
    let
      e = motion event
      p = point[cint](e.x, e.y)
    if scroll.rect.contains(p):
      scroll.in_view = true
    if scroll.scroll_pressed:
      let scrolled = scroll.sy + e.yrel
      if scrolled >= 0 and scrolled + scroll.sheight <= scroll.height:
        scroll.sy = scrolled
  elif scroll.in_view and event.kind == KeyDown:
    let key = event.key.keysym.sym
    case key
    of 1073741906:  # up arrow
      let scrolled = scroll.sy - scroll.scroll_size
      if scrolled >= 0 and scrolled + scroll.sheight <= scroll.height:
        scroll.sy = scrolled
        scroll.is_changed = true
    of 1073741905:  # down arrow
      let scrolled = scroll.sy + scroll.scroll_size
      if scrolled >= 0 and scrolled + scroll.sheight <= scroll.height:
        scroll.sy = scrolled
        scroll.is_changed = true
    else:
      discard
  elif event.kind == MouseButtonDown and scroll.in_view:
    let
      e = button event
      sthumb = rect(
        scroll.swidth - scroll.scroll_width,
        scroll.sy div 2, scroll.scroll_width, scroll.sheight)
    if e.x >= sthumb.x and e.x <= sthumb.x + sthumb.w and e.y >= sthumb.y and e.y <= sthumb.y + sthumb.h:
      scroll.scroll_pressed = true
  elif event.kind == MouseButtonUp:
    scroll.scroll_pressed = false
