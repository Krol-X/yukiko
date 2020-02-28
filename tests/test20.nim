# author: Ethosa
# Span text.
import asyncdispatch
import yukiko

var window = Window("Yukiko ^^")

waitFor window.setBackgroundColor(0xc0c0ff)

var view = TextView(256, 100)
var text = span"""Hello, Yukiko!
    BAN ._. ...
"""

text.setFont("../fonts/DejaVuSans.ttf", 12)
text[0..4].setForegroundColor(0x6272a4)
text[4..6].setBackgroundColor(0x00000000)
text[7].setForegroundColor(0xf77ff7)
text[7].setBackgroundColor(0x333333ff)


waitFor view.setBackgroundColor(0x00000000)
waitFor view.setText(text)

window.addView(view)

waitFor window.startLoop()
