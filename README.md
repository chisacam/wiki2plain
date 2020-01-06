# Wiki2plain

본 문서는 wikipedia dump 파일에서 plaintext를 추출하기 위한 코드과 이에 관한 설명을 기술합니다.



작성자 : 임종원(dladsds123@gmail.com)

작성일 : 2019.05.09.

------

### 1. 개요

wikipedia는 다수의 사람들이 참여하여 함께 작성하는 인터넷 백과사전이고, Wikipedia dump는 wikipedia의 문서들을 모두 합쳐 하나의 xml파일로 저장한것 입니다. 

해당 xml 파일에는 실제 문서 내용 외에 url, HTML 태그 등이 함께 작성되어 있으며, 본 프로그램은 이 xml파일에서 plaintext, infobox를 추출하고 이를 바탕으로 JSON을 생성하는 작업을 수행합니다.



#### 1-1. 제거 가능한 문법

- 중괄호로 둘러싸인 태그(lang, unicode, ruby, zh, IPA 등)
- 대괄호로 둘러싸인 텍스트
- < 와 >로 둘러싸인 태그들(nowiki, small, br, divstart, ref, math 등)
- &amp, &minus 등의 위키태그가 아닌 html 태그

#### 1-2. 프로그램 결과물

- 전체 문서의 plaintext
- 전체 문서의 infobox
- 전체 문서의 초록 plaintext
- infobox와 초록을 합친 JSON

#### 1-3. 시스템 요구사항

**gawk 최신버전(2019년 5월 9일 기준 gawk버전 4.2.1)** 이 설치된 리눅스 또는 유닉스.



#### 1-4. 통계

본 프로그램을 사용했을때의 결과 통계는 **2019년 4월 1일** 기준으로 아래와 같습니다.

| 분류                       | 해당 개수  |
| :------------------------- | ---------- |
| 총 문서 수                 | 45만 705개 |
| Infobox가 존재하는 문서 수 | 20만 839개 |

| 분류                                | 해당 개수    |
| :---------------------------------- | ------------ |
| 총 문장 수(문서 제목, 항목 등 포함) | 816만 5900줄 |
| 총 문장 수(문서 제목, 항목 등 제외) | 606만 6063줄 |

| 분류                                                    | 해당 개수 |
| :------------------------------------------------------ | --------- |
| 총 infobox 항목 수(예시:출생일, 종교, sponsor, year 등) | 11317개   |
| 총 infobox 한글 항목 수(예시:출생일, 종교, 기호 등)     | 6461개    |
| 태그 미처리(미제거) 항목 수                             | 489개     |



### 2. 사용방법

1. 먼저 https://dumps.wikimedia.org/kowiki/ 에 접속하여 최신 일자 링크를 클릭합니다.

2. partial dump 항목에서 kowiki-(날짜)-pages-articles-multistream.xml.bz2 를 다운받습니다.
    만약 2019년 4월 1일의 덤프 라면 (날짜) 자리에 20190401이 들어가있습니다.

3. 다운이 완료되면 압축을 해제하고, 터미널을 실행합니다.

4. `git clone https://github.com/chisacam/wiki2plain.git` 명령어를 입력하면 소스코드가 **(현재 디렉토리)/wiki2plain** 안에 다운로드 됩니다.

5. 디렉토리 구조에 따라 dump xml파일을 이동하고, 터미널에서 `wikipedia_refinement.sh`를 다음 예시를 참고하여 실행 합니다.

#### 2-1. 실행 예시

***주의 : 본 프로그램은 gawk 최신버전을 필요로 합니다. 만약 설치되어 있지 않다면 gawk_install옵션에 -i를 선택하여 설치하거나 직접 설치 해주셔야 합니다. macOS의 경우 brew 패키지 관리자를 먼저 설치하고 brew로 gawk를 설치하도록 하고 있습니다.***

------

> ./wikipedia_refinement.sh [gawk_install] [infobox] [abstract] [Json] [input_file]

(예시) `./wikipedia_refinement.sh -s -y -y -y kowiki-20190401.xml`

- 첫 번째 인자 [gawk_install]

    -i : gawk 설치

    -u : apt 또는 brew 업데이트

    -s : 스킵

- 두 번째 인자 [infobox]

    -y : infobox 통합 파일로 추출 (출력되는 결과물은 1개의 infobox 통합 파일)

    -n : infobox 개별 파일로 추출 (출력되는 결과물은 infobox가 있는 위키 문서 개수만큼의 infobox 파일)

- 세 번째 인자 [abstract]

    -y : 초록 통합파일로 추출 (출력되는 결과물은 1개의 abstract 통합 파일)

    -n : 초록 개별파일로 추출 (출력되는 결과물은 위키 문서 개수만큼의 abstract 파일)

    -s : 초록 추출 스킵

- 네 번째 인자 [Json]

    -y : JSON 파일 생성

    -n : JSON 파일 생성안함

- 다섯 번째 인자 [input_file]

    처리할 wikidump 파일 이름

------



#### 2-2. wiki2text 컴파일방법

만약 wiki2text 사용이 불가능한 상태(손상 등)라면, wiki2text_source 디렉토리에 있는 파일을 이용하여 컴파일해서 다시 정상적인 wiki2text 실행 파일을 얻을 수 있습니다. 본 문서에서는 유닉스, 리눅스 환경을 기준으로 설명하겠습니다.

1. 터미널을 열고, mscOS라면 `brew install nim` 명령을, 데비안이나 우분투라면 `apt-get install nim` 명령을 실행하여 nim을 설치합니다.
2. 설치가 완료되면 `cd (Wikipedia_refinement 저장경로)/wiki2text_source` 명령으로 해당 디렉토리에 이동합니다.
3. `make` 명령을 실행하면 같은 위치에 wiki2text가 생성됩니다.



### 3. 디렉토리 구조

모든 파일은 다음과 같은 구조로 한 디렉토리 내에 존재해야 합니다.

------

Wikipedia_refinement/

- abstract_dif.awk

- abstract.awk

- makejson.awk

- Preprocessing.awk

- Preprocessing_dif.awk

- wiki2text

- wiki2text_source/

   * Makefile

   * wiki2text.num

   * wiki2text.nimble

- wikipedia_refinement.sh

- kowiki-(날짜)-pages-articles-multistream.xml

------



프로그램을 실행했을때, 사용 방법에서 소개한 예시대로 실행했다고 가정하면 wikipedia_refinement.sh가 있는 폴더(Wikipedia_refinement/)에 다음과같은 이름의 파일이 생성됩니다.

- plaintext.txt -> **모든 문서의 모든 plaintext가 출력된 파일**
- all_docs_abstract.txt -> **모든 문서의 초록만 plaintext로 출력된 파일**
- all_docs_infobox.txt -> **모든 문서의 infobox만 추출된 파일**
- result.json -> **모든 문서의 초록과 infobox로 구성된 JSON파일**



### 4. 프로그램 결과물

#### 4-1. 입력 포맷

> {{국가원수 정보

> | 이름 = 제임스 얼 카터 주니어

> | 원래 이름 = {{lang|en|James Earl Carter Jr.}}

> | 그림 = JimmyCarterPortrait2.jpg

> | 크기 = 300px

> | 국가 = 미국

> | 대수 = 39

> | 취임일 = [[1977년]] [[1월 20일]]

> | 퇴임일 = [[1981년]] [[1월 20일]]

> | 부통령 = [[월터 먼데일]]

> | 전임 = 제럴드 포드

> | 전임대수 = 38

> | 후임 = 로널드 레이건

> | 후임대수 = 40

> | 국적 = [[미국]]

> | 출생일 = {{출생일|1924|10|1}}

> | 출생지 = [[미국]] [[조지아주]] [[플레인스 (조지아)|플레인스]]

> | 사망지 =

> | 정당 = [[민주당 (미국)|민주당]]

> | 학력 = [[조지아 남서 주립대학교]]&lt;br /&gt;[[조지아 공과대학교]]&lt;br /&gt;[[유니언 칼리지]]&lt;br /&gt;[[미국 해군사관학교]]

> | 종교 = [[침례교]]

> | 배우자 = [[로잘린 카터]]

> | 자녀 = 슬하 3남 1녀

> | 서명 = Jimmy Carter Signature-2.svg

> | 웹사이트 = http://www.cartercenter.org/index.html

> | 서훈= {{노벨상 딱지|평화상|2002}}

> }}

> '''제임스 얼 &quot;지미&quot; 카터 주니어'''({{llang|en|James Earl &quot;Jimmy&quot; Carter, Jr.}}, [[1924년]] [[10월 1일]] ~ )는 [[민주당 (미국)|민주당]] 출신 [[미국]] 39번째 대통령 ([[1977년]] ~ [[1981년]])이다.

> == 생애 ==

> === 어린 시절 ===

> 지미 카터는 [[조지아주]] 섬터 카운티 플레인스 마을에서 태어났다. [[조지아 공과대학교]]를 졸업하였다. 그 후 해군에 들어가 전함·원자력·잠수함의 승무원으로 일하였다. [[1953년]] [[미국 해군]] [[대위]]로 예편하였고 이후 땅콩·면화 등을 가꿔 많은 돈을 벌었다. 그의 별명이 &quot;땅콩 농부&quot; (Peanut Farmer)로 알려졌다.

> === 정계 입문 ===

> [[1962년]] 조지아 주 상원 의원 선거에서 낙선하나 그 선거가 부정선거 였음을 입증하게 되어 당선되고, [[1966년]] 조지아 주 지사 선거에 낙선하지만 [[1970년]] 조지아 주 지사를 역임했다. 대통령이 되기 전 [[조지아주]] 상원의원을 두번 연임했으며, 1971년부터 1975년까지 조지아 지사로 근무했다.&lt;ref&gt;{{웹 인용| url=http://www.georgiaencyclopedia.org/nge/Article.jsp?id=h-676 | 제목=Jimmy Carter | 출판사=Georgia Humanities Council |저자=조지아 주 백과사전}}&lt;/ref&gt; 조지아 주지사로 지내면서, [[아프리카계 미국인|미국에 사는 흑인]] 등용법을 내세웠다.

> == 대통령 재임 ==

> [[파일:Inauguration of Jimmy Carter.jpg|섬네일|왼쪽|380px|취임식을 올리는 카터]]

> [[1976년]] 대통령 선거에 민주당 후보로 출마하여 도덕주의 정책으로 내세워, [[제럴드 포드|포드]]를 누르고 당선되었다.

> 카터 대통령은 에너지 개발을 촉구했으나 [[공화당 (미국)|공화당]]의 반대로 무산되었다.&lt;ref&gt;[http://academic.naver.com/view.nhn?doc_id=9835341 카터 에너지 계획의 내용과 전망 ]&lt;/ref&gt;&lt;ref&gt;[http://academic.naver.com/view.nhn?doc_id=9837242 카터미대통령 의 에너지 계획 (카터美大統領 의 에너지 計劃) ]&lt;/ref&gt;&lt;ref&gt;[http://academic.naver.com/view.nhn?doc_id=9887138 ... 에너지대책 과 평가]&lt;/ref&gt;&lt;ref&gt;[http://academic.naver.com/view.nhn?doc_id=9887100 카터 대통령의 연설]&lt;/ref&gt;

>

> (후략)



#### 4-2. 출력 파일

##### 4-2-1. infobox

> = 지미 카터 =

>

> 이름 = 제임스 얼 카터 주니어

> 원래 이름 = James Earl Carter Jr.

> 그림 = JimmyCarterPortrait2.jpg

> 크기 = 300px

> 국가 = 미국

> 대수 = 39

> 취임일 = 1977년 1월 20일

> 퇴임일 = 1981년 1월 20일

> 부통령 = 월터 먼데일

> 전임 = 제럴드 포드

> 전임대수 = 38

> 후임 = 로널드 레이건

> 후임대수 = 40

> 국적 = 미국

> 출생일 = 1924|10|1

> 출생지 = 미국 조지아주 플레인스

> 사망지 =

> 정당 = 민주당

> 학력 = 조지아 남서 주립대학교조지아 공과대학교유니언 칼리지미국 해군사관학교

> 종교 = 침례교

> 배우자 = 로잘린 카터

> 자녀 = 슬하 3남 1녀

> 서명 = Jimmy Carter Signature-2.svg

> 웹사이트 = http://www.cartercenter.org/index.html

> 서훈= 노벨상 딱지|평화상|2002

##### 4-2-2. Plaintext

> = 지미 카터 =

>

> 제임스 얼 "지미" 카터 주니어(James Earl "Jimmy" Carter, Jr., 1924년 10월 1일 ~ )는 민주당 출신 미국 39번째 대통령 (1977년 ~ 1981년)이다.

> == 생애 ==

> === 어린 시절 ===

> 지미 카터는 조지아주 섬터 카운티 플레인스 마을에서 태어났다. 조지아 공과대학교를 졸업하였다. 그 후 해군에 들어가 전함·원자력·잠수함의 승무원으로 일하였다. 1953년 미국 해군 대위로 예편하였고 이후 땅콩·면화 등을 가꿔 많은 돈을 벌었다. 그의 별명이 "땅콩 농부" (Peanut Farmer)로 알려졌다.

> === 정계 입문 ===

> 1962년 조지아 주 상원 의원 선거에서 낙선하나 그 선거가 부정선거 였음을 입증하게 되어 당선되고, 1966년 조지아 주 지사 선거에 낙선하지만 1970년 조지아 주 지사를 역임했다. 대통령이 되기 전 조지아주 상원의원을 두번 연임했으며, 1971년부터 1975년까지 조지아 지사로 근무했다. 조지아 주지사로 지내면서, 미국에 사는 흑인 등용법을 내세웠다.

> == 대통령 재임 ==

> 1976년 대통령 선거에 민주당 후보로 출마하여 도덕주의 정책으로 내세워, 포드를 누르고 당선되었다.

> 카터 대통령은 에너지 개발을 촉구했으나 공화당의 반대로 무산되었다.

>

> (후략)

##### 4-2-3. Abstract

> = 지미 카터 =

>

> 제임스 얼 "지미" 카터 주니어(James Earl "Jimmy" Carter, Jr., 1924년 10월 1일 ~ )는 민주당 출신 미국 39번째 대통령 (1977년 ~ 1981년)이다.

##### 4-2-4. JSON

```json
{
    "wikipedia":[
        {
            "docname":"지미 카터",
            "abstract":[
                "제임스 얼 \"지미\" 카터 주니어(James Earl \"Jimmy\" Carter, Jr., 1924년 10월 1일 ~ )는 민주당 출신 미국 39번째 대통령 (1977년 ~ 1981년)이다."
            ],
            "inform":{
                "서명":"Jimmy Carter Signature-2.svg",
                "부통령":"월터 먼데일",
                "자녀":"슬하 3남 1녀",
                "학력":"조지아 남서 주립대학교조지아 공과대학교유니언 칼리지미국 해군사관학교",
                "국가":"미국",
                "이름":"제임스 얼 카터 주니어",
                "정당":"민주당",
                "후임대수":"40",
                "취임일":"1977년 1월 20일",
                "웹사이트":"http://www.cartercenter.org/index.html",
                "후임":"로널드 레이건",
                "종교":"침례교",
                "전임":"제럴드 포드",
                "크기":"300px",
              	"출생일":"1924|10|1",
                "그림":"JimmyCarterPortrait2.jpg",
                "배우자":"로잘린 카터",
                "출생지":"미국 조지아주 플레인스",
                "국적":"미국",
                "퇴임일":"1981년 1월 20일",
                "전임대수":"38",
                "대수":"39",
                "원래이름":"James Earl Carter Jr."
            }
        },
      .
      .
      .
```



### 5. 참조

[1] wiki2text 프로그램 출처 : https://github.com/rspeer/wiki2text
