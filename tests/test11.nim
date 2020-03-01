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

view.on_click = proc(x, y: cint) {.async.} =
  await view.setText("Money: " & $money & ". :3")
  money *= 2

waitFor box.addView(view)
waitFor box.setGravityX(CENTER)
waitFor box.setGravityY(CENTER)

window.addView(box)

waitFor window.startLoop()
