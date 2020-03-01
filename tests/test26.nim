# author: Ethosa
# activities test
import asyncdispatch
import yukiko

var window = Window("Yukiko Activities o.o")
waitFor window.setIcon("../nimlogo.png")
waitFor window.setBackgroundColor(0xc0c0ff)

# Add the new activity:
window.addActivity(Activity("Second"))
# IMPORTANT: Standart Activity is Main.

var
  viewInMain = View(128, 128)
  viewInSecond = View(128, 128)
waitFor viewInMain.setBackgroundColor(0xf77ff7ff.uint32)
waitFor viewInSecond.setBackgroundColor(0x7ff77fff.uint32)

waitFor viewInSecond.move(128, 128)

viewInMain@click:
  window.setActivity("Second")
  # window.setActivity is changes activity to other activity,
  # if available.

viewInSecond@click:
  window.setActivity("Main")

window.addView(viewInMain)
window.addView(viewInSecond, "Second")

waitFor window.startLoop()
