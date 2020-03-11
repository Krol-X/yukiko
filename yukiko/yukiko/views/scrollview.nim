# author: Ethosa
import asyncdispatch
import sdl2
import view


type
  ScrollViewObj* = object of ViewObj
    views*: seq[ptr ViewRef]
    scroll_thumb*: SurfacePtr
    scroll_back*: SurfacePtr
    scroll_size*: cint
    scroll_width*: cint
    scroll_height*: cint
    swidth*: cint
    sheight*: cint
    minscrollh*: cint
    sy*: cint
    show_scroller*: bool
    scroll_pressed*: bool
  ScrollViewRef* = ref ScrollViewObj


template scrollbar_init*(result: untyped): untyped =
  `result`.scroll_size = 50
  `result`.scroll_width = 8
  `result`.swidth = swidth
  `result`.sheight = sheight
  `result`.minscrollh = 16
  `result`.show_scroller = true
  `result`.scroll_pressed = false
  `result`.sy = 0

template scrollbar_recalc*(result, sheight: untyped): untyped =
  `result`.scroll_height = (`sheight` / height * `sheight`.float).cint
  if `result`.scroll_height < `result`.minscrollh:
    `result`.scroll_height = `result`.minscrollh
  `result`.scroll_back = createRGBSurface(
    0, `result`.scroll_width, `sheight`, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  `result`.scroll_back.fillRect(nil, 0x33333355)
  `result`.scroll_thumb = createRGBSurface(
    0, `result`.scroll_width, `result`.scroll_height, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  `result`.scroll_thumb.fillRect(nil, 0x333333ff)


proc ScrollView*(width, height: cint, x: cint = 0, y: cint = 0,
                 parent: SurfacePtr = nil, swidth: cint = 256, sheight: cint = 256): ScrollViewRef =
  viewInitializer(ScrollViewRef)
  scrollbar_init(result)
  scrollbar_recalc(result, sheight)

proc addView*(scroll: ScrollViewRef, view: ViewRef) {.async.} =
  ## Adds view in scroll
  scroll.views.add view.addr

method draw*(scroll: ScrollViewRef, dst: SurfacePtr) {.async.} =
  ## Draws scroll in scroll.parent.
  if scroll.is_visible:
    if scroll.is_changed:
      scroll.is_changed = false
    scroll.background.fillRect(nil, 0x00000000)
    for view in scroll.views:
      if view[].is_changed:
        view[].is_changed = false
        await view[].redraw()
        scroll.is_changed = true
      await view[].draw(scroll.background)
    var
      r = rect(0, scroll.sy, scroll.swidth, scroll.sheight)
      sback = rect(
        scroll.swidth - scroll.scroll_width,
        0, scroll.scroll_width, scroll.sheight)
      sthumb = rect(
        scroll.swidth - scroll.scroll_width,
        scroll.sy div (scroll.height / scroll.sheight).cint,
        scroll.scroll_width, scroll.sheight)

    blitSurface(scroll.background, r.addr, dst, scroll.rect.addr)
    blitSurface(scroll.scroll_back, nil, dst, sback.addr)
    blitSurface(scroll.scroll_thumb, nil, dst, sthumb.addr)
    await scroll.on_draw()

template scrollercalc(sc, scrolled: untyped): untyped =
  if `scrolled` >= 0:
    if `scrolled` + `sc`.sheight <= `sc`.height:
      `sc`.sy = `scrolled`
      `sc`.is_changed = true
    elif `scrolled` <= `sc`.height:
      `sc`.sy = `sc`.height - `sc`.sheight
      `sc`.is_changed = true
  else:
    `sc`.sy = 0
    `sc`.is_changed = true


method setThumbWidth*(scroll: ScrollViewRef, size: cint) {.async, base.} =
  ## Changes the scroll bar thumb width.
  scroll.scroll_width = size

method setThumbBackgroundColor*(scroll: ScrollViewRef, color: uint32) {.async, base.} =
  ## Changes the scroll bar thumb background color.
  scroll.scroll_thumb = createRGBSurface(
    0, scroll.scroll_width, scroll.scroll_height, 32,
    0xFF000000.uint32, 0x00FF0000, 0x0000FF00, 0x000000FF)
  scroll.scroll_thumb.fillRect(nil, color)


method event*(scroll: ScrollViewRef, views: seq[ViewRef], event: Event) {.async.} =
  await procCall scroll.ViewRef.event(views, event)
  if event.kind == MouseWheel and scroll.in_view:
    let
      e = wheel event
      scrolled = scroll.sy + -e.y*scroll.scroll_size
    scrollercalc(scroll, scrolled)
  elif event.kind == MouseMotion:
    let
      e = motion event
      p = point[cint](e.x, e.y)
    if scroll.rect.contains(p):
      scroll.in_view = true
    if scroll.scroll_pressed:
      let scrolled = scroll.sy + e.yrel*(scroll.scroll_size / 16).cint
      scrollercalc(scroll, scrolled)
  elif scroll.in_view and event.kind == KeyDown:
    let key = event.key.keysym.sym
    case key
    of 1073741906:  # up arrow
      let scrolled = scroll.sy - scroll.scroll_size
      scrollercalc(scroll, scrolled)
    of 1073741905:  # down arrow
      let scrolled = scroll.sy + scroll.scroll_size
      scrollercalc(scroll, scrolled)
    else:
      discard
  elif event.kind == MouseButtonDown and scroll.in_view:
    let
      e = button event
      sthumb = rect(
        scroll.swidth - scroll.scroll_width,
        scroll.sy div (scroll.height / scroll.sheight).cint,
        scroll.scroll_width, scroll.sheight)
      p = point[cint](e.x, e.y)
    if sthumb.contains(p):
      scroll.scroll_pressed = true
  elif event.kind == MouseButtonUp:
    scroll.scroll_pressed = false
