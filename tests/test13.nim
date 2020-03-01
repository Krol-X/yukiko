# author: Ethosa
# Change background color
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 320, 480)

waitFor window.setBackgroundColor(0x333333)

var view = View(128, 100)

view.on_click = proc(x, y: cint) {.async.} =
  # standart background color is #E0E0E0ff
  # standart accent color is #212121
  var color = await view.getBackgroundColor()
  await view.setBackgroundColor(color - 0x00050000.uint32)

window.addView(view)

waitFor window.startLoop()
