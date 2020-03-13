# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/gfx
import view

import ../drawable/canvas


type
  ScrollViewObj* = object of ViewObj
    show_scroller*: bool
    scroll_pressed*: bool
    scroll_size*: cint
    scroll_width*: cint
    scroll_height*: cint
    swidth*: cint
    sheight*: cint
    minscrollh*: cint
    sy*: cint
    views*: seq[ViewRef]
    scroll_thumb*: SurfacePtr
    scroll_back*: SurfacePtr
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
  if `sheight` < `result`.height:
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


template rescrollbar*(result, width, sheight: untyped): untyped =
  if `sheight` < `result`.height:
    var
      old_height = `result`.scroll_height
      old_width = `result`.scroll_height
    `result`.scroll_height = (`sheight` / `result`.height * `sheight`.float).cint
    if `result`.scroll_height < `result`.minscrollh:
      `result`.scroll_height = `result`.minscrollh
    var
      w = `width`.cdouble / old_width.cdouble
      h = `result`.scroll_height.cdouble / old_height.cdouble
    `result`.scroll_back = `result`.scroll_back.zoomSurface(w, 1.0, 1)
    `result`.scroll_thumb = `result`.scroll_thumb.zoomSurface(w, h, 1)


proc ScrollView*(width, height: cint, x: cint = 0, y: cint = 0,
                 parent: SurfacePtr = nil, swidth: cint = 256, sheight: cint = 256): ScrollViewRef =
  viewInitializer(ScrollViewRef)
  scrollbar_init(result)
  scrollbar_recalc(result, sheight)

proc addView*(scroll: ScrollViewRef, view: ViewRef) {.async.} =
  ## Adds view in scroll
  scroll.views.add view

method draw*(scroll: ScrollViewRef, dst: SurfacePtr) {.async.} =
  ## Draws scroll in scroll.parent.
  if scroll.is_visible:
    if scroll.is_changed:
      scroll.is_changed = false
    scroll.background.fillRect(nil, 0x00000000)
    for view in scroll.views:
      if view.is_changed:
        view.is_changed = false
        await view.redraw()
        scroll.is_changed = true
      await view.draw(scroll.background)
    var r = rect(0, scroll.sy, scroll.swidth, scroll.sheight)

    blitSurface(scroll.background, r.addr, dst, scroll.rect.addr)

    if scroll.sheight < scroll.height:
      var
        sback = rect(
          scroll.swidth - scroll.scroll_width,
          0, scroll.scroll_width, scroll.sheight)
        sthumb = rect(
          scroll.swidth - scroll.scroll_width,
          (scroll.sy.float / (scroll.height / scroll.sheight)).cint,
          scroll.scroll_width, scroll.sheight)
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
  rescrollbar(scroll, size, scroll.sheight)
  scroll.scroll_width = size

method setThumbBackgroundColor*(scroll: ScrollViewRef, color: uint32) {.async, base.} =
  ## Changes the scroll bar thumb background color.
  scroll.scroll_thumb.fillRect(nil, color)
  rescrollbar(scroll, scroll.scroll_width, scroll.sheight)

method setThumbBackground*(scroll: ScrollViewRef, canvas: CanvasRef) {.async, base.} =
  ## Changes the scroll bar thumb background.
  var surface = await canvas.getSurface()
  let
    neww = scroll.scroll_thumb.w.cdouble / surface.w.cdouble
    newh = scroll.scroll_thumb.h.cdouble / surface.h.cdouble
  surface = zoomSurface(surface, neww, newh, 1)
  scroll.scroll_thumb = surface
  rescrollbar(scroll, scroll.scroll_width, scroll.sheight)


method setScrollBarBackgroundColor*(scroll: ScrollViewRef, color: uint32) {.async, base.} =
  ## Changes the scroll bar background color.
  scroll.scroll_back.fillRect(nil, color)
  rescrollbar(scroll, scroll.scroll_width, scroll.sheight)

method setScrollBarBackground*(scroll: ScrollViewRef, canvas: CanvasRef) {.async, base.} =
  ## Changes the scroll bar background.
  var surface = await canvas.getSurface()
  let
    neww = scroll.scroll_back.w.cdouble / surface.w.cdouble
    newh = scroll.scroll_back.h.cdouble / surface.h.cdouble
  surface = zoomSurface(surface, neww, newh, 1)
  scroll.scroll_back = surface
  rescrollbar(scroll, scroll.scroll_width, scroll.sheight)



method event*(scroll: ScrollViewRef, views: seq[ViewRef], event: Event) {.async.} =
  await procCall scroll.ViewRef.event(views, event)
  if scroll.sheight < scroll.height:
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
