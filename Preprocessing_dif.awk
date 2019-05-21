BEGIN{
	unclosed = 0 #중괄호가 안닫힌경우 횟수 카운트변수
	unclosedref = 0 #각주, 인용문 태그가 안닫힌경우 카운트변수
	system("rm -rf infobox")
	system("mkdir infobox")
}

function checktype(text){
	#둘러싸인 내용중 남길 텍스트가 포함된 위키문법태그들
	islang = match(text, "^(" ")?([lL]{1,2})ang(-)?([a-z]{1,3})?(" ")?$")
	isnorthkorean = match(text, "^문화어$")
	isunicode = match(text, ".nicode")
	iskorunicode = index(text, "유니코드")
	isruby = match(text, "^(" ")?.uby(-[a-z]{1,3})?(" ")?$")
	ishanja = match(text, "^(" ")?한자(" ")?$")
	iszh = match(text, "^(" ")?.h(-[a-z]{1,3})?(" ")?$")
	isnysesmall = match(text, "^(" ")?.yse(-[a-z]{1,3})?(" ")?$")
	isnysebig = match(text, "^(" ")?NYSE(-[a-z]{1,3})?(" ")?$")
	isipabig = index(text, "IPA")
	isipasmall = match(text, "^(" ")?.pa(-[a-z]{1,3})?(" ")?$")
	ismath = match(text, "^math([a-z]{1,3})?$")
	isket = match(text, "^([a-z]{1,3}-)?ket")
	isbra = match(text, "^bra$")
	isangbr = match(text, "^angbr$")
	isvie = match(text, "^.ie$")
	isoldkorean = match(text, "^중세 국어$")

	iscountryimage = index(text, "국기")
	iscolor = index(text, "color box")
	isarmy = match(text, "^[육해공]군$")
	isnavy = match(text, "^navy$")
	isbirthdaykor = index(text, "출생일")
	isbirthdayeng = match(text, "[Bb]irth date")
	isbirthyearkor = index(text, "출생년")
	isbirthyeareng = match(text, "[Yy]ear")
	isdiedaykor = index(text, "사망일")
	isdiedayeng = match(text, "[Dd]eath date")
	isdate = index(text, "날짜")
	isurl = index(text, "URL")

	#태그만 제거할 위키문법 태그들
	isnowikistart = match(text, "^lt;nowiki&$")
	isnowikiend = match(text, "^lt;/nowiki&$")
	issubstart = match(text, "^lt;sub&$")
	issubend = match(text, "^lt;/sub&$")
	issupstart = match(text, "^lt;sup&$")
	issupend = match(text, "^lt;/sup&$")
	issmallstart = match(text, "^lt;small&$")
	issmallend = match(text, "^lt;/small&$")
	isbr = match(text, "^lt;(/)?[bB][rR]")
	isdivstart = match(text, "^lt;div&$")
	isdivend = match(text, "^lt;/div&$")
	isbigstart = match(text, "^lt;big&$")
	isbigend = match(text, "^lt;/big&$")
	isreference = index(text, "lt;references")

	#태그와 둘러싸인 내용을 함께 제거할 위키문법 태그들
	ishtmlmathstart = match(text, "^lt;math&$")
	ishtmlmathend = match(text, "^lt;/math&$")
	isrefgt = match(text, "^lt;[rR][eE][fF]&$") #대문자 태그도 존재
	isref = match(text, "^lt;[rR][eE][fF] $")
	isgallery = match(text, "^lt;gallery&$") #대문자 태그도 존재
	isgallery2 = match(text, "^lt;gallery $")
	istimeline = match(text, "^lt;timeline&$")
	iscomment = match(text, "^comment$")
	isid = match(text,"^id$")
	isparentid = match(text, "^parentid$")
	istime = match(text, "^timestamp$")
	isusername = match(text, "^username$")
	ismodel = match(text, "^model$")
	isformat = match(text, "^format$")
	issha = match(text, "^sha1$")
	isip = match(text, "^ip$")
	isdivlong = match(text, "^lt;div $")
	iscancel = match(text, "^lt;[!?]$")
	isspan = match(text, "^lt;span&$")
	isspan2 = match(text, "^lt;span $")
	isspan3 = match(text, "^lt;/span&$") # 하나로 합칠 수 있을거같은데

	#infobox 추출용
	isinfobox = match(text, "정보$")
	istitle = match(text, "^title$")

	#태그사이의 내용 일부를 남기는 유형
	if(isbirthyearkor != 0 || isbirthyeareng != 0 || isnavy != 0 || isurl != 0 || isdate != 0 || isdiedaykor != 0 || isdiedayeng != 0 || isbirthdaykor != 0 || isbirthdayeng != 0 || isarmy != 0 || iscolor != 0 || iscountryimage != 0 || isoldkorean != 0 || isvie != 0 || isangbr != 0 || isbra != 0 || ismath != 0 || isket != 0 || isipasmall != 0 || isipabig != 0 || islang != 0 || ishanja != 0 || iskorunicode != 0 || isunicode != 0 || isnorthkorean != 0 || isruby != 0 || iszh != 0 || isnysebig != 0 || isnysesmall != 0){
		foundtype = 1
		return foundtype
	}
	#태그만 제거하는 유형
	else if(isspan3 != 0 || isspan2 != 0 || isspan != 0 || isreference != 0 || isbigstart != 0 || isbigend != 0 || isdivlong != 0 || isdivstart != 0 || isdivend != 0 || issmallstart != 0 || issmallend != 0 || issupstart != 0 || issupend != 0 || isnowikistart != 0 || isnowikiend != 0 || issubstart != 0 || issubend != 0 || isbr != 0){
		foundtype = 2
		return foundtype
	}
	#태그 시작부터 끝까지 전부 제거하는 유형(단, &lt;~&gt;로 둘러싸인 태그)
	else if(isref != 0 || isrefgt != 0){
		foundtype = 3
		return foundtype
	}
	#태그 시작부터 끝까지 전부 제거하는 유형(단, <>로 둘러싸인 태그)
	else if(isip != 0 || iscomment != 0 || isid != 0 || isparentid != 0 || istime != 0 || isusername != 0 || ismodel != 0 || isformat != 0 || issha != 0){
		foundtype = 4
		return foundtype
	}
	#태그확인
	else if(istitle != 0){
		foundtype = 5
		return foundtype
	}
	#정보상자 시작 확인
	else if(isinfobox != 0){
		foundtype = 7
		return foundtype
	}
	#시작부터 끝까지 제거하되 인용이 아닌것
	else if(ishtmlmathstart != 0 || ishtmlmathend != 0 || iscancel != 0 || isgallery != 0 || isgallery2 != 0 || istimeline != 0){
		foundtype = 6
		return foundtype
	}
	#위에서 지정한 형식이 아닌 모든경우
	else{
		foundtype = 0
		return foundtype
	}
}
#인용태그와 내용 제거함수
function deleteref(inputtext,position,len){
	deleteposition = position
	deletecheck = position
	foundref = 0
	foundanotherclose = 0
	while(deletecheck <= len){
		if(inputtext ~ "lt;[rR][eE][fF]&" && textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2]textarr[deletecheck+3]textarr[deletecheck+4]textarr[deletecheck+5]textarr[deletecheck+6] ~ "/[rR][eE][fF]&gt"){
			foundref = 1
			break
		}
		else if(inputtext ~ "lt;[rR][eE][fF] " && textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2] == "gt;"){
			foundref = 1
			break
		}
		deletecheck++
	}

	if(foundref == 0){
		while(deleteposition <= len){
			delete textarr[deleteposition++]
		}
		unclosedref++
	}
	else if(foundref == 1){
		while(deleteposition <= len){
			if(inputtext ~ "lt;[rR][eE][fF]&" && textarr[deleteposition]textarr[deleteposition+1]textarr[deleteposition+2]textarr[deleteposition+3]textarr[deleteposition+4]textarr[deleteposition+5]textarr[deleteposition+6] ~ "/[rR][eE][fF]&gt"){
				for(i = 0;i < 8;i++){
					delete textarr[deleteposition++]
				}
				break
			}
			else if(inputtext ~ "lt;[rR][eE][fF] " && textarr[deleteposition]textarr[deleteposition+1]textarr[deleteposition+2]textarr[deleteposition+3] == "/&gt"){
				for(j = 0;j < 5;j++){
					delete textarr[deleteposition++]
				}
				break
			}
			else if(inputtext ~ "lt;[rR][eE][fF] " && textarr[deleteposition]textarr[deleteposition+1]textarr[deleteposition+2]textarr[deleteposition+3] ~ "[^/]&gt"){
				for(j = 0;j < 5;j++){
					delete textarr[deleteposition++]
				}
				checkanotherclose = deleteposition
				while(checkanotherclose <= len){
					if(textarr[checkanotherclose]textarr[checkanotherclose+1]textarr[checkanotherclose+2]textarr[checkanotherclose+3]textarr[checkanotherclose+4]textarr[checkanotherclose+5]textarr[checkanotherclose+6] ~ "/[rR][eE][fF]&gt"){
						foundanotherclose = 1
						break
					}
					else if(textarr[checkanotherclose]textarr[checkanotherclose+1]textarr[checkanotherclose+2]textarr[checkanotherclose+3]textarr[checkanotherclose+4]textarr[checkanotherclose+5]textarr[checkanotherclose+6]textarr[checkanotherclose+7] ~ "&lt;[rR][eE][fF]&"){
						checkanotherclose = deleteref("lt;ref&", checkanotherclose, len)
					}
					else if(textarr[checkanotherclose]textarr[checkanotherclose+1]textarr[checkanotherclose+2]textarr[checkanotherclose+3]textarr[checkanotherclose+4]textarr[checkanotherclose+5]textarr[checkanotherclose+6]textarr[checkanotherclose+7] ~ "&lt;[rR][eE][fF] "){
						checkanotherclose = deleteref("lt;ref ", checkanotherclose, len)
					}
					checkanotherclose++
				}
				if(foundanotherclose == 0){
					while(deleteposition <= len){
						delete textarr[deleteposition++]
					}
					unclosedref++
				}
				if(foundanotherclose == 1){
					while(deleteposition <= len){
						if(textarr[deleteposition]textarr[deleteposition+1]textarr[deleteposition+2]textarr[deleteposition+3]textarr[deleteposition+4]textarr[deleteposition+5]textarr[deleteposition+6] ~ "/[rR][eE][fF]&gt"){
							for(i = 0;i < 8;i++){
								delete textarr[deleteposition++]
							}
							break
						}
						delete textarr[deleteposition++]
					}
				}
				break
			}
			else if(deleteposition > position + 8 && textarr[deleteposition]textarr[deleteposition+1]textarr[deleteposition+2]textarr[deleteposition+3]textarr[deleteposition+4]textarr[deleteposition+5]textarr[deleteposition+6]textarr[deleteposition+7] ~ "&lt;[rR][eE][fF]&"){
				deleteposition = deleteref("lt;ref&", deleteposition, len)
			}
			else if(deleteposition > position + 8 && textarr[deleteposition]textarr[deleteposition+1]textarr[deleteposition+2]textarr[deleteposition+3]textarr[deleteposition+4]textarr[deleteposition+5]textarr[deleteposition+6]textarr[deleteposition+7] ~ "&lt;[rR][eE][fF] "){
				deleteposition = deleteref("lt;ref ", deleteposition, len)
			}
			delete textarr[deleteposition++]
		}
	}
	return deleteposition
}
#대괄호 범용 제거 함수
function delsqbrace(checkbracepos, len){
	if(textarr[checkbracepos] == "["){
		if(textarr[checkbracepos]textarr[checkbracepos+1] == "[["){
			delpos = checkbracepos
			checkpos = checkbracepos
			fudbar = 0
			fudClassification = 0
			fudfile = 0
			delete textarr[delpos++]
			delete textarr[delpos++]
			if(textarr[delpos]textarr[delpos+1] == "분류"){
				fudClassification = 1
			}
			if(textarr[delpos]textarr[delpos+1] == "파일"){
				fudfile = 1
			}
			while(checkpos <= len){
				if(textarr[checkpos] == "]"){
					break
				}
				
				else if(textarr[checkpos] == "|"){
					fudbar++
				}
				checkpos++
			}
			if(fudfile == 1 || fudClassification == 1){
				fudbar = 0
			}
			while(delpos <= len){
				if(textarr[delpos]textarr[delpos+1] == "]]"){
					break
				}
				else if(fudbar > 0 && textarr[delpos] == "|"){
					delete textarr[delpos++]
					fudbar--
					if(fudbar == 0){
						break
					}
				}
				else if(textarr[delpos] == "["){
					if(fudfile == 1){
						temp = 1
					}
					else{
						temp = 0
					}
					delpos = delsqbrace(delpos, len)
					fudfile = temp
				}
				if(textarr[delpos]textarr[delpos+1]textarr[delpos+2]textarr[delpos+3]textarr[delpos+4]textarr[delpos+5]textarr[delpos+6]textarr[delpos+7] ~ "&lt;[rR][eE][fF]&"){
					break
				}
				if(textarr[delpos]textarr[delpos+1]textarr[delpos+2]textarr[delpos+3]textarr[delpos+4]textarr[delpos+5]textarr[delpos+6]textarr[delpos+7] ~ "&lt;[rR][eE][fF] "){
					break
				}
				if(textarr[delpos]textarr[delpos+1] == "{{"){
					break
				}
				if(fudbar > 0 || fudfile != 0 || fudClassification != 0){
					delete textarr[delpos++]
				}
				else{
					delpos++
				}
			}
			findpos = delpos
			while(findpos <= len){
				if(textarr[findpos]textarr[findpos+1] == "]]"){
					break
				}
				findpos++
			}
			delete textarr[findpos++]
			delete textarr[findpos++]
		}
		else{
			delpos = checkbracepos
			fudbar = 0
			fudhttp = 0
			delete textarr[delpos++]
			if(textarr[delpos]textarr[delpos+1]textarr[delpos+2]textarr[delpos+3] == "http"){
				fudhttp = 1
			}
			while(delpos <= len){
				if(textarr[delpos] == "]"){
					delete textarr[delpos++]
					break
				}
				else if(textarr[delpos] == "["){
					delpos = delsqbrace(delpos, len)
				}
				if(textarr[delpos]textarr[delpos+1] == "{{"){
					break
				}
				if(fudhttp == 1 && textarr[delpos] == " "){
					delete textarr[delpos++]
					break
				}
				delete textarr[delpos++]
			}
		}
	}
	else if(textarr[checkbracepos] == "]"){
		delpos = checkbracepos
		delete textarr[delpos++]
		if(textarr[delpos] == " "){
			delete textarr[delpos++]
		}
	}
	return checkbracepos
}
#모든 문장을 글자단위로 쪼개서 문장의 끝까지 경우에따라 출력, 제거수행
{
	mainpos = 1 #문장 시작위치 초기화
	split($0, textarr, "") #문장 글자단위 분해
	len = length($0) #문장 전체 길이
	if(foundunclosed == 1){
		if(index($0, "&lt;/gallery&gt;") != 0){
			deletepos = mainpos
			while(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] != ";/gall"){
				if(deletepos > len){
					break
				}
				delete textarr[deletepos++]
			}
			for(i = 0;i < 13;i++){
					delete textarr[deletepos++]
				}
			foundunclosed = 0
			mainpos = deletepos
		}
		else if(index($0, "&lt;/timeline&gt;") != 0){
			deletepos = mainpos
			while(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] != "/timel"){
				if(deletepos > len){
					break
				}
				delete textarr[deletepos++]
			}
			for(i = 0;i < 13;i++){
					delete textarr[deletepos++]
				}
			foundunclosed = 0
			mainpos = deletepos
		}
		else if(index($0, "--&gt;") != 0){
			deletepos = mainpos
			while(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] != "--&gt;"){
				if(deletepos > len){
					break
				}
				delete textarr[deletepos++]
			}
			for(i = 0;i < 6;i++){
					delete textarr[deletepos++]
				}
			foundunclosed = 0
			mainpos = deletepos
		}
		else if(index($0, "&lt;/span&gt;") != 0){
			deletepos = mainpos
			while(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] != "/span&"){
				if(deletepos > len){
					break
				}
				delete textarr[deletepos++]
			}
			for(i = 0;i < 9;i++){
					delete textarr[deletepos++]
				}
			foundunclosed = 0
			mainpos = deletepos
		}
		else if(index($0, "&lt;/math&gt;") != 0){
			deletepos = mainpos
			while(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] != "/math&"){
				if(deletepos > len){
					break
				}
				delete textarr[deletepos++]
			}
			for(i = 0;i < 9;i++){
					delete textarr[deletepos++]
				}
			foundunclosed = 0
			mainpos = deletepos
		}
		else{
			next
		}
	}
	if(unclosedref > 0){
		if(match($0, "&lt;/[rR][eE][fF]&gt;") != 0){
			deleteunclosedref = 1
			while(deleteunclosedref <= len){
				if(textarr[deleteunclosedref]textarr[deleteunclosedref+1]textarr[deleteunclosedref+2]textarr[deleteunclosedref+3]textarr[deleteunclosedref+4]textarr[deleteunclosedref+5]textarr[deleteunclosedref+6] ~ "/[rR][eE][fF]&gt"){
					for(i = 0;i < 8;i++){
						delete textarr[deleteunclosedref++]
					}
					break
				}
				delete textarr[deleteunclosedref++]
			}
			unclosedref--
		}
		else{
			next
		}
	}
	while(mainpos <= len){
		if(textarr[mainpos] == "\\"){
			textarr[mainpos] = "\\\\"
		}
		#[]가 발견되면 제거함수 호출
		if(textarr[mainpos] == "[" || textarr[mainpos] == "]"){
			deletepos = delsqbrace(mainpos, len)
		}
		#<가 발견되면 문장전체를 삭제해야할 태그인지 확인후 맞으면 삭제
		if(textarr[mainpos] == "<"){
			wikitext = ""
			firstclose = mainpos + 1
			while(textarr[firstclose] != ">"){
				wikitext = wikitext textarr[firstclose++]
			}
			checkedtype = checktype(wikitext)
			if(checkedtype == 4){
				next
			}
			if(checkedtype == 5){
				title = ""
				firstclose++
				while(textarr[firstclose] != "<"){
					title = title textarr[firstclose++]
					if(firstclose > len){
						break
					}
				}
				foundinfobox = 0
				unclosed = 0
				isfirst = 1
			}
		}
		#&lt가 발견됐을때, 삭제처리를 해야하는 태그를 포함하는지 검사후 맞으면 삭제함수 호출
		else if(textarr[mainpos]textarr[mainpos+1]textarr[mainpos+2] == "&lt"){
			htmltext = ""
			firstand = mainpos + 1
			while(firstand <= len){
				if(textarr[firstand] == "&" || textarr[firstand] == " " || textarr[firstand] == "!" || textarr[firstand] == "?"){
					break
				}
				htmltext = htmltext textarr[firstand]
				firstand++
			}
			htmltext = htmltext textarr[firstand]
			checkedtype = checktype(htmltext)
			if(checkedtype == 2){
				deletepos = mainpos
				while(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2] != "gt;"){
					if(deletepos > len){
						break
					}
					delete textarr[deletepos++]
				}
				delete textarr[deletepos++]
				delete textarr[deletepos++]
				delete textarr[deletepos++]
			}
			else if(checkedtype == 3){
				deletepos = deleteref(htmltext, mainpos, len)
			}
			else if(checkedtype == 6){
				deletepos = mainpos
				deletecheck = mainpos
				foundclose = 0
				while(deletecheck <= len){
					if(textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2]textarr[deletecheck+3]textarr[deletecheck+4]textarr[deletecheck+5]textarr[deletecheck+6] == ";/galle"){
						foundclose = 1
						break
					}
					if(textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2]textarr[deletecheck+3]textarr[deletecheck+4]textarr[deletecheck+5]textarr[deletecheck+6] == ";/timel"){
						foundclose = 1
						break
					}
					if(textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2]textarr[deletecheck+3]textarr[deletecheck+4]textarr[deletecheck+5] == "--&gt;"){
						foundclose = 1
						break
					}
					if(textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2]textarr[deletecheck+3]textarr[deletecheck+4]textarr[deletecheck+5] == ";/span"){
						foundclose = 1
						break
					}
					if(textarr[deletecheck]textarr[deletecheck+1]textarr[deletecheck+2]textarr[deletecheck+3]textarr[deletecheck+4]textarr[deletecheck+5] == ";/math"){
						foundclose = 1
						break
					}
					deletecheck++
				}
				if(foundclose == 0){
					while(deletepos <= len){
						delete textarr[deletepos++]
					}
					foundunclosed = 1
				}
				else if(foundclose == 1){
					while(deletepos <= len){
						if(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5]textarr[deletepos+6] == "/galler"){
							for(i = 0;i < 13;i++){
								delete textarr[deletepos++]
							}
							break
						}
						if(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] == "--&gt;"){
							for(i = 0;i < 6;i++){
								delete textarr[deletepos++]
							}
							break
						}
						if(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] == ";/span"){
							for(i = 0;i < 10;i++){
								delete textarr[deletepos++]
							}
							break
						}
						if(textarr[deletepos]textarr[deletepos+1]textarr[deletepos+2]textarr[deletepos+3]textarr[deletepos+4]textarr[deletepos+5] == ";/math"){
							for(i = 0;i < 10;i++){
								delete textarr[deletepos++]
							}
							break
						}
						delete textarr[deletepos++]
					}
				}
			}
		}
		#}}가 발견됐을때, 만약 이전에 중괄호를 닫지 않았다면 삭제 수행
		else if(textarr[mainpos]textarr[mainpos+1] == "}}"){
			if(unclosed > 0){
				deletepos = 1
				check = 1
				foundbar = 0
				while(check <= len){
					if(textarr[check] == "}" && textarr[check+1] == "}"){
						unclosed--
					}
					if(textarr[check] == "{" && textarr[check+1] == "{"){
						unclosed--
					}
					if(textarr[check] == "|"){
						if(textarr[check+1]textarr[check+2] == "}}"){
							delete textarr[check]
						}
						else{
							foundbar++
						}
					}
					if(unclosed == 0){
							break
						}
					check++
				}

				if(foundbar != 0){
					while(foundbar > 0){
						if(textarr[deletepos] == "|") {
							foundbar -= 1
							if(foundbar == 0){
								break
							}
						}
						delete textarr[deletepos++]
					}
					delete textarr[deletepos++]
				}
				while(textarr[deletepos]textarr[deletepos+1] != "}}"){
					if(isipabig != 0 || isipasmall != 0){
						if(textarr[deletepos] == "[" || textarr[deletepos] == "]"){
							delete textarr[deletepos]
						}
					}
					if(deletepos > len){
						break
					}
					deletepos++
				}
				if(deletepos <= len){
					delete textarr[deletepos]
					delete textarr[deletepos+1]
				}
			}
		}
		#{{를 찾았을때, }}나 새로운 {{를 만날때까지 |를 찾고, 마지막 |까지 모든 텍스트를 삭제한뒤 }}를 삭제
		#만약 }}를 찾지 못했다면 unclosed를 1 증가
		else if(textarr[mainpos]textarr[mainpos+1] == "{{"){
			text = ""
			firstbarpos = mainpos + 2
			while(firstbarpos <= len){
				if(textarr[firstbarpos] == "|"){
					break
				}
				if(textarr[firstbarpos]textarr[firstbarpos+1] == "}}"){
					break
				}
				if(textarr[firstbarpos]textarr[firstbarpos+1]textarr[firstbarpos+2]textarr[firstbarpos+3]textarr[firstbarpos+4]textarr[firstbarpos+5]textarr[firstbarpos+6] ~ "lt;[rR][eE][fF]&"){
					firstbarpos = deleteref("lt;ref&", firstbarpos, len)
				}
				if(textarr[firstbarpos]textarr[firstbarpos+1]textarr[firstbarpos+2]textarr[firstbarpos+3]textarr[firstbarpos+4]textarr[firstbarpos+5]textarr[firstbarpos+6] ~ "lt;[rR][eE][fF] "){
					firstbarpos = deleteref("lt;ref ", firstbarpos, len)
				}
				text = text textarr[firstbarpos]
				firstbarpos++
			}
			checkedtype = checktype(text)
			if(checkedtype == 7){
				printpos = mainpos
				foundinfobox = 1
				opened = 0
			}
			if(checkedtype == 1){
				deletepos = mainpos
				check = mainpos
				foundbar = 0
				while(check <= len){
					if(textarr[check] == "}" && textarr[check+1] == "}"){
						break
					}
					if(check > mainpos + 2 && textarr[check] == "{" && textarr[check+1] == "{"){
						break
					}
					if(textarr[check] == "|"){
						if(textarr[check+1]textarr[check+2] == "}}"){
							delete textarr[check]
						}
						else{
							foundbar++
						}
					}
					check++
				}
				if(foundbar != 0){
					while(foundbar > 0){
						if(textarr[deletepos] == "|") {
							foundbar -= 1
							if(isbirthdaykor != 0 || isbirthdayeng != 0 || isdate != 0 || isdiedaykor != 0 || isdiedayeng != 0){
								foundbar = 0
							}
							if(foundbar == 0){
								break
							}
						}
						delete textarr[deletepos++]
					}
					delete textarr[deletepos++]
					if(iszh != 0 || isvie != 0){
						checkequal = deletepos
						while(checkequal <= len){
							if(textarr[checkequal] == "="){
								break
							}
							checkequal++
						}
						if(checkequal < len){
							while(deletepos <= checkequal){
								delete textarr[deletepos++]
							}
						}
					}
				
					while(textarr[deletepos]textarr[deletepos+1] != "}}"){
						if(isipabig != 0 || isipasmall != 0){
							if(textarr[deletepos] == "[" || textarr[deletepos] == "]"){
								delete textarr[deletepos]
							}
						}
						if(deletepos > len){
							unclosed++
							break
						}
						deletepos++
					}
					if(deletepos <= len){
						delete textarr[deletepos]
						delete textarr[deletepos+1]
					}
				}
			}
		}
		#문장배열에서 남은 텍스트들 출력, 삭제처리가 된 부분은 출력이 되지않음
		plainstring = plainstring textarr[mainpos]
		mainpos++
	}
	print plainstring > "result.xml"
	plainstring = ""
	if(foundinfobox == 1 && isfirst == 1){
		if($0 ~ "^'''[^']+'''[(].+"){
			foundinfobox = 0
			next
		}
		else if($0 ~ "==[^=]+=="){
			foundinfobox = 0
			next
		}
		else if(title ~ "파일:[^=]+"){
			foundinfobox = 0
			next
		}
		else if(title ~ "틀:[^=]+"){
			foundinfobox = 0
			next
		}
		while(printpos <= len){
			if(textarr[printpos]textarr[printpos+1]textarr[printpos+2]textarr[printpos+3]textarr[printpos+4]textarr[printpos+5]textarr[printpos+6] == "</text>"){
				foundinfobox = 0
				break
			}
			else if(textarr[printpos] == "{"){
				opened++
				if(opened == 1){
					print "= "title" =" > "all_docs_infobox.txt"
					delinfohead = printpos
					while(textarr[delinfohead]textarr[delinfohead+1] != "정보"){
						delete textarr[delinfohead++]
					}
					delete textarr[delinfohead++]
					delete textarr[delinfohead++]
				}
				else if(opened > 1 && textarr[printpos+1] == "{"){
					delpos = printpos
					checkbar = printpos
					barnum = 0
					while(checkbar <= len){
						if(textarr[checkbar] == "|"){
							barnum++
						}
						else if(textarr[checkbar]textarr[checkbar+1] == "}}"){
							break
						}
						else if(textarr[checkbar]textarr[checkbar+1] == "{{"){
							break
						}
						checkbar++
					}
					while(delpos <= len){
						if(barnum == 0){
							delete textarr[delpos++]
							delete textarr[delpos++]
							break
						}
						if(textarr[delpos]textarr[delpos+1] == "}}"){
							break
						}
						if(delpos > printpos + 2 && textarr[delpos]textarr[delpos+1] == "{{"){
							break
						}
						delete textarr[delpos++]
					}
				}
			}
			else if(textarr[printpos] == "}"){
				opened--
				if(opened == 0){
					foundinfobox = 0
					isfirst = 0
					break
				}
				else if(opened >= 1 && textarr[printpos+1] == "}"){
					delpos = printpos
					delete textarr[delpos++]
					delete textarr[delpos++]
				}
			}
			else if(textarr[printpos]textarr[printpos+1]textarr[printpos+2]textarr[printpos+3] == "&lt;"){
				delpos = printpos
				while(delpos <= len){
					if(textarr[printpos]textarr[printpos+1]textarr[printpos+2] == "gt;"){
						delete textarr[delpos++]
						delete textarr[delpos++]
						delete textarr[delpos++]
						break
					}
					delete textarr[delpos++]
				}
			}
			if(textarr[printpos] == "&"){
				delete textarr[printpos]
			}
			if(textarr[printpos]textarr[printpos+1]textarr[printpos+2]textarr[printpos+3]textarr[printpos+4] == "quot;"){
				delpos = printpos
				delete textarr[delpos++]
				delete textarr[delpos++]
				delete textarr[delpos++]
				delete textarr[delpos++]
				textarr[delpos] = "\""
			}
			if(textarr[printpos]textarr[printpos+1]textarr[printpos+2]textarr[printpos+3]textarr[printpos+4]textarr[printpos+5] == "minus;"){
				delpos = printpos
				delete textarr[delpos++]
				delete textarr[delpos++]
				delete textarr[delpos++]
				delete textarr[delpos++]
				delete textarr[delpos++]
				textarr[delpos] = "-"
			}
			if(textarr[printpos]textarr[printpos+1]textarr[printpos+2]textarr[printpos+3] == "amp;"){
				delpos = printpos
				delete textarr[delpos++]
				delete textarr[delpos++]
				delete textarr[delpos++]
				textarr[delpos] = "&"
			}
			if(delbar == 0 && textarr[printpos] == "|"){
				delete textarr[printpos]
				delbar = 1
			}
			if(textarr[printpos] == "'"){
				delete textarr[printpos]
			}
			string = string textarr[printpos++]
		}
		startindex = match(string, "[^ ]")
		string = substr(string, startindex)
		print string > "infobox/"title"_infobox.txt"
		string = ""
		printpos = 1
		delbar = 0
	}
	delete textarr
}