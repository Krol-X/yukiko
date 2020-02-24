# author: Ethosa
# view focus and unfocus
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = View(100, 100)

proc on_focus() {.eventhandler: view.} =
  echo "hm?"

proc on_unfocus() {.eventhandler: view.} =
  echo "ok, bye."

window.addView(view)

waitFor window.startLoop()
