#!/usr/bin/env bash

generateRandomName() {
    name = ""
    shuf -n 2 words.txt > "$name"
    echo "$name"
}