---
title: "논문 리뷰: Through the Authentication Maze: Detecting Authentication Bypass Vulnerabilities in Firmware Binaries"
date: 2026-11-09 05:54:35 +0900
categories: ["Paper Review"]
tags: ["Paper Review"]
math: true
---

https://www.ndss-symposium.org/ndss-paper/through-the-authentication-maze-detecting-authentication-bypass-vulnerabilities-in-firmware-binaries/https://www.ndss-symposium.org/ndss-paper/through-the-authentication-maze-detecting-authentication-bypass-vulnerabilities-in-firmware-binaries/https://www.ndss-symposium.org/ndss-paper/through-the-authentication-maze-detecting-authentication-bypass-vulnerabilities-in-firmware-binaries/
선정 논문: Through the Authentication Maze: Detecting Authentication Bypass Vulnerabilities in Firmware Binaries   
through the authentication maze.pdf

게재 학회 및 연도: Network and Distributed System Security (NDSS) Symposium 2026   

저자: Nanyu Zhong, Yuekang Li, Yanyan Zou, Jiaxu Zhao, Jinwei Dong, Yang Xiao, Bingwei Peng, Yeting Li, Wei Wang, Wei Huo (Chinese Academy of Sciences, University of New South Wales)
<br> <br>

<span style="font-size:1.5em;">논문 이해를 위한 용어정리</span>

<br> <br>

<span style="font-size:1.2em;">1. 임베디드 및 웹 인증 도메인 용어</span>

| 용어(Term) | 개념 정의 및 본 논문에서의 역할 |
| --- | --- |
| 펌웨어 (Firmware) & 펌웨어 바이너리 | 라우터, 방화벽, NAS, IP 카메라 등 임베디드 하드웨어 장비를 제어하고 구동하기 위해 비휘발성 메모리에 탑재되는 시스템 소프트웨어다. 본 논문에서는 이 펌웨어 내부에 포함되어 외부 네트워크 요청을 처리하는 C/C++ 기반 웹 서버 실행 파일을 핵심 분석 대상으로 삼는다. |
| Basic 인증 (HTTP Basic Authentication) | HTTP 표준 인증 방식 중 하나로, 클라이언트가 사용자 ID와 비밀번호를 콜론으로 이어 붙인 뒤 Base64로 인코딩하여 요청 헤더의 Authorization 필드에 담아 전송하는 가장 기본적인 사용자 자격 증명 방식이다. |
| NTLM (NT LAN Manager) 인증 | 마이크로소프트가 설계한 챌린지-응답 기반의 인증 프로토콜이다. 평문으로 자격 증명을 보내는 Basic 인증과 달리 서버와 클라이언트가 NTLM 페이로드 메시지를 주고받으며 해시 기반으로 인증한다. 본 논문의 동기 부여 사례에서는 공격자가 User-Agent 헤더는 NTLM용으로, Authorization 헤더는 Basic용으로 섞어 보내 두 인증 루틴이 서로 검증 책임을 미루게 만드는 논리적 사각지대를 유발하는 데 악용되었다. |
| 논리 취약점 vs 메모리 취약점 |버퍼 오버플로우 같은 메모리 취약점은 잘못된 메모리 참조로 인해 크래시 등 즉각적인 외부 신호를 발생시키지만, 인증 우회 같은 논리 취약점은 프로그램이 정상 실행 흐름 안에서 잘못된 권한 상태에 도달하므로 별도의 탐지 기준 정의가 필수적이다. |

<span style="font-size:1.2em;">2. 논문 핵심 정의 용어</span>


| 용어 및 기호 | 풀네임 | 개념 정의 및 본 논문에서의 역할 |
| --- | --- | --- |
| CVS | Credential Verification Statement (자격 증명 검증문) |각 인증 메커니즘에서 사용자가 제출한 자격 증명(비밀번호, 토큰 등)의 유효성을 최초로 직접 검사하여 흐름을 갈라놓는 핵심 조건문이다. 성공 요청과 실패 요청의 실행 트레이스가 이 지점 이전까지는 거의 동일하다가 직후부터 급격히 달라진다는 특징을 이용해 탐지한다. |
|AV| Authentication Variable (인증 변수) | CVS 등의 인증 검증 결과를 저장하고 다른 코드나 상위 호출 함수로 전파하는 변수다. 논문 수식에서는 변수 집합을 $\mathcal{V}_{auth}$로 표기하며, 각 원소는 (변수 v, 값 val, 인증결과 x) 형태의 3중 튜플 (v, val, x)로 관리된다. |
| ACS | Authentication Conditional Statement (인증 조건문) | 인증 변수의 값을 확인하여 프로그램의 제어 흐름을 성공 경로 또는 실패 경로로 분기시키는 모든 조건문을 뜻한다. 앞서 설명한 CVS는 해당 인증 메커니즘에서 가장 처음 등장하는 특수한 초기 ACS에 해당하며, 이후 전파된 AV를 검사하는 상위 함수들의 if 문들도 모두 ACS가 된다. |
| ASBB | Authentication-Success Basic Block (인증 성공 기본 블록)| 오직 인증이 성공했을 때만 실행되는 기본 블록으로, 그 실행 여부가 Cauth내의 성공 분기에 전적으로 제어 의존성을 갖는 코드 영역이다. 공격자가 자격 증명 검증 없이 이 블록에 도달하는 경로를 찾는 것이 곧 인증 우회 취약점 탐지이므로, 지향성 퍼저의 최종 도달 타겟 역할을 한다. |
| AFBB | Authentication-Failure Basic Block (인증 실패 기본 블록) | ASBB와 반대로 인증이 실패했을 때 실행되는 기본 블록이며 집합 기호로 $\mathcal{B}{fail}$을 쓴다. 성공 트레이스에서 선택되지 않은 반대편 분기가 $\mathcal{B}{fail}$로 향한다면 해당 조건문을 암묵적 ACS로 역추론하는 동적 트레이스 기반 식별 규칙에 핵심적으로 활용된다.

<span style="font-size:1.2em;">3. 바이너리 프로그램 분석 및 퍼징 시스템 용어</span>

| 용어 | 개념 정의 및 본 논문에서의 역할 |
| --- | --- |
| 펌웨어 리호스팅 (Firmware Rehosting) & 동적 계측 (Dynamic Instrumentation) | 물리적 장비 없이 QEMU 같은 에뮬레이터에서 펌웨어를 부팅 및 실행하는 기술이 리호스팅이다. 에뮬레이터의 바이너리 변환 과정에 추적 코드를 심어 실행된 기본 블록과 메모리 값을 실시간 기록하는 것이 동적 계측이다. |
| ICFG, CDG, DDG| 바이너리를 디컴파일한 의사코드 수준에서 함수 간 실행 흐름을 이은 그래프가 ICFG(함수 간 제어 흐름 그래프)다. 특정 문장의 실행 여부가 어떤 조건문에 의해 결정되는지 나타내는 그래프가 CDG(제어 의존성 그래프)이며, 변수 간 값의 전달 관계를 나타내는 그래프가 DDG(데이터 의존성 그래프)다. |
| Gen/Kill 데이터 흐름 분석 (Data-flow Analysis) | 각 기본 블록을 통과할 때 추적 대상 속성(인증 변수)이 새로 생성되는지, 혹은 변수가 재정의되어 기존 속성이 소멸되는지를 반복 계산하여 더 이상 새로운 요소가 나오지 않을 때까지 수렴시키는 정적 분석 기법이다. |
| LCS (최장 공통 부분 수열) & RO 유사도 알고리즘 | 성공/실패 실행 트레이스가 갈라지는 후보 분기점을 찾기 위해 두 시퀀스의 가장 긴 공통 흐름을 추출하는 알고리즘이 LCS(Longest Common Subsequence)다. 추출된 분기점 전후의 트레이스 유사도(Sim before,Sim after)를 [0,1] 사이 값으로 정규화해 CVS 점수를 매길 때는 RO(Ratcliff/Obershelp Gestalt pattern matching) 알고리즘이 사용된다. |
| 지향성 그레이박스 퍼징 (Directed Greybox Fuzzing) & SMT 솔버 | 사전에 지정된 목표 위치(Bsucc)까지의 제어 흐름 거리(Distance)와 커버리지 점수를 계산하여 목표 지점에 빠르게 도달하도록 입력값 변이를 유도하는 기법이다. 이때 strcmp, strncmp 같은 문자열 비교 조건문이 가로막고 있으면, 런타임에 후킹한 문자열과 SMT 솔버(경로 조건을 수학적으로 풀어 해를 구하는 도구)를 결합해 조건문을 통과하는 정확한 변이 값을 생성한다. |

<span style="font-size:1.5em;">1. 이 논문의 배경 및 문제 정의</span>
<br> <br>
<span style="font-size:1.2em;">1.1 임베디드 웹 서비스의 인증 구조와 위협 모델</span>
<br>
현대의 라우터, NAS, 게이트 웨이 등 임베디드 시스템은 원격 제어를 위해 경량 웹 서버를 내장하며, 주로 토큰 기반 인증 워크플로우를 사용한다.
<br> <br>
-사용자 자격 증명: 로그인 단계에서 클라이언트가 id/password, pin등을 제출하면 서버가 이를 검증하고 액세스 토큰을 발급한다.
<br> <br>
-토큰 자격 증명: 이후 보호된 리소스에 접근할때 클라이언트가 쿠키, JWT, 세션id등의 토큰을 제시하면 서버가 이를 검증한다.
<br> <br>

저자들은 공격자가 유효한 자격 증명 없이 임의의 HTTP요청을 조작해 보낼 수 있는 상황을 가정하고, 공격 벡터를 두가지로 명확히 정의했다
<br> <br>
-Attack Vector 1: 로그인 핸들러에서 사용자 자격 증명 검증을 우회하여 정당한 액세스 토큰을 탈취하는 공격.   

-Attack Vector 2: 보호된 리소스 요청 핸들러에서 토큰 자격 증명 검증을 우회하여 관리자 기능에 직접 접근하는 공격.
<br> <br><span style="font-size:1.2em;">1.2 실제 사례(CVE-2025-2492)로 본 기존 기법의 구조적 한계</span>
<br> <br>
저자들은 연구의 동기를 설명하기 위해 실제 장비(ASUS RT-AC68U 등)의 lighttpd 기반 웹 서비스에서 발견한 CVE-2025-2492 취약점을 예시로 제시한다. 이 백엔드 바이너리는 설정 파일과 요청의 User-Agent 헤더에 따라 Basic 인증과 NTLM 인증 두 가지 루틴을 모두 지원한다.
<br> <br>
취약점 발생 원리: 공격자가 HTTP 요청 헤더의 User-Agent는 NTLM 인증 대상인 WebDrive로 설정하고, 정작 Authorization 헤더에는 Basic 인증 포맷의 값을 넣어서 보낸다. 그러면 첫 번째 분기에서는 User-Agent가 WebDrive이므로 플래그가 3으로 설정되어 NTLM 인증 함수로 진입한다. 하지만 NTLM 파서는 Authorization 헤더가 Basic 포맷이므로 파싱에 실패하고 내부 플래그를 초기값인 2로 그대로 둔다. 문제는 ntlm_authentication 함수가 qflag가 2일 때 "이 요청은 Basic 인증 루틴이 처리할 것이다"라고 판단하여 goto LABEL_36을 통해 NTLM 자격 증명 검사를 통째로 건너뛰고 인증 성공을 반환해 버린다는 점이다. 결과적으로 두 인증 루틴이 서로 책임을 미루는 논리적 사각지대가 발생해 아무런 검증 없이 인증이 통과된다.
<br> <br>
기존 연구들이 실패하는 이유:

1) Firmalice (NDSS 2015): "login success" 같은 고정된 문자열 단서나 수동 정책에 의존해 인증 코드를 찾는다. 따라서 문자열 단서가 없는 NTLM 인증 루틴의 취약점은 아예 인식하지 못한다.   

2) Weasel (CCS 2013): 실행 트레이스로부터 의사결정 트리를 만들고 지배자 노드를 인증 함수로 추정하는 휴리스틱을 쓴다. 하지만 위 사례처럼 복수의 인증 메커니즘이 얽혀 있으면 최상위 라우팅 함수 하나만 찾고 실제 검증 함수들은 놓치게 된다.
<br> <br>
<span style="font-size:1.5em;">2. 핵심 아이디어 및 시스템 구성-AuthSpark는 어떻게 문제를 해결했는지</span>
<br> <br>
<span style="font-size:1.2em;">2.1 저자들의 두가지 핵심 관찰과 통찰</span>

저자들은 인증 메커니즘이 아무리 다양하더라도 모든 인증 우회 취약점의 본질은 "적절한 자격 증명 검사를 거치지 않고 인증 성공 상태 코드에 도달하는 실행 경로가 존재하는 것"이라는 점에 주목하여 두 가지 규칙성을 발견했다.
<br> <br>
관찰 1 (실행 트레이스의 분기 특성): 인증 성공 요청과 인증 실패 요청의 실행 트레이스(Execution Trace)를 비교하면, 자격 증명을 검증하는 조건문인 CVS(Credential Verification Statement) 이전까지는 전처리 및 플래그 설정 등으로 인해 실행 경로가 매우 유사하지만, CVS 직후부터는 실패 요청이 조기 종료되는 등 경로가 급격히 갈라진다.
<br> <br>
관찰 2 (인증 변수의 전파 특성): CVS에서 판별된 인증 결과는 특정 변수인 AV에 저장되며, 이 변수는 상위 호출 함수의 반환값으로 전달되거나 이후 코드 흐름으로 전파되면서 최종적으로 ASBB의 실행 여부를 통제한다.
<br> <br>
<span style="font-size:1.2em;">2.2 AuthSpark의 4단계 파이프라인 아키텍처</span>
<br> <br>
<span style="font-size:1.2em;">1단계: 전처리 및 의사코드 정렬(preprocessing)</span>

쌍 요청 입력 및 동적 계측: 정상 자격 증명을 가진 성공 요청과, 자격 증명이나 토큰 필드만 더미 값으로 변이한 실패 요청 한쌍을 준비, 다른 필드는 고정하고 인증필드만 바꿈으로써 실행 트레이스의 차이가 오직 인증 검증에서만 기인하도록 통제한다. 이후 QEMU 기반 동적 계측을 통해 두 요청의 기본 블록 실행 트레이즈 수집.

trace-to-pseudocode alignment: 어셈블리 수준에서는 변수 및 문장 단위 데이터 흐름 분석이 어렵기 때문에, 수집된 동적 트레이스를 IDA pro의 디컴파일러가 생성한 의사코드 수준에 매핑, 이때 멀티스레딩 등에 의한 흐름꼬임을 방지하기 위해 콜스택 컨텍스트를 복원하여 문맥이 유지된 의사코드 트레이스를 만들고, 함수별 cdg와 ddg구축
<br> <br>
<span style="font-size:1.2em;">2단계: 자격 증명 검증문 탐지</span>

-콜스택 기반 분할 정복 LCS: 성공.실패두 트레이스가 갈라지는 분기점을 찾기 위해 최장 공통 부분 수열 알고리즘을 사용한다. 그러나 수만 개의 기본 블록으로 이루어진 원본 트레이스에 LCS를 바로 적용하면 계산 복잡도가 폭발한다. 이를 해결하기 위해 함수 호출 지점의  튜플 시퀀스에 먼저 LCS를 적용해 정렬 지점을 찾고, 트레이스를 작은 세그먼트로 쪼갠 뒤 구간별 LCS를 수행하는 최적화를 도입했다.

-유사도 스코어링 수식: 추출된 후보 분기점 d 중 실제 CVS를 가려내기 위해 
Ratcliff/Obershelp알고리즘으로 분기점 이전의 유사도와 이후의 유사도를 계산하여 다음 점수를 매긴다.

![이미지 설명](/assets/tntlr.png/)


여기서 α (실험 최적값 3)는 분기 이전 경로가 동일할수록 보상을 증폭하는 지수이고, β (실험 최적값 0.2)는 분기 이후 경로가 비슷할 때 페널티를 주는 가중치다. 이 수식을 통해 "이전까지는 똑같이 실행되다가 이 지점 직후부터 완전히 달라지는" CVS를 정확히 1순위로 랭크한다.
<br> <br>
<span style="font-size:1.2em;">3단계: 인증 성공 기본 블록 식별</span>
<br> <br>
식별된 CVS를 출발점으로 삼아, 함수 간 반복적 순방향 데이터 흐름 분석을 수행하여 인증 변수 집, 인증 조건문 집합, 인증 성공/실패 블록 집합을 확장해 나간다.
<br> <br>
<span style="font-size:1.2em;">-인증 변수 생성 3대규칙</span>
<br> 
1. 제어 의존성 조건: 변수 대입문의 제어 의존성이 오직 동일한 인증 결과를 갖는 인증 조건문들의 부분집합에만 종속될 때 해당 변수를 AV로 마킹한다.

2. 복사 전파 조건: 기존 AV의 값을 그대로 대입받는 변수는 동일한 인증 상태를 상속받는다.

3. 함수 반환 변수 조건: return 문이 AV를 반환하거나 인증 조건문에 제어 의존성을 가질 때, 성공 맥락과 실패 맥락에서의 반환값을 평가하여 두 값이 다르면 해당 함수의 반환값 자체를 AV로 등록한다.
<br> 
<span style="font-size:1.2em;">-인증 조건문 및 블록 업데이트 2대 규칙</span>

1. 변수 기반 식별: 조건문이 $\mathcal{V}_{auth}$에 속한 변수만 참조한다면, SMT 솔버를 이용해 해당 변수의 값에 따라 어느 분기가 인증 성공인지 추론한다.

2. 동적 트레이스 기반 식별: 조건문이 명시적인 AV를 쓰지 않더라도, 성공 트레이스에서 선택되지 않은 반대쪽 분기가 이미 확인된 실패 블록으로 직행한다면 암묵적 인증 조건문으로 추론하여 추가한다.
이후 기본 블록의 첫 문장이 \mathcal{C}_{auth}$의 성공 분기에 제어 의존성을 가지면 최종적으로 목표 타겟인 ASBB($\mathcal{B}_{succ})에 편입시킨다.
<br> 
<span style="font-size:1.2em;">4단계: 우회 경로 마이닝 및 검증</span>

찾아낸 모든 성공 블록들을 타겟으로 삼아 다중 타겟 지향성 그레이박스 퍼징 수행

<span style="font-size:1.2em;">-3가지 가이드 전략: </span>

(1) 새로운 엣지 발견 비율을 뜻하는 Coverage Score

(2) 테스트 케이스 실행 경로에서 각 성공 블록까지의 제어 흐름 거리를 가중 평균한 Distance Score

(3) 문자열 가이드 변이 생성을 결합한다. 특히 임베디드 웹 서버는 헤더나 파라미터를 strcmp, strncmp, strstr 같은 문자열 비교 함수로 검사하는 경우가 많으므로, 런타임에 이 함수들의 인자를 후킹해 설정 파일에서 로드된 문자열을 사전에 추가하고, 타겟 도달을 가로막는 핵심 분기가 발견되면 SMT 솔버로 그 문자열 비교를 통과할 입력값을 계산해 변이에 직접 주입한다.

-검증모듈: 통합 인증 구조를 가진 서버에서는 로그인이나 인증이 원래 필요 없는 공개 엔드포인트도 동일한 인증 함수를 거쳐 $\mathcal{B}{succ}$에 도달하므로 다수의 오탐이 발생할 수 있다. 이를 막기 위해 $\mathcal{B}{succ}$에 도달한 입력이 나오면 URL 정규화 후 유효한 자격 증명을 넣은 요청과 무효한 자격 증명을 넣은 요청 두 개를 만들어 서버 응답을 비교한다. 두 응답이 똑같다면 원래 공개된 페이지이므로 필터링하고, 응답이 다를 때만 보호된 엔드포인트가 뚫린 실제 취약점으로 최종 확정한다.


<br> 
<span style="font-size:1.5em;">실험 평가, 실제 성과 및 한계점</span>
<br> <br>
<span style="font-size:1.2em;">3.1 실험 환경 및 데이터셋 구성</span>

저자들은 약 25,000줄의 Python과 3,000줄의 C 코드로 AuthSpark를 구현했다. 평가는 D-Link, TP-Link, Fortigate, F5, Ivanti, QNAP, NETGEAR, Zyxel, ASUS, Linksys 등 12개 제조사의 실제 장비 펌웨어 32종을 대상으로 진행되었으며, 여기에는 14개의 알려진 취약점이 포함되어 있다. 에뮬레이션 한계를 보완하기 위해 22개 장비는 QEMU 계측(dataset-1)으로, 나머지 10개 장비는 GDB 트레이싱(dataset-2)으로 실행 트레이스를 수집했다.
<br> <br>
<span style="font-size:1.2em;">3.2 핵심 실험 결과(RQ1 ~ RQ3)</span>


| 평가 항목 (Research Question) | 비교 대상 / 설정 | 핵심 실험 결과 및 수치 |
| --- | --- | --- |
| RQ1-1: CVS(자격 증명 검증문) 식별 정확도| AuthSpark vs Weasel (총 44개 실제 CVS 대상, Top-1 기준)| AuthSpark: 44개 중 42개(95.5%) 정확히 Top-1 식별 (Top-4 기준 44개 전수 식별), 알려진 취약점 14개와 연결된 핵심 CVS 11개 100% 식별. <br>Weasel: 44개 중 **16개(36.4%)**만 식별, 취약점 관련 CVS는 11개 중 3개만 탐지. |
| RQ1-2: ASBB(인증 성공 블록) 식별 절제 연구 | Full AuthSpark vs 규칙별 제거 모델 4종 (NoCopy, NoFunc, NoVarCond, NoDynamicCond) | Full AuthSpark: 총 383개 ASBB 식별, 14개 1-day 취약점 경로 100%(14/14) 노출.<br> 복사 전파 제거(NoCopy): 230개 식별 (취약점 4개만 노출).<br>함수 반환 변수 제거(NoFunc): 132개 식별 (취약점 1개만 노출 — 함수 반환값을 통한 상태 전파가 가장 치명적임을 입증).<br>변수 기반 조건문 제거NoVarCond): 77개 식별 (취약점 2개만 노출).<br>동적 트레이스 조건문 제거(NoDynamicCond): 363개 식별 (1-day는 모두 찾았으나 실제 0-day 1건(Report Issue 1) 미탐지).|
| RQ2: 1-day 취약점 퍼징 탐지 성능 (QEMU 지원 22개 장비, 24시간×5회)| AuthSpark vs 변이 제거 모델 2종 vs 기존 퍼저 3종 (SRFuzzer, Snipuzz, BooFuzz) | AuthSpark: 대상 장비 내 알려진 취약점 9개 전수(9/9) 탐지 (공개된 기술 문서가 전혀 없던 NETGEAR XR300의 CVE-2021-34977도 URL 내 "rpc" 문자열 조건을 역산해 독자적으로 재발견).<br>AuthSpark-NoStr(동적 문자열 제거): 6개 탐지 / NoStr-NoMutate: 3개 탐지.<br>SRFuzzer, Snipuzz, BooFuzz: AuthSpark가 찾아낸 ASBB를 오라클로 제공했음에도 1-day 0개(0/9) 탐지.<br> |
| RQ3: 최신 펌웨어 0-day 취약점 발굴 | 최신 버전 펌웨어 대상 퍼징 | 총 6개의 0-day 인증 우회 취약점 신규 발굴 및 제조사 검증 완료 (CVE 3건, PSV 1건 공식 할당: PSV-2025-0044 2건, CVE-2024-6342, CVE-2025-2492, CVE-2025-59366 등).<br>검증 모듈을 통해 ASUS RT-AX56U에서 24시간 동안 발생한 2,689개의 알림 중 공개 엔드포인트 오탐을 걸러내고 158개로 줄이는 데 성공. |

<br> 
<span style="font-size:1.2em;">3.3 한계점 및 아쉬운점</span>
<br> <br>
논문이 자체적으로 언급한 한계
<br> <br>

1. 극단적으로 긴 실행 트레이스에서의 CVS 랭킹 오류: AuthSpark가 Top-1에서 놓친 2개의 CVS(FortiOS 및 TP-Link Archer C8)를 분석해 보면, 전체 실행 트레이스가 50,000개 이상의 기본 블록으로 매우 길고, 실제 CVS에서 발생한 성공/실패의 분기가 아주 짧게 끝난 뒤 다시 합류하여 긴 공통 경로를 공유하는 구조를 띠고 있었다. 이 경우 트레이스 후반부에 우연히 등장한 무관한 분기점이 앞선 거대한 공통 프리픽스 덕분에 Sim before ≈0.99라는 높은 점수를 받아 실제 CVS를 밀어내고 1순위로 잘못 랭크되는 현상이 발생했다.

2. 비전통적 인증 상태 저장소 추적 불가:
AuthSpark는 인증 결과가 메모리 상의 지역/전역 변수나 함수 반환값을 통해 전파된다고 가정한다. 따라서 Juniper SRX처럼 인증 결과를 세션 파일이나 외부 DB, 공유 메모리에 기록해 두고 나중에 파일 내용만 읽어서 검증하는 아키텍처에서는 데이터 흐름이 끊겨 추적하지 못한다.

3. 다중 레벨 포인터 및 복합 자료구조에 대한 정적 분석의 한계:
인증 상태가 다중 포인터로 참조되는 복잡한 구조체 필드 내부에 저장될 경우, IDA Pro의 디컴파일러와 정적 데이터 흐름 분석이 기본 블록 너머로 변수 상태를 온전히 전파하지 못하는 정밀도 한계가 존재한다.

4. 단일 C/C++ 바이너리 모듈 내 분석으로 제한된 범위: SonicWall GMS처럼 Apache와 Tomcat 등 여러 모듈이나 프로세스에 걸쳐 인증 로직이 분산되어 있거나, PHP/Lua/Python 같은 스크립트 언어로 인증이 구현된 경우 현재의 AuthSpark로는 엔드투엔드 추적이 불가능하다. 또한 QEMU 시스템 에뮬레이션이 실패하여 GDB에 의존해야 했던 10개 장비(dataset-2)의 경우, 트레이스 기반 CVS/ASBB 식별까지는 가능했으나 QEMU 계측에 의존하는 피드백 기반 퍼징 실험에서는 제외되었다
<br> <br>
<span style="font-size:1.5em;">느낀점, 배운점 및 향후 연구/ 프로젝트 확장</span>
<br> <br>
<span style="font-size:1.2em;">4.1 느낀점</span>
<br> <br>
보안에 관련된것이 아니라 논문 자체를 읽어보는것이 처음이었는데 기본지식이 부족하다보니 양이 방대한것은 아님에도 불구하고, 기본적인 단어들의 뜻과 의미조차 몰라 뜻을 검색하고 이해하려고 하는 부분에 있어서 소요된 시간이 오래걸렸던것 같다. 그럼에도 불구하고 내가 이 논문의 정확한 내용을 파악했는지 조차 솔직히 모르겠다, 단어의 의미를 알면 좀 이해하기 쉬울까 라고 생각하였지만 전혀 그렇지 않았다. 그래도 이해하지 못하더라도 이런 논문들을 하나씩 읽어보는것만으로도 보안 용어에 익숙해지고 찾아보는 습관을 기를 수 있을것 같다는 생각을 하게되었다.
<br> <br>
<span style="font-size:1.2em;">4.2 논문을 통해 배운점과 인사이트</span>
<br> <br>
메모리 취약점과 달리 무엇이 버그인지 정의하기조차 막막한 논리 취약점을, 성공/실패 실행 트레이스 간 차분 분석과 정적 제어,데이터 흐름 전파의 결합으로 풀어낸 점이 매우 인상 깊었다. 특히 동적 분석만 쓰면 도달하지 못한 코드 경로의 인증 로직을 놓치기 쉽고, 정적 분석만 쓰면 무엇이 인증 검증문인지조차 특정할 수 없는데, 동적 트레이스 비교로 시작점을 정확히 꽂아준 뒤 정적 분석으로 목표 지점을 확장하고 다시 지향성 퍼징으로 둘 사이의 우회 경로를 뚫어내는 것이 인상적이었다.
<br> <br>
<span style="font-size:1.2em;">4.3 앞으로 할 것</span>
<br> <br>
-논문읽기
<br> 
Atropos: Effective Fuzzing of Web Applications for Server-Side Vulnerabilities (USENIX Security 2024, Güler et al.): AuthSpark의 문자열 비교 함수 후킹 및 동적 문자열 사전 구축에 직접적인 영감을 준 논문이기 때문에 읽으면 AuthSpark라는 것에 대해 지금보다 더 깊게 이해할 수 있을것 같아서 읽어보려한다.
<br> <br>
-다른 분야와의 접목, 프로젝트 등은 아직 개념을 확실하게 이해하지 못했기 때문에 관련 논문들을 더 읽고 개념을 확실히 잡은후에 찾아보려한다.
