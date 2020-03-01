# author: Ethosa
# pressed and released events.
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var  view = View(256, 100)

waitFor view.setBackgroundColor 0x7777ddff.uint32

view.on_press = proc(x, y: cint) {.async.} =
  echo "the view is pressed at position ", x, ", ", y

view.on_release = proc(x, y: cint) {.async.} =
  echo "now the view is not pressed. ", x, ", ", y

window.addView(view)

waitFor window.startLoop()
