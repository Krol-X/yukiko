# author: Ethosa
# view hover and out
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = View(100, 100)

view.on_hover = proc() {.async.} =
  echo "entered >.<"

view.on_out = proc() {.async.} =
  echo "outed =3"

window.addView(view)

waitFor window.startLoop()
