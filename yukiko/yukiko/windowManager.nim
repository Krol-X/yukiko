import asyncdispatch
import sdl2

import views/view
export view
import utils/imageloader


discard sdl2.init(INIT_EVERYTHING)


type
  ActivityRef* = ref object
    name*: string
    views*: seq[ViewRef]
  WindowManager* = ref object
    event: Event
    is_run: bool
    window: WindowPtr
    render: RendererPtr
    background_color: uint32
    views*: ptr seq[ViewRef]
    current_activity*: string
    activities*: seq[ActivityRef]


proc Activity*(name: string): ActivityRef =
  ActivityRef(name: name, views: @[])


proc Window*(name: cstring, width: cint = 720, height: cint = 480): WindowManager =
  ## Creates a new window manager object.
  ##
  ## Arguments:
  ## -   ``name`` -- window name.
  ## -   ``width`` -- window width.
  ## -   ``height`` -- window height.
  var window = sdl2.createWindow(
    name, 100, 100, width, height, SDL_WINDOW_SHOWN)
  var render = sdl2.createRenderer(
    window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
  var activity = ActivityRef(name: "Main", views: @[])
  result = WindowManager(window: window, render: render,
    is_run: true, event: sdl2.defaultEvent,
    background_color: 0x000000, views: activity.views.addr, current_activity: "Main",
    activities: @[activity])


proc addView*(wm: WindowManager, views: varargs[ViewRef]) {.inline.} =
  ## Adds a new view(s) in window for render.
  for view in views:
    view.parent = wm.window.getSurface
    view.id = wm.views[].len
    wm.views[].add view


proc addActivity*(wm: WindowManager, a: ActivityRef) =
  var act = a
  for activity in wm.activities:
    if act.name == activity.name:
      return
  wm.activities.add act


proc setActivity*(wm: WindowManager, name: string) =
  if name == wm.current_activity:
    return
  var
    contains = false
    i = 0
  for activity in wm.activities:
    if activity.name == name:
      contains = true
      break
    inc i
  if contains:
    wm.views = wm.activities[i].views.addr
    wm.current_activity = name


proc addView*(wm: WindowManager, views: varargs[ViewRef], activity: string) {.inline.} =
  var now = wm.current_activity
  wm.setActivity(activity)
  wm.addView(views)
  wm.setActivity(now)


proc setBackgroundColor*(wm: WindowManager, color: uint32) {.async.} =
  ## Changes window background color.
  wm.background_color = color

proc setIcon*(wm: WindowManager, image_path: cstring) {.async.} =
  ## Changes window icon.
  var image = await loadImageFromFile(image_path)
  if image == nil:
    return
  wm.window.setIcon(image)

proc setTitle*(wm: WindowManager, title: cstring) {.async.} =
  ## Changes window title.
  wm.window.setTitle(title)


proc handleEvent(wm: WindowManager) {.async.} =
  ## Handles all window events.
  while pollEvent(wm.event):
    if wm.event.kind == QuitEvent:
      wm.is_run = false
      break
    for view in wm.views[]:
      await view.event(wm.views[], wm.event)


proc draw(wm: WindowManager) {.async.} =
  wm.window.getSurface.fillRect(nil, wm.background_color)
  for view in wm.views[]:
    await view.draw wm.window.getSurface


proc startLoop*(wm: WindowManager) {.async.} =
  ## Starts loop and event handler.
  while wm.is_run:
    await wm.handleEvent()
    await wm.draw()
    discard wm.window.updateSurface()
  sdl2.destroy(wm.render)
  sdl2.destroy(wm.window)
