# author: Ethosa
# ImageView test.
import asyncdispatch
import yukiko

var
  window = Window("ImageView Yukiko ^^")
  image_path = "../nimlogo.png"

var
  image = ImageView(512, 512)
  view = View(512, 512)
waitFor image.setImage(image_path, mode=CENTER_CROP)  # Default mode is FILL_XY
## modes for imageview:
## - ``FILL_XY`` -- resizes the loaded image to imageview size.
## - ``ICENTER`` -- resizes the loaded image, if needed and places it in the center of imageview.
## - ``CENTER_CROP`` -- places loaded image in the center of imageview, without resize it.
## - ``ILEFT`` -- places loaded image in the left side of the imageview.
## - ``IRIGHT`` -- places loaded image in the right side of the imageview.
## - ``ITOP`` -- places loaded image in the top side of the imageview.
## - ``IBOTTOM`` -- places loaded image in the bottom side of the imageview.

window.addView(view, image)

waitFor window.setBackgroundColor(0xc0c0ff)
waitFor window.startLoop()
