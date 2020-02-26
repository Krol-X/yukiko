# author: Ethosa
# view hover and out
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = View(100, 100)

proc on_hover() {.async, eventhandler: view.} =
  echo "entered >.<"

proc on_out() {.async, eventhandler: view.} =
  echo "outed =3"

window.addView(view)

waitFor window.startLoop()
