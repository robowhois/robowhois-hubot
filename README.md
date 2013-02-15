# RoboWhois script for Hubot

[RoboWhois](http://www.robowhois.com/) script for [Hubot](http://hubot.github.com/).

## Installation

Add the package `hubot-robowhois` as dependencies in your Hubot `package.json` file.

    "dependencies": {
      "hubot-robowhois": ">= 0"
    }

Run the following command to make sure those packages is installed.

    $ npm install hubot-robowhois

To enable the script, add the `hubot-robowhois` entry to the `external-scripts.json` file (you may need to create this file, if it is not present or if you upgraded from Hubot < 2.4).

    ["hubot-robowhois"]

