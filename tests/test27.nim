# author: Ethosa
# Linear Gradient test.
import asyncdispatch
import yukiko

var window = Window("Linear gradient with Yukiko ^^.")

var canvas = Canvas(512, 256)

waitFor canvas.lineargradient(256, 0, 250, 128, 0xf77ff7ff.uint32, 0x7ff77fff.uint32)
echo "complete"


var view = View(512, 256)
waitFor view.setBackground(canvas)
window.addView(view)
waitFor window.setBackgroundColor(0xc0c0ff)
waitFor window.startLoop()
