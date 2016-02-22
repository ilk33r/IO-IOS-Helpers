#!/bin/sh
set -e

brew update
brew outdated xctool || brew upgrade xctool