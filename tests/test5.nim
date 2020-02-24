# author: Ethosa
# view event handle
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var
  view = View(100, 100)
  view1 = View(100, 100, 25, 75)

proc on_click(x, y: cint) {. eventhandler: view1 .} =
  assert x >= 0
  assert y >= 0
  echo "View1 clicked at position ", x, ", ", y
  waitFor view1.setBackgroundColor(0xdd77dd)

window.addView(view, view1)

assert view.id == 0
assert view.id == 1

waitFor window.startLoop()
