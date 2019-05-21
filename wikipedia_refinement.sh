#!/bin/bash

# 옵션설명시작

# 첫번째 인자
#	-y = gawk 설치
#	-u = apt 또는 brew 업데이트
#	-s 또는 나머지 = 스킵
# 두번째 인자
#	-y = infobox 통합파일로 추출
#	-n = infobox 개별파일로 추출
# 세번째 인자
#	-y = 초록 통합파일로 추출
#	-n = 초록 개별파일로 추출
# 네번째 인자
#	-y = Json파일 생성
#	-n = Json파일 생성안함
# 다섯번째 인자
#	처리할 wikidump 파일 이름(같은폴더내에 존재해야함)

# 옵션설명끝

CHECK_OS="`uname -s`" 
case "$CHECK_OS" in
    Darwin*)   THIS_OS="MAC";;
    Linux*)   THIS_OS="LINUX";;
esac 
echo "OS 확인 : ${THIS_OS}"
printf "gawk 설치 옵션 : "
case "$1" in
	-i)
		printf "install\n"
		;;
	-u)
		printf "update\n"
		;;
	*)
		printf "skip\n"
		;;
esac

case "$1" in
	-i)
		if [[ "$CHECK_OS" = "Darwin"* ]]; then
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
			brew install gawk
		elif [[ "$CHECK_OS" = "Linux"* ]]; then
			sudo apt update
			sudo apt install gawk
		fi
		;;
	-u)
		if [[ "$CHECK_OS" = "Darwin"* ]]; then
			brew upgrade
		elif [[ "$CHECK_OS" = "Linux"* ]]; then
			sudo apt update
			sudo apt upgrade
		fi
		;;
	*)
		echo "gawk 설치(업데이트)를 하지 않도록 선택하셨습니다."
esac

case "$2" in
	-y)	
		echo "dump 전처리 & infobox 통합파일로 추출중..."
		gawk -f Preprocessing.awk $5
		;;
	-n)
		echo "dump 전처리 & infobox 개별파일로 추출중..."
		gawk -f Preprocessing_dif.awk $5
		;;
esac

echo "plaintext 추출중..."
grep . result.xml | ./wiki2text > plaintext.txt

case "$3" in
	-y)
		echo "초록 통합파일로 추출중..."
		gawk -f abstract.awk plaintext.txt
		;;
	-n)
		echo "초록 개별파일로 추출중..."
		gawk -f abstract_dif.awk plaintext.txt
		;;
esac

case "$4" in
	-y)
		echo "Json 생성중..."
		gawk -f makejson.awk all_docs_infobox.txt all_docs_abstract.txt
		;;
	-n)
		echo "Json 생성 하지않음"
		;;
esac

echo "완료!"
