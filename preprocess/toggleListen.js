#!/usr/bin/osascript -l JavaScript
var app = Application.currentApplication()
app.includeStandardAdditions = true

const fnKeyCode = 63
Application('System Events').keyCode([fnKeyCode, fnKeyCode])
delay(0.5)
