# author: Ethosa
# event handler via macro `@`
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 320, 480)

waitFor window.setBackgroundColor(0x333333)

var button = Button(128, 32)
waitFor button.setFont("../fonts/DejaVuSans-Bold.ttf", 14)
waitFor button.setText("Press me :3")
waitFor button.setBackgroundColor(0xeeeeee)

button@hover:  # This calls when your mouse enter in button area.
  echo "lol :p"

button@click:  # This calls when you click on button.
  echo "clicked at ", x, ", ", y

window.addView(button)

waitFor window.startLoop()
