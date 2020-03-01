# author: Ethosa
# listview test.
import asyncdispatch
import yukiko

var window = Window("Yukiko ListView.")

var
  list = ListView(512, 256, swidth=348)
  view = View(348, 256)
  textview = TextView(256, 512)
var text = span"""Hello, Yukiko!
    BAN ._. ...

   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
   yukiko yukiko yukiko
"""

text.setFont("../fonts/DejaVuSans.ttf", 12)
text[0..4].setForegroundColor(0x6272a4)
text[4..6].setBackgroundColor(0x00000000)
text[7].setForegroundColor(0xf77ff7)
text[7].setBackgroundColor(0x333333ff)
waitFor textview.setBackgroundColor(0x00000000)
waitFor textview.setText(text)

waitFor view.setBackgroundImageFromFile("../nimlogo.png")

waitFor list.addView view
waitFor list.addView textview

echo list.width
echo list.height

window.addView list
waitFor window.setBackgroundColor(0xc0c0ff)
waitFor window.startLoop()
