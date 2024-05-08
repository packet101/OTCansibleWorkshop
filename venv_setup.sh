#!/usr/bin/env bash

python -m venv ~/ansible-workshop

source ~/ansible-workshop/bin/activate
pip install -r requirements.txt

echo "source ~/ansible-workshop/bin/activate" >> ~/.bashrc
