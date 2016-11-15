#!/usr/bin/env bash

generateRandomName() {
    shuf -n 2 includes/words.txt
    echo "$name"
}