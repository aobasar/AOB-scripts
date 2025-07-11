#!/bin/bash
#brew update
brew update && brew upgrade && brew cleanup

#software update
sudo softwareupdate -i -a
