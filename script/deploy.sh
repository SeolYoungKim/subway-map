#!/bin/bash

## 변수 설정
EXECUTION_PATH=$(pwd)
SHELL_SCRIPT_PATH=$(dirname $0)
BRANCH=$1
PROFILE=$2

txtrst='\033[1;37m' # White
txtred='\033[1;31m' # Red
txtylw='\033[1;33m' # Yellow
txtpur='\033[1;35m' # Purple
txtgrn='\033[1;32m' # Green
txtgra='\033[1;30m' # Gray

if [[ $# -ne 2 ]]
then
    echo -e "${txtylw}=======================================${txtrst}"
    echo -e "${txtgrn}  << 스크립트 🧐 >>${txtrst}"
    echo -e ""
    echo -e "${txtgrn} $0 브랜치이름 ${txtred}{ prod | dev }"
    echo -e "${txtylw}=======================================${txtrst}"
    exit
fi

## 깃 브랜치 변경 check
function check_df() {
  git fetch
  master=$(git rev-parse $BRANCH)
  remote=$(git rev-parse origin/$BRANCH)

  if [[ $master == $remote ]]; then
    echo -e "[$(date)] Nothing to do!!! 😫"
    exit 1
  fi
}

check_df;

## 저장소 pull
function pull() {
  echo -e ""
  echo -e ">> Pull Request"
  git pull origin main || { echo -e "${txtred}Git pull 실패!${txtrst}"; exit 1; }
}

pull;

## gradle build
function build() {
  echo -e ""
  echo -e ">> Build Gradle"
  cd ..
  ./gradlew clean build || { echo -e "${txtred}Gradle 빌드 실패!${txtrst}"; exit 1; }
}

build;

## 프로세스 pid를 찾는 명령어
pid=""

function searchPidOfJava() {
  echo -e ""
  echo -e ">> Search Pid Of Java (SubwayApplication)"

  pid=$(pgrep -f SubwayApplication)


  if [[ -z "$pid" ]]; then
    echo -e "${txtred}❌ SubwayApplication이 실행 중이지 않습니다.${txtrst}"
  fi

  echo -e "${txtgrn}✅ SubwayApplication 실행 중 (PID: $pid)${txtrst}"
}


searchPidOfJava;

## 프로세스를 종료하는 명령어
function killJava() {
  echo -e ""
  echo -e ">> ${txtpur}Kill Java Process (PID: $pid)${txtrst}"

  if [[ -z "$pid" ]]; then
    echo -e "${txtred}❌ 종료할 프로세스가 없습니다.${txtrst}"
  else
    kill -15 "$pid"
  fi

  sleep 2

  # 종료 확인
  if ps -p "$pid" > /dev/null; then
    echo -e "${txtylw}⚠️ 정상 종료되지 않아 강제 종료 실행 (kill -9)${txtrst}"
    kill -9 "$pid"
  fi

  echo -e "${txtgrn}✅ SubwayApplication 종료 완료.${txtrst}"
}

killJava;

## 자바 프로세스 실행
function runJavaProcess() {
  echo -e ""
  echo -e ">> ${txtpur}Run Java Process${txtrst}"

  java -jar -Dspring.profiles.active=${BRANCH} ~/subway-map/build/libs/*.jar
}

runJavaProcess;
searchPidOfJava;
