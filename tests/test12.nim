# author: Ethosa
# Resize the view.
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 320, 480)

waitFor window.setBackgroundColor(0x333333)

var
  view = View(128, 100)
  view1 = View(128, 100)

waitFor view.resize(100, 100)
waitFor view1.move(64, 128)

window.addView(view, view1)

waitFor window.startLoop()
