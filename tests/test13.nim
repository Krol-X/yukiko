# author: Ethosa
# Change background color
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 320, 480)

waitFor window.setBackgroundColor(0x333333)

var view = View(128, 100)

proc on_click(x, y: cint) {.eventhandler: view.} =
  # standart background color is #E0E0E0
  # standart accent color is #212121
  var color = waitFor view.getBackgroundColor()
  waitFor view.setBackgroundColor(color - 0x000500)

window.addView(view)

waitFor window.startLoop()
