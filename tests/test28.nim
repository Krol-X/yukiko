# author: Ethosa
# pie chart.
import asyncdispatch
import yukiko
import json

var
  window = Window("Pie chart", 1024, 480)
  data = %*{
    "Nim": %50,
    "Python": %25,
    "C++": %15
  }
  pie = PieChart(100, 100, data=data)

waitFor pie.setBackgroundColor(0xf77ff777'u32)

window.addView(pie)


waitFor window.startLoop()
