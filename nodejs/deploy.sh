#!/bin/sh

git pull
npm update
forever restart index.js