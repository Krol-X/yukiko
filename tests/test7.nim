# author: Ethosa
# linear layout with center gravity.
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var
  view = View(64, 100)
  view1 = View(256, 100)
  view2 = View(128, 100)
  layout = LinearLayout(500, 400)

waitFor view.setBackgroundColor 0x7777dd
waitFor view1.setBackgroundColor 0x77dd77
waitFor view2.setBackgroundColor 0xdd7777

waitFor layout.addView(view)
waitFor layout.addView(view1)
waitFor layout.addView(view2)
waitFor layout.setGravityX(CENTER)
waitFor layout.setGravityY(CENTER)

window.addView(layout)

waitFor window.startLoop()
