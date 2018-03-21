#!/bin/bash
osascript -l JavaScript <<"EOF"

  var app = Application.currentApplication()
  app.includeStandardAdditions = true

  app.say("Hello World", {
      using: "Alex",
      speakingRate: 140,
      pitch: 42,
      modulation: 60
  })

   app.doShellScript('echo sss')

EOF

