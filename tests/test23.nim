# author: Ethosa
# progress bar test
import asyncdispatch
import yukiko

var window = Window("Progress bar in Yukiko ^^.")

var
  progress = ProgressBar(120, 20)
  progress_image = ProgressBar(120, 20)

waitFor progress.setProgress(50)
waitFor progress_image.move(0, 32)
waitFor progress_image.setProgress(55)
waitFor progress_image.setProgressImageFromFile("../progress_bar.jpg")

waitFor progress.setBackgroundColor(0xe0e0e0ff.uint32)
waitFor progress_image.setBackgroundColor(0xe0e0e0ff.uint32)

window.addView(progress, progress_image)
waitFor window.setBackgroundColor(0xc0c0ff)
waitFor window.startLoop()
