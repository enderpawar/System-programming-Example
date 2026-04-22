"""
2025 System Programming 예상 중간고사 정답 및 해설집 PDF 생성기
"""
from fpdf import FPDF

FONT_R = 'C:/Windows/Fonts/malgun.ttf'
FONT_B = 'C:/Windows/Fonts/malgunbd.ttf'


class AnswerPDF(FPDF):
    def __init__(self):
        super().__init__(orientation='P', unit='mm', format='A4')
        self.add_font('KR', '',  FONT_R)
        self.add_font('KR', 'B', FONT_B)
        self.set_margins(20, 25, 20)
        self.set_auto_page_break(auto=True, margin=20)

    def header(self):
        self.set_font('KR', 'B', 10)
        w = self.w - 40
        self.cell(w * 0.35, 6, 'System Programming', border=0)
        self.cell(w * 0.40, 6, '2025 Mid-Term  [정답 및 해설]', border=0, align='C')
        self.cell(w * 0.25, 6, f'page {self.page_no()} / {{nb}}', border=0, align='R')
        self.ln(2)
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.5)
        self.line(20, self.get_y(), self.w - 20, self.get_y())
        self.set_line_width(0.4)
        self.ln(4)

    def footer(self):
        self.set_y(-13)
        self.set_font('KR', '', 8)
        self.set_text_color(130, 130, 130)
        self.cell(0, 6, '기출 분석 기반 2025 예상 문제 해설 — 학습 목적으로만 사용할 것', align='C')
        self.set_text_color(0, 0, 0)

    # ── 헬퍼 ──────────────────────────────────────────────────
    def kr(self, size=10, bold=False):
        self.set_font('KR', 'B' if bold else '', size)

    def q_header(self, num, pt, title, answer_short=''):
        """문제 제목 + 간략 답"""
        # 배경 박스
        self.set_fill_color(30, 60, 120)
        self.set_text_color(255, 255, 255)
        self.set_font('KR', 'B', 10)
        self.cell(self.w - 40, 7, f'  {num}. [{pt}pt]  {title}', border=0, fill=True)
        self.ln(7)
        self.set_fill_color(255, 255, 255)
        self.set_text_color(0, 0, 0)
        if answer_short:
            self.set_fill_color(220, 235, 255)
            self.set_font('KR', 'B', 9.5)
            self.cell(self.w - 40, 6, f'  ★ 정답: {answer_short}', border=0, fill=True)
            self.ln(6)
            self.set_fill_color(255, 255, 255)
        self.ln(1)

    def section(self, label, text='', indent=6):
        self.set_x(20 + indent)
        self.kr(9.5, bold=True)
        lw = self.get_string_width(label) + 2
        self.cell(lw, 5.5, label)
        if text:
            self.kr(9.5)
            self.multi_cell(self.w - 40 - indent - lw, 5.5, text)
        else:
            self.ln(5.5)

    def explain(self, text, indent=10, size=9.5, lh=5.5):
        self.set_x(20 + indent)
        self.kr(size)
        self.multi_cell(self.w - 40 - indent, lh, text)

    def bullet(self, items, indent=12):
        for text in items:
            self.set_x(20 + indent)
            self.kr(9.5)
            self.multi_cell(self.w - 40 - indent, 5.5, text)

    def code_block(self, lines, indent=8):
        self.set_fill_color(242, 242, 242)
        self.set_draw_color(190, 190, 190)
        self.set_line_width(0.2)
        bw = self.w - 40 - indent
        lh, pad = 4.6, 2
        total_h = lh * len(lines) + pad * 2
        x0, y0 = 20 + indent, self.get_y()
        self.rect(x0, y0, bw, total_h, 'DF')
        self.set_font('Courier', '', 8.5)
        self.set_y(y0 + pad)
        for line in lines:
            self.set_x(x0 + pad)
            self.cell(bw - pad * 2, lh, line)
            self.ln(lh)
        self.set_fill_color(255, 255, 255)
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.4)
        self.ln(1)

    def answer_box(self, text, indent=10):
        """초록 배경 정답 박스"""
        self.set_fill_color(230, 255, 230)
        self.set_draw_color(0, 150, 0)
        self.set_line_width(0.4)
        self.set_x(20 + indent)
        self.kr(9.5, bold=True)
        self.multi_cell(self.w - 40 - indent, 6, text, border=1, fill=True)
        self.set_draw_color(0, 0, 0)
        self.ln(1)

    def key_point(self, text, indent=10):
        """빨간 테두리 핵심 포인트"""
        self.set_fill_color(255, 245, 245)
        self.set_draw_color(200, 0, 0)
        self.set_line_width(0.4)
        self.set_x(20 + indent)
        self.kr(9)
        self.multi_cell(self.w - 40 - indent, 5.5, text, border=1, fill=True)
        self.set_draw_color(0, 0, 0)
        self.ln(1)

    def divider(self):
        self.ln(3)
        self.set_draw_color(150, 150, 150)
        self.set_line_width(0.2)
        self.line(20, self.get_y(), self.w - 20, self.get_y())
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.4)
        self.ln(3)

    def flag_answer(self, cf, of_, sf, zf, indent=10):
        self.set_x(20 + indent)
        self.kr(9, bold=True)
        cw = 22
        for f in ('CF', 'OF', 'SF', 'ZF'):
            self.cell(cw, 6, f, border=1, align='C')
        self.ln(6)
        self.set_x(20 + indent)
        self.set_fill_color(230, 255, 230)
        for v in (cf, of_, sf, zf):
            self.cell(cw, 7, str(v), border=1, align='C', fill=True)
        self.ln(8)
        self.set_fill_color(255, 255, 255)

    def mem_table(self, rows, indent=10):
        self.set_x(20 + indent)
        self.kr(9, bold=True)
        self.cell(38, 6, '주소 (오프셋)', border=1, align='C')
        self.cell(30, 6, '저장된 값', border=1, align='C')
        self.ln(6)
        self.set_fill_color(230, 255, 230)
        for addr, val in rows:
            self.set_x(20 + indent)
            self.kr(9)
            self.cell(38, 7, addr, border=1)
            self.kr(9, bold=True)
            self.cell(30, 7, val, border=1, align='C', fill=True)
            self.ln(7)
        self.set_fill_color(255, 255, 255)


# ══════════════════════════════════════════════════════════════
pdf = AnswerPDF()
pdf.alias_nb_pages()
pdf.set_line_width(0.4)

# ══════════════════════════════════════════════════════════════
# PAGE 1
# ══════════════════════════════════════════════════════════════
pdf.add_page()

pdf.kr(9)
pdf.set_text_color(80, 80, 80)
pdf.multi_cell(0, 5,
    '  ※ 초록 박스 = 정답  |  파란 배경 = 문제 제목  |  빨간 박스 = 시험 핵심 포인트\n'
    '  ※ 채점 기준은 교수에 따라 다를 수 있음 — 해설을 이해하는 것이 목표')
pdf.set_text_color(0, 0, 0)
pdf.ln(3)

# ── Q1 ──────────────────────────────────────────────────────
pdf.q_header('1', 10, 'Assembly Language 옳지 않은 설명 고르기', '①②④')

pdf.bullet([
    '① [틀림]  Assembly Language는 CPU가 직접 실행하지 못함.\n'
    '           CPU는 기계어(Machine Code)만 직접 실행 가능.\n'
    '           Assembly Language는 Assembler를 통해 기계어로 변환 후 실행.',
    '② [틀림]  Object 파일(.obj)은 Linker를 거쳐야 실행 파일(.exe)이 됨.\n'
    '           Object 파일만으로는 실행 불가 (라이브러리 주소 미연결).',
    '③ [맞음]  Linker = Object(.obj) + Library(.lib) → Executable(.exe)',
    '④ [틀림]  Assembly Language와 Machine Language는 대체로 1대1이지만,\n'
    '           Directive(의사명령어: .DATA, BYTE, PROC 등)는 기계어로 번역되지 않음.\n'
    '           또한 MACRO는 여러 명령어로 확장될 수 있어 1대1이 아님.',
    '⑤ [맞음]  Assembly는 특정 CPU에 종속 → 이식성 낮음.',
])
pdf.key_point(
    '[핵심] 어셈블-링크-실행 사이클:  .asm → [Assembler] → .obj → [Linker] → .exe → [OS Loader] → 실행\n'
    '         Directive(어셈블 시간 처리) vs Instruction(런타임 실행, 기계어로 번역)',
    indent=8)

pdf.divider()

# ── Q2 ──────────────────────────────────────────────────────
pdf.q_header('2', 5, '부호있는 8비트 정수(SBYTE) 범위')

pdf.explain('8비트 2의 보수(Two\'s Complement) 부호있는 정수:')
pdf.bullet([
    '비트 수 = 8, MSB = 부호 비트',
    '최소 = -2^(8-1) = -2^7 = -128',
    '최대 = 2^(8-1) - 1 = 2^7 - 1 = 127',
])
pdf.answer_box('최소: -128  (= -2^7)         ~        최대: 127  (= 2^7 - 1)', indent=8)
pdf.key_point(
    '[핵심] n비트 부호있는 정수 범위: -2^(n-1)  ~  2^(n-1)-1\n'
    '         8비트: -128 ~ 127  |  16비트: -32,768 ~ 32,767  |  32비트: -2,147,483,648 ~ 2,147,483,647',
    indent=8)

pdf.divider()

# ── Q3 ──────────────────────────────────────────────────────
pdf.q_header('3', 10, '폰 노이만(Von Neumann) 컴퓨터 구조')

pdf.section('(1) [4pt]  폰 노이만 구조의 주된 특징')
pdf.answer_box(
    '프로그램 내장 방식 (Stored Program Concept)\n'
    '· 명령어(프로그램)와 데이터를 동일한 메모리(RAM)에 함께 저장\n'
    '· CPU가 메모리에서 명령어를 순차적으로 읽어(Fetch) 실행\n'
    '· 프로그램 변경 시 메모리 내용만 바꾸면 됨 (이전: 물리적 배선 변경 필요)',
    indent=8)

pdf.section('(2) [3pt]  병목지점(Bottleneck)')
pdf.answer_box(
    '폰 노이만 병목 (Von Neumann Bottleneck)\n'
    '· CPU 처리 속도 >> 메모리(RAM) 접근 속도\n'
    '· CPU-메모리 간 Bus 대역폭이 CPU 처리 속도를 따라가지 못함\n'
    '· CPU가 연산할 준비가 되어도 메모리에서 데이터를 기다려야 하는 지연 발생',
    indent=8)

pdf.section('(3) [3pt]  병목 해결 전략')
pdf.answer_box(
    '캐시 메모리 (Cache Memory) 활용\n'
    '· CPU와 주기억장치(RAM) 사이에 소용량·고속 캐시 메모리 배치\n'
    '· 자주 사용하는 명령어·데이터를 캐시에 미리 적재 (Locality 원리)\n'
    '· 캐시 히트 시 RAM 접근 불필요 → 대기 시간 대폭 감소',
    indent=8)

pdf.divider()

# ══════════════════════════════════════════════════════════════
# PAGE 2
# ══════════════════════════════════════════════════════════════
pdf.add_page()

# ── Q4 ──────────────────────────────────────────────────────
pdf.q_header('4', 10, 'CPU 명령어 실행 사이클 빈칸 채우기')

pdf.explain('3단계 실행 사이클 (Fetch → Decode → Execute):')
pdf.ln(1)

rows_q4 = [
    ('1단계 (Fetch)',   '메모리(①)',   '명령어(②)',   '을/를 가져온다'),
    ('2단계 (Decode)',  '명령어(③)',   '해독/디코딩(④)', '한다'),
    ('3단계 (Execute)', '명령어/연산(⑤)', '실행(⑥)',  '한다'),
]
cw = [38, 48, 48, 35]
pdf.set_x(20)
pdf.kr(9, bold=True)
for w_, t in zip(cw, ['단계', '① / ③ / ⑤', '② / ④ / ⑥', '문형']):
    pdf.cell(w_, 6, t, border=1, align='C')
pdf.ln(6)
for step, a, b, end in rows_q4:
    pdf.set_x(20)
    pdf.kr(9)
    pdf.cell(cw[0], 7, step, border=1)
    pdf.set_fill_color(230, 255, 230)
    pdf.kr(9, bold=True)
    pdf.cell(cw[1], 7, a, border=1, fill=True, align='C')
    pdf.cell(cw[2], 7, b, border=1, fill=True, align='C')
    pdf.set_fill_color(255, 255, 255)
    pdf.kr(9)
    pdf.cell(cw[3], 7, end, border=1)
    pdf.ln(7)

pdf.ln(2)
pdf.key_point(
    '[핵심] 필수 단계: Fetch(필수), Decode(필수), Execute(필수)\n'
    '         추가 단계(5단계): Fetch→Decode→Execute→Memory Access→Write Back\n'
    '         EIP(명령어 포인터): 다음 실행할 명령어의 메모리 주소를 저장',
    indent=6)

pdf.divider()

# ── Q5 ──────────────────────────────────────────────────────
pdf.q_header('5', 10, 'Real Address 모드 주소 공간 계산')

pdf.explain('물리 주소 구성 방식:  물리주소 = Segment × 16 + Offset')
pdf.explain('Segment: 16비트 (최대 FFFFh),  Offset: 16비트 (최대 FFFFh)')
pdf.ln(1)
pdf.answer_box(
    '[ 계산 과정 ]\n'
    '  최대 물리 주소 = FFFFh × 10h + FFFFh\n'
    '                 = FFFF0h + FFFFh\n'
    '                 = 10FFEFh\n\n'
    '  실제 주소 버스 폭 = 20비트\n'
    '  → 주소 공간 최대 크기 = 2^20 = 1,048,576 bytes = 1 MB\n\n'
    '  답: 1 MB  (= 2^20 bytes = 1,048,576 bytes)',
    indent=6)
pdf.key_point(
    '[핵심] Real Address 모드: 20비트 주소 → 최대 1MB\n'
    '         Protected 모드: 32비트 주소 → 최대 4GB\n'
    '         주소 버스가 20비트인 이유: 16비트 Segment × 16(= ×2^4)이 최대 20비트 생성',
    indent=6)

pdf.divider()

# ── Q6 ──────────────────────────────────────────────────────
pdf.q_header('6', 15, 'CPU 플래그 계산  (ADD AL, BL)')

pdf.explain('실행 코드:')
pdf.code_block([
    'MOV AX, 1A64h   ; AL = 64h = 0110 0100 = 100 (signed: +100)',
    'MOV BX, 2B50h   ; BL = 50h = 0101 0000 =  80 (signed: +80)',
    'ADD AL, BL      ; 8-bit ADD',
], indent=6)

pdf.section('(1) [6pt]  플래그 값')
pdf.explain('이진수 계산:', indent=8)
pdf.code_block([
    '  AL = 0110 0100  (= 64h = 100)',
    '  BL = 0101 0000  (= 50h =  80)',
    '  +) ----------------',
    '     1011 0100  (= B4h = 180)   <- no carry out from bit 8',
], indent=10)
pdf.flag_answer(0, 1, 1, 0, indent=10)

pdf.section('(2) [9pt]  탐지 방법 설명')

pdf.explain('1) CF (Carry Flag):', indent=8)
pdf.answer_box(
    '8비트 부호 없는 덧셈에서 9번째 비트로 올림(Carry out) 발생 여부\n'
    '0110 0100 + 0101 0000 = 1011 0100  (9번째 비트 = 0)\n'
    '100 + 80 = 180 ≤ 255  → 부호없는 오버플로 없음  →  CF = 0',
    indent=10)

pdf.explain('2) OF (Overflow Flag):', indent=8)
pdf.answer_box(
    '8비트 부호있는 덧셈에서 오버플로 발생 여부 (양+양=음  or  음+음=양)\n'
    'AL = +100 (양수, MSB=0),  BL = +80 (양수, MSB=0)\n'
    '결과 = B4h = 1011 0100  →  MSB = 1  →  부호있는 정수로 -76으로 해석\n'
    '양수 + 양수 = 음수  →  오버플로 발생  →  OF = 1\n'
    '[확인] 100 + 80 = 180 > 127 (8비트 부호있는 최대)  →  OF = 1',
    indent=10)

pdf.explain('3) SF / ZF:', indent=8)
pdf.answer_box(
    'SF (Sign Flag):  결과의 MSB 값\n'
    '결과 = B4h = 1011 0100  →  MSB = 1  →  SF = 1\n\n'
    'ZF (Zero Flag):  결과가 정확히 0인지 여부\n'
    '결과 = B4h ≠ 0  →  ZF = 0',
    indent=10)

pdf.key_point(
    '[핵심] OF 판정 규칙:\n'
    '  · 양수 + 양수 → 결과가 음수(MSB=1)이면 OF=1\n'
    '  · 음수 + 음수 → 결과가 양수(MSB=0)이면 OF=1\n'
    '  · 양수 + 음수 (or 음수 + 양수) → 절대 OF=1 불가\n'
    '  · CF vs OF: CF = 부호없는 오버플로,  OF = 부호있는 오버플로',
    indent=6)

# ══════════════════════════════════════════════════════════════
# PAGE 3
# ══════════════════════════════════════════════════════════════
pdf.add_page()

# ── Q7 ──────────────────────────────────────────────────────
pdf.q_header('7', 15, '어셈블리 프로그램 분석')

# Q7-(1)
pdf.section('(1) [5pt]  리틀 엔디안 메모리 배치')
pdf.explain('ARRAY WORD 0AB12h, 0CD34h  →  리틀 엔디안 저장:', indent=8)
pdf.explain('WORD 0AB12h: 하위 바이트(12h) 먼저 → 낮은 주소에 저장', indent=10)
pdf.explain('WORD 0CD34h: 하위 바이트(34h) 먼저 → 그 다음 주소에 저장', indent=10)
pdf.ln(1)
pdf.mem_table([
    ('ARRAY+0  (#1)', '12h'),
    ('ARRAY+1  (#2)', 'ABh'),
    ('ARRAY+2  (#3)', '34h'),
    ('ARRAY+3  (#4)', 'CDh'),
], indent=10)
pdf.key_point(
    '[핵심] 리틀 엔디안(x86): 낮은 주소에 LSB(Least Significant Byte, 하위 바이트) 저장\n'
    '         WORD 0AB12h  →  [12h][ABh]  (12h가 낮은 주소)\n'
    '         DWORD 12345678h  →  [78h][56h][34h][12h]  (78h가 낮은 주소)',
    indent=8)

pdf.divider()

# Q7-(2)
pdf.section('(2) [5pt]  WORD PTR 읽기 결과')
pdf.explain('메모리 배치 (리틀 엔디안):', indent=8)
pdf.code_block([
    'VAR1 WORD  0FFFFh  ->  [FFh][FFh]   ; ESI+0=FFh, ESI+1=FFh',
    'VAR2 SWORD 256     ->  [00h][01h]   ; ESI+2=00h, ESI+3=01h',
    '',
    'MOV AX, WORD PTR [ESI+1]  ; read 2 bytes from ESI+1 as WORD',
    '  AL = [ESI+1] = FFh  (low byte)',
    '  AH = [ESI+2] = 00h  (high byte)',
    '  AX = 00FFh',
], indent=10)
pdf.answer_box('AX = 00FFh', indent=10)
pdf.key_point(
    '[핵심] WORD PTR [addr]: addr 부터 2바이트를 WORD로 읽음\n'
    '         리틀 엔디안이므로 [addr] → AL (하위), [addr+1] → AH (상위)\n'
    '         경계를 넘는 읽기(VAR1+VAR2 걸치기)도 허용됨',
    indent=8)

pdf.divider()

# Q7-(3)
pdf.section('(3) [5pt]  LOOP 프로그램 결과')
pdf.code_block([
    'ARRAY BYTE 10, 20, 30, 40, 50  ; 5 elements',
    'SUM   BYTE 0',
    'ECX = 5 (LENGTHOF ARRAY)  ->  loop runs 5 times',
], indent=10)
pdf.explain('루프 실행 과정:', indent=10)
pdf.code_block([
    'iter 1: SUM =   0 + 10 =  10',
    'iter 2: SUM =  10 + 20 =  30',
    'iter 3: SUM =  30 + 30 =  60',
    'iter 4: SUM =  60 + 40 = 100',
    'iter 5: SUM = 100 + 50 = 150',
], indent=12)
pdf.answer_box('SUM = 150  (오류 없음)', indent=10)
pdf.key_point(
    '[주의] ADD SUM, ARRAY[ESI]: 두 피연산자 모두 메모리 참조\n'
    '         x86 엄밀히는 메모리-메모리 ADD 불가 → MASM 버전에 따라 오류 가능\n'
    '         [교수 의도 해석] 오류 없이 실행 → SUM = 150\n'
    '         [완전 정답] 오류 발생 시: "ADD SUM, ARRAY[ESI]에서 메모리-메모리 연산 불가 오류"\n'
    '           수정: MOV AL, ARRAY[ESI]  →  ADD SUM, AL',
    indent=8)

pdf.divider()

# ── Q8 ──────────────────────────────────────────────────────
pdf.q_header('8', 10, 'C++ → Assembly 변환  (#1)(#2) 채우기')

pdf.explain('for 루프를 LOOP 명령어로 변환하는 패턴:')
pdf.explain('· C++ for(i=0; i<N; ++i) → Assembly에서 ECX=N, LOOP 명령 사용', indent=8)
pdf.explain('· sizeof(arr) = LENGTHOF ARR (원소 개수)', indent=8)
pdf.ln(1)
pdf.answer_box(
    '(#1) = MOV ECX, LENGTHOF ARR   ; 루프 횟수 설정 (5회)',
    indent=8)
pdf.answer_box(
    '(#2) = LOOP L1                  ; ECX--, ECX≠0이면 L1으로 점프',
    indent=8)

pdf.key_point(
    '[핵심] LOOP 명령어 동작:\n'
    '  ① ECX -= 1\n'
    '  ② ECX ≠ 0이면 레이블로 점프, ECX = 0이면 다음 명령어 실행\n'
    '  [주의] LOOP 전 ECX = 0이면 ECX -= 1 → ECX = FFFFFFFFh (= 약 42억회 루프!)',
    indent=6)

# ══════════════════════════════════════════════════════════════
# PAGE 4
# ══════════════════════════════════════════════════════════════
pdf.add_page()

# ── Q9 ──────────────────────────────────────────────────────
pdf.q_header('9', 15, 'Stack / Procedure  —  CALL, RET, ESP, EIP')

# Q9-(1)
pdf.section('(1) [5pt]  call MySub 직후 ESP, EIP 값')
pdf.explain('CALL 명령 실행 전: ESP = 0000FF00h', indent=8)
pdf.ln(1)
pdf.code_block([
    'CALL MySub: two actions occur in sequence:',
    '  1) ESP -= 4      : ESP = 0000FF00h - 4 = 0000FEFCh',
    '  2) [ESP] = return addr = 00000016h  (addr of "mov ebx, eax")',
    '  3) EIP = MySub start address = 00000040h',
], indent=8)
pdf.answer_box(
    'EIP = 00000040h   (MySub 시작 주소 — 다음 실행할 명령어)\n'
    'ESP = 0000FEFCh   (= 0000FF00h - 4, 복귀주소 push로 감소)',
    indent=8)
pdf.explain('[ESP]가 가리키는 값 = 00000016h  (스택에 저장된 복귀 주소)', indent=8)
pdf.ln(1)
pdf.key_point(
    '[핵심] CALL 명령어 동작:\n'
    '  ① ESP -= 4\n'
    '  ② [ESP] = CALL 다음 명령어 주소 (복귀 주소)\n'
    '  ③ EIP = 피호출 함수(MySub) 시작 주소\n\n'
    '[핵심] RET 명령어 동작 (역순):\n'
    '  ① EIP = [ESP]  (복귀 주소 pop)\n'
    '  ② ESP += 4',
    indent=6)

pdf.divider()

# Q9-(2)
pdf.section('(2) [10pt]  ADD eax, 64 실행 직후 ESP가 가리키는 값')
pdf.ln(1)
pdf.explain('단계별 EAX·ESP 변화 추적 (초기 ESP = E 가정):', indent=8)
pdf.code_block([
    'Instruction               EAX change             ESP change',
    '------------------------------------------------------------',
    'MOV eax, -1               FFFFFFFFh              E  (no change)',
    'MOV ax, 128 (= 0080h)     FFFF0080h              E  (hi 16bits kept)',
    'PUSH eax                  FFFF0080h              E-4  ([E-4]=FFFF0080h)',
    'CALL mysub                FFFF0080h              E-8  ([E-8]=ret addr)',
    '  ADD eax, 32             FFFF00A0h              E-8  (inside mysub)',
    '  ret                     FFFF00A0h              E-4  (ret addr popped)',
    '[*] ADD eax, 64 HERE      FFFF00E0h              E-4',
], indent=8)
pdf.ln(1)
pdf.explain('ADD eax, 64 실행 직후 ESP = E-4', indent=8)
pdf.explain('[E-4]에 저장된 값 = FFFF0080h  (PUSH eax로 저장된 값, ret으로 변경 안 됨)', indent=8)
pdf.ln(1)
pdf.answer_box(
    'ESP가 가리키는 값 = FFFF0080h\n\n'
    '[ 계산 근거 ]\n'
    '· MOV eax, -1   → EAX = FFFFFFFFh\n'
    '· MOV ax, 128   → AX = 0080h, 상위 16비트 유지 → EAX = FFFF0080h\n'
    '· PUSH eax      → [ESP] = FFFF0080h, ESP -= 4\n'
    '· CALL mysub    → 복귀주소 push, ESP -= 4\n'
    '· ret           → 복귀주소 pop, ESP += 4  (PUSH eax 위치로 복귀)\n'
    '· ADD eax, 64   → 이 시점에서 ESP = PUSH eax 이후 값 = E-4\n'
    '                   [ESP] = FFFF0080h  (PUSH eax 때 저장된 값)',
    indent=6)
pdf.key_point(
    '[핵심] ret 이후 ESP는 CALL 이전 위치로 복귀 (복귀주소 pop)\n'
    '         PUSH eax로 넣은 값은 ret 이후에도 스택에 그대로 남아있음\n'
    '         (단, POP으로 명시적으로 꺼내지 않는 한)\n\n'
    '[핵심] MOV ax, 128 이후 EAX:\n'
    '         EAX = FFFFFFFFh 상태에서 AX(하위 16비트)만 0080h로 변경\n'
    '         → EAX = FFFF0080h  (상위 16비트는 FFFFh 유지)',
    indent=6)

pdf.divider()

# ── 총점 배점표 ─────────────────────────────────────────────
pdf.ln(2)
pdf.set_fill_color(245, 245, 245)
pdf.kr(9, bold=True)
pdf.cell(self_w := pdf.w - 40, 6, '  [ 배점 요약표 ]', border=1, fill=True, align='L')
pdf.ln(6)
pdf.set_fill_color(255, 255, 255)

score_data = [
    ('Q1', '10pt', 'Assembly 틀린 설명 (①②④)'),
    ('Q2', ' 5pt', 'SBYTE 범위 (-128 ~ 127)'),
    ('Q3', '10pt', '폰 노이만 특징·병목·해결책'),
    ('Q4', '10pt', 'CPU 실행 사이클 Fetch/Decode/Execute 빈칸'),
    ('Q5', '10pt', 'Real address 주소 공간 = 1MB = 2^20'),
    ('Q6', '15pt', 'CF=0, OF=1, SF=1, ZF=0  (계산 과정)'),
    ('Q7', '15pt', '리틀 엔디안(#1~4)  +  AX=00FFh  +  SUM=150'),
    ('Q8', '10pt', '#1=MOV ECX,LENGTHOF ARR  /  #2=LOOP L1'),
    ('Q9', '15pt', 'EIP=40h,ESP=FEFCh  /  ESP→FFFF0080h'),
]
for qn, pt, ans in score_data:
    pdf.set_x(20)
    pdf.kr(9, bold=True)
    pdf.cell(12, 6, qn, border=1, align='C')
    pdf.set_fill_color(230, 255, 230)
    pdf.cell(14, 6, pt, border=1, align='C', fill=True)
    pdf.set_fill_color(255, 255, 255)
    pdf.kr(9)
    pdf.cell(self_w - 26, 6, '  ' + ans, border=1)
    pdf.ln(6)

pdf.set_x(20)
pdf.kr(10, bold=True)
pdf.set_fill_color(30, 60, 120)
pdf.set_text_color(255, 255, 255)
pdf.cell(self_w, 7, '  합계: 100점', border=1, fill=True)
pdf.set_text_color(0, 0, 0)
pdf.set_fill_color(255, 255, 255)
pdf.ln(8)

# ── 마지막 핵심 정리 ──────────────────────────────────────
pdf.kr(9, bold=True)
pdf.cell(0, 5, '[ 내일 시험 전 최종 체크리스트 ]')
pdf.ln(5)
checklist = [
    '□  어셈블-링크-실행 사이클: .asm → Assembler → .obj → Linker → .exe',
    '□  SBYTE 범위: -128 ~ 127  /  BYTE 범위: 0 ~ 255',
    '□  폰 노이만 병목: CPU-메모리 속도 차이, 해결책: 캐시 메모리',
    '□  Fetch(메모리→명령어) / Decode(명령어 해독) / Execute(실행)',
    '□  Real address 주소 공간: 20비트 = 1MB',
    '□  CF=부호없는 오버플로(9번째 비트 올림)  OF=부호있는 오버플로',
    '□  리틀 엔디안: 낮은 주소에 LSB (하위 바이트) 먼저 저장',
    '□  CALL: ESP-=4 → [ESP]=복귀주소 → EIP=함수시작',
    '□  RET: EIP=[ESP] → ESP+=4',
    '□  LOOP: ECX-- → ECX≠0이면 점프  (시작 전 ECX=0 주의!)',
]
pdf.kr(9)
for item in checklist:
    pdf.set_x(22)
    pdf.cell(0, 6, item)
    pdf.ln(6)

# ══════════════════════════════════════════════════════════════
out = 'C:/Users/user/Desktop/System-programming-Example/docs/2025_예상_시스템프로그래밍_중간고사_해설.pdf'
pdf.output(out)
print(f'[완료] {out}')
