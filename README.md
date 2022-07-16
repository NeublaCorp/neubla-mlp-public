# Neubla MLP Public

이 페이지는 Neubla 의 개발환경을 사용하시는 외부인들을 위한 가이드를 제공하기 위해 작성되었습니다.

## 서버 접속하기

Neubla 의 Linux server로의 접속에는 [Teleport](https://goteleport.com/) 를
이용합니다. Teleport는 기존 SSH 에 비해 더 나은 보안성과, Web UI를 통한
편리함을 제공합니다. 또한 SSH와 연동되어 있어, SSH를 통해 할 수 있었던 대부분의
작업을 할 수 있습니다.  Teleport 를 사용하기 위해서는 다음과 같은 것들이
필요합니다.

* Smartphone 기기와 Microsoft Authenticator, Authy 와 같은 2-Factor Authentication App 
* Web Browser (Google Chrome, Firefox, Microsoft Edge, Apple Safari 등)를 사용할 수 있는 컴퓨터
* (Terminal 을 통한 접속이 필요한 경우) [Teleport CLI](https://goteleport.com/docs/installation/)

## 서버 사용하기 

제공되는 서버는 Ubuntu Linux 20.04 가 설치되어 있으며, 제공되는 계정은
`sudo` 권한을 가지고 있지 않습니다. 단, `docker` group 에 속해 있기에 Docker 를 이용한
필요한 컨테이너 환경을 구성할 수 있습니다. 가급적 Neubla에서 사용하는 
Docker container 를 통한 표준화된 개발 환경을 사용하시기를 권장드립니다.

Neubla의 표준 환경에 대해서는 [DEVENV](./environ/devenv.md)를 참고하시기 바랍니다.


