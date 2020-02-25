# author: Ethosa
# Hello world program.
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = TextView(256, 100)
waitFor view.setFont("../fonts/DejaVuSans.ttf", 12)
waitFor view.setText("Hello, Yukiko!")

window.addView(view)

waitFor window.startLoop()
