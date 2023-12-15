## lovr-cam

Tiny orbiting camera module for [LÖVR](https://github.com/bjornbytes/lovr).

To use:
* make sure to disable the headset camera in `conf.lua` file: `t.modules.headset = false`
* place `require('cam').integrate()` at the end of your `main.lua` file

Mouse controls:
* left click + drag - orbit camera around the center
* middle click + drag - pan camera; move the center
* wheel up / down - zoom in and out
