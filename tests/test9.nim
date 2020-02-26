# author: Ethosa
# pressed and released events.
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var
  view = View(256, 100)

waitFor view.setBackgroundColor 0x7777dd

proc on_press(x, y: cint) {.async, eventhandler: view.} =
  echo "the view is pressed at position ", x, ", ", y

proc on_release(x, y: cint) {.async, eventhandler: view.} =
  echo "now the view is not pressed. ", x, ", ", y

window.addView(view)

waitFor window.startLoop()
