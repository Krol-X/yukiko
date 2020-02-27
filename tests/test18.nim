# author: Ethosa
# textinput test
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = EditText(64, 100)
waitFor view.setFont("../fonts/DroidSans.ttf", 12)
waitFor view.setText("input ... привет")

window.addView(view)

waitFor window.startLoop()

