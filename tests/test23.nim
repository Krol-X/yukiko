# author: Ethosa
# Canvas test.
import asyncdispatch
import yukiko

var window = Window("Progress bar in Yukiko ^^.")

var canvas = Canvas(512, 256)

waitFor canvas.box(16, 16, 128, 128, 0xf77ff755.uint32)
waitFor canvas.roundBox(32, 32, 256, 128, 18, 0xf77ff755.uint32)
waitFor canvas.hline(16, 128, 64, 0xf77ff755.uint32)
waitFor canvas.aaline(64, 64, 128, 256, 0x7ff77f55.uint32)
waitFor canvas.filledCircle(128, 128, 32, 0x32323250)
waitFor canvas.filledPie(64, 128, 32, 0, 270, 0x323232e3.uint32)
waitFor canvas.filledTrigon(0, 256, 128, 0, 256, 128, 0xdd777735.uint32)


var view = View(512, 256)
waitFor view.setBackground(canvas)
window.addView(view)
waitFor window.setBackgroundColor(0xc0c0ff)
waitFor window.startLoop()
