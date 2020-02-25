# author: Ethosa
# Clicker program.
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 321, 481)

var
  view = TextView(256, 100)
  box = LinearLayout(320, 480)
  money: uint64 = 1
waitFor view.setFont("../fonts/DejaVuSans.ttf", 12)
waitFor view.setText("Hello, Yukiko!")

proc on_click(x, y: cint) {.eventhandler: view.} =
  waitFor view.setText("Money: " & $money & ". :3")
  money *= 2

waitFor box.addView(view)
waitFor box.setGravityX(CENTER)
waitFor box.setGravityY(CENTER)

window.addView(box)

waitFor window.startLoop()
