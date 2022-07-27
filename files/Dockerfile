# Unminized version of the Ubuntu Docker image
# You can build this  image with:
# docker build -t ubuntu-unmin ~/.dotfiles/master/files/Dockerfile
FROM ubuntu:latest
RUN yes | unminimize
RUN apt update -y
RUN apt upgrade -y
RUN apt install curl git zsh -y
