#!/bin/bash
set -x
#sudo rm -rf /media/kiblik/boot/*
sudo rsync -arv boot/* /media/kiblik/boot
#sudo rm -rf /media/kiblik/0aed834e-8c8f-412d-a276-a265dc676112/*
sudo rsync -arv root/* /media/kiblik/0aed834e-8c8f-412d-a276-a265dc676112
sudo sync