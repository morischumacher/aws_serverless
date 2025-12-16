FROM fischerscode/flutter as flutter-builder

WORKDIR /opt/g7t2
COPY ui /opt/g7t2/ui

ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN apt-get update && apt-get install -y --fix-missing curl git wget unzip libgtk-3-dev libsecret-1-dev libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 cmake ninja-build g++ clang pkg-config

# Switch to a non-root user
RUN chown -R flutter:flutter /opt/g7t2/ui
USER flutter
WORKDIR /opt/g7t2/ui
# Ensure the correct Flutter version is installed
RUN flutter channel stable
RUN flutter upgrade

RUN flutter doctor  
RUN flutter pub outdated
RUN flutter build web  

FROM node:lts as base

RUN apt-get update && apt-get install -y python3 python3-pip

RUN npm install -g aws-cdk-local aws-cdk

COPY aws /opt/g7t2/aws
WORKDIR /opt/g7t2/aws
RUN pip install --break-system-packages -r requirements.txt


COPY docker/aws_start.sh .
COPY --from=flutter-builder /opt/g7t2/ui/build ../ui/build
RUN chmod +x aws_start.sh

CMD ["/bin/bash", "-c", "./aws_start.sh"]