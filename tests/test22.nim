# author: Ethosa
# ScrollView test.
import asyncdispatch
import yukiko

var
  window = Window("ScrollView Yukiko ^^")
  image_path = "../nimlogo.png"

var
  scroll = ScrollView(512, 512, swidth=512)  ## swidth/sheight is the width/height, which see user.
  image = ImageView(512, 512)
  view = View(512, 512)
waitFor image.setImage(image_path, mode=CENTER_CROP)

waitFor scroll.addView(view)
waitFor scroll.addView(image)

window.addView(scroll)

waitFor window.setIcon(image_path)
waitFor window.setBackgroundColor(0xc0c0ff)
waitFor window.startLoop()
