BEGIN{
	system("rm -rf extracted")
	system("mkdir extracted")
	docname = "all_docs_abstract.txt"
	isabstract = 0
}
/^=[^=]+=$/{
	isabstract = 1
	print "" > docname
	print $0 > docname
	split($0, temp, " ")
	titlelen = length(temp)
	title = temp[2]
	for(j = 3;j < titlelen;j++){
			title = title" "temp[j]
		}
	gsub("/", "", title)
	next
}
/==[^=]+==/{
	isabstract = 0
}
{
	if(isabstract == 1){
		if($0 == "" || $0 == " ") next
		gsub("}}", "", $0)
		text = ""
		for(printtest = 1;printtest <= NF;printtest++){
			text = text" "$printtest
			if($printtest ~ "[가-힣]+[.?]$"){
#				print text > docname
				print text > "extracted/" title "_abstract" ".txt"
				text = ""
			}
		}
#		if(text != "" && text != " " && text != " .") print text > docname
		if(text != "" && text != " " && text != " .") print text > "extracted/" title "_abstract" ".txt"
	}
}