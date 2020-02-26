# author: Ethosa
# Buttons.
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 320, 480)

waitFor window.setBackgroundColor(0x333333)

var button = Button(128, 32)
waitFor button.setFont("../fonts/DejaVuSans-Bold.ttf", 14)
waitFor button.setText("Press me :3")

proc on_press(x, y: cint) {.async, eventhandler: button.} =
  ## This calls when you press on the button.
  await button.setText("pressed 8|")
  await button.setBackgroundColor(0xcccccc)

proc on_release(x, y: cint) {.async, eventhandler: button.} =
  await button.setText("Press me :3")
  if button.in_view:
    await button.setBackgroundColor(0xeeeeee)
  else:
    await button.setBackgroundColor(0xe0e0e0)

proc on_hover() {.async, eventhandler: button.} =
  ## This calls when your mouse enter in the button area.
  await button.setBackgroundColor(0xeeeeee)

proc on_out() {.async, eventhandler: button.} =
  ## This calls when your mouse out from the button area.
  await button.setBackgroundColor(0xe0e0e0)

window.addView(button)

waitFor window.startLoop()
