# author: Ethosa
# create view and render this
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = View(100, 100)
window.addView(view)

assert view.id == 0

waitFor window.startLoop()
