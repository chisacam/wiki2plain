BEGIN{
	docnumber_ifno = 0
	docnumber_abst = 0
	infoline = 1
	abstline = 1
}
FILENAME == ARGV[1]{
	if($0 ~ "^=[^=]+=$"){
        split($0, temp2, " ")
		titlelen2 = length(temp2)
		infotitle = temp2[2]
		for(j = 3;j < titlelen2;j++){
			infotitle = infotitle" "temp2[j]
		}
		gsub("\\", "\\\\", infotitle)
		gsub("&", "", infotitle)
		gsub("amp;", "", infotitle)
		gsub("&quot;", "\\\"", infotitle)
		infoboxarr[infotitle] = 1
    }
	if($0 ~ "[^=]+=.[^=]+"){
		left = substr($0, 1, index($0, "=") - 1)
		if(index(left, "STR+") != 0){
			next
		}
		gsub(" ", "", left)
		gsub("\"", "\\\"", left)
		gsub("\t", "", left)
		right = substr($0, index($0, "=") + 1)
		gsub("\"", "\\\"", right)
		gsub("\t", "", right)
		startindex = match(right, "[^ ]")
		right = substr(right, startindex)
		infoboxtextarr[infotitle][left] = "\t\t\t\t\"" left "\":\"" right "\""
	}
}
FILENAME == ARGV[2]{
	if($0 ~ "^=[^=]+=$"){
		split($0, temp, " ")
		titlelen = length(temp)
		absttitle = temp[2]
		for(j = 3;j < titlelen;j++){
			absttitle = absttitle" "temp[j]
		}
		gsub("\"", "\\\"", absttitle)
		gsub("\\", "\\\\", absttitle)
		abstractarr[++docnumber_abst] = absttitle
		abstline = 1
	}
	else{
		abstracttextarr[docnumber_abst][abstline++] = $0
	}
}
END{
	print "{" > "result.json"
	print "\t\"wikipedia\":[" > "result.json"
	len = length(abstractarr)
	for(i = 1;i <= len;i++){
		abstractlen = length(abstracttextarr[i]) - 1
		print "\t\t{" > "result.json"

		# 문서제목 출력
		print "\t\t\t\"docname\":\""abstractarr[i]"\"," > "result.json" 

		# 초록 출력
		print "\t\t\t\"abstract\":[" > "result.json" 
		for(k = 1;k < abstractlen;k++){
			startindex = match(abstracttextarr[i][k], "[^ ]")
			abstracttext = substr(abstracttextarr[i][k], startindex)
			gsub("\"", "\\\"", abstracttext)
			gsub("\\", "", abstracttext)
			gsub("]", "", abstracttext)
			print "\t\t\t\t\""abstracttext"\"," > "result.json"
		}
		if(abstractlen == -1){
			print "\t\t\t]," > "result.json"
		}
		else{
			startindex = match(abstracttextarr[i][k], "[^ ]")
			abstracttext = substr(abstracttextarr[i][k], startindex)
			gsub("\"", "\\\"", abstracttext)
			gsub("\\", "", abstracttext)
			gsub("]", "", abstracttext)
			print "\t\t\t\t\""abstracttext"\"" > "result.json"
			print "\t\t\t]," > "result.json"
		}
		
		# 정보상자 출력
		print "\t\t\t\"inform\":{" > "result.json"
		if(abstractarr[i] in infoboxarr){
			infoboxlen = length(infoboxtextarr[abstractarr[i]])
			if(infoboxlen == 0){
				print "\t\t\t}" > "result.json"
				if(i == len){
					print "\t\t}" > "result.json"
					break
				}
				print "\t\t}," > "result.json"
				continue
			}
			for(printinfo in infoboxtextarr[abstractarr[i]]){
				infoboxtext = infoboxtextarr[abstractarr[i]][printinfo]
				infoboxlen--
				if(infoboxlen == 0){
					print infoboxtext > "result.json"
				}
				else{
					print infoboxtext"," > "result.json"
				}
			}
		}
		print "\t\t\t}" > "result.json"
		if(i == len){
			print "\t\t}" > "result.json"
			break
		}
		print "\t\t}," > "result.json"
	}
	print "\t]" > "result.json"
	print "}" > "result.json"
}