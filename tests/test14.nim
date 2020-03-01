# author: Ethosa
# Buttons.
import asyncdispatch
import yukiko

var window = Window("Yukiko clicker ^^", 320, 480)

waitFor window.setBackgroundColor(0x333333)

var button = Button(128, 32)
waitFor button.setFont("../fonts/DejaVuSans-Bold.ttf", 14)
waitFor button.setText("Press me :3")

button.on_press = proc(x, y: cint) {.async.} =
  ## This calls when you press on the button.
  await button.setText("pressed 8|")
  await button.setBackgroundColor(0xccccccff.uint32)

button.on_release = proc(x, y: cint) {.async.} =
  await button.setText("Press me :3")
  if button.in_view:
    await button.setBackgroundColor(0xeeeeeeff.uint32)
  else:
    await button.setBackgroundColor(0xe0e0e0ff.uint32)

button.on_hover = proc() {.async.} =
  ## This calls when your mouse enter in the button area.
  await button.setBackgroundColor(0xeeeeeeff.uint32)

button.on_out = proc() {.async.} =
  ## This calls when your mouse out from the button area.
  await button.setBackgroundColor(0xe0e0e0ff.uint32)

window.addView(button)

waitFor window.startLoop()
