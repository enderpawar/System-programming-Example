"""
2025 System Programming 예상 중간고사 문제집 PDF 생성기
기출 분석 기반 (2023, 2024 기출 참조)
"""
from fpdf import FPDF

FONT_R  = 'C:/Windows/Fonts/malgun.ttf'
FONT_B  = 'C:/Windows/Fonts/malgunbd.ttf'


def has_korean(s):
    return any('가' <= c <= '힣' or 'ᄀ' <= c <= 'ᇿ' for c in s)


class ExamPDF(FPDF):
    def __init__(self):
        super().__init__(orientation='P', unit='mm', format='A4')
        self.add_font('KR',  '',  FONT_R)
        self.add_font('KR',  'B', FONT_B)
        self.set_margins(20, 25, 20)
        self.set_auto_page_break(auto=True, margin=20)

    def header(self):
        self.set_font('KR', 'B', 10)
        w = self.w - 40
        self.cell(w * 0.35, 6, 'System Programming', border=0)
        self.cell(w * 0.38, 6, '2025 Mid-Term Exam  [예상문제]', border=0, align='C')
        self.cell(w * 0.27, 6, f'page {self.page_no()} / {{nb}}', border=0, align='R')
        self.ln(2)
        self.set_line_width(0.5)
        self.line(20, self.get_y(), self.w - 20, self.get_y())
        self.set_line_width(0.4)
        self.ln(4)

    def footer(self):
        self.set_y(-13)
        self.set_font('KR', '', 8)
        self.set_text_color(130, 130, 130)
        self.cell(0, 6, '기출 분석 기반 2025 예상 문제 — 학습 목적으로만 사용할 것', align='C')
        self.set_text_color(0, 0, 0)

    # ── 폰트 헬퍼 ──────────────────────────────────────────
    def kr(self, size=10, bold=False):
        self.set_font('KR', 'B' if bold else '', size)

    def mono(self, size=8.5):
        self.set_font('Courier', '', size)

    # ── 레이아웃 헬퍼 ──────────────────────────────────────
    def question_title(self, num, pt, text):
        self.kr(10, bold=True)
        label = f'{num}. [{pt}pt]  '
        self.cell(self.get_string_width(label), 6, label)
        self.kr(10, bold=False)
        self.multi_cell(0, 6, text, border=0)
        self.ln(1)

    def sub_q(self, label, pt, text, indent=8):
        self.set_x(20 + indent)
        self.kr(9.5, bold=True)
        prefix = f'({label}) [{pt}pt]  '
        self.cell(self.get_string_width(prefix), 5.5, prefix)
        self.kr(9.5)
        self.multi_cell(0, 5.5, text, border=0)
        self.ln(0.5)

    def body(self, text, indent=8, size=9.5, lh=5.5):
        self.set_x(20 + indent)
        self.kr(size)
        self.multi_cell(self.w - 40 - indent, lh, text, border=0)

    def bullet(self, items, indent=12):
        for text in items:
            self.set_x(20 + indent)
            self.kr(9.5)
            self.multi_cell(self.w - 40 - indent, 5.5, text, border=0)
            self.ln(0.5)

    def divider(self):
        self.ln(2)
        self.set_draw_color(180, 180, 180)
        self.set_line_width(0.2)
        self.line(20, self.get_y(), self.w - 20, self.get_y())
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.4)
        self.ln(3)

    def code_block(self, lines, indent=8):
        """ASCII only code block (gray bg)"""
        self.set_fill_color(242, 242, 242)
        self.set_draw_color(190, 190, 190)
        self.set_line_width(0.2)
        block_w = self.w - 40 - indent
        lh = 4.8
        pad = 2
        total_h = lh * len(lines) + pad * 2
        x0, y0 = 20 + indent, self.get_y()
        self.rect(x0, y0, block_w, total_h, 'DF')
        self.set_font('Courier', '', 8.5)
        self.set_y(y0 + pad)
        for line in lines:
            self.set_x(x0 + pad)
            self.cell(block_w - pad * 2, lh, line, border=0)
            self.ln(lh)
        self.set_fill_color(255, 255, 255)
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.4)
        self.ln(1)

    def flag_table(self, flags=('CF', 'OF', 'SF', 'ZF'), indent=10):
        self.set_x(20 + indent)
        self.kr(9, bold=True)
        cw = 22
        for f in flags:
            self.cell(cw, 6, f, border=1, align='C')
        self.ln(6)
        self.set_x(20 + indent)
        for _ in flags:
            self.cell(cw, 8, '', border=1, align='C')
        self.ln(9)

    def answer_box(self, label='답:', width=70, indent=8):
        self.set_x(20 + indent)
        self.kr(9.5)
        self.cell(self.get_string_width(label) + 2, 6, label)
        self.rect(self.get_x(), self.get_y(), width, 6)
        self.ln(9)

    def write_area(self, h=24, indent=8):
        x0, y0 = 20 + indent, self.get_y()
        w = self.w - 40 - indent
        self.set_draw_color(190, 190, 190)
        self.set_line_width(0.2)
        self.rect(x0, y0, w, h)
        lh = 6
        for i in range(1, int(h // lh)):
            self.line(x0 + 2, y0 + i * lh, x0 + w - 2, y0 + i * lh)
        self.set_y(y0 + h + 2)
        self.set_draw_color(0, 0, 0)
        self.set_line_width(0.4)

    def two_col_table(self, left_lines, right_lines, lw=80, rw=90, lh=4.5, indent=0):
        """두 컬럼 코드 비교 테이블"""
        self.set_x(20 + indent)
        self.kr(9, bold=True)
        self.cell(lw, 5.5, 'C/C++ 코드', border=1, align='C')
        self.cell(rw, 5.5, 'Assembly (MASM)', border=1, align='C')
        self.ln(5.5)
        self.set_font('Courier', '', 8.2)
        max_r = max(len(left_lines), len(right_lines))
        for i in range(max_r):
            self.set_x(20 + indent)
            lt = left_lines[i]  if i < len(left_lines)  else ''
            rt = right_lines[i] if i < len(right_lines) else ''
            self.set_fill_color(248, 248, 248)
            self.cell(lw, lh, '  ' + lt, border='LR', fill=True)
            self.set_fill_color(255, 255, 255)
            self.cell(rw, lh, '  ' + rt, border='LR', fill=False)
            self.ln(lh)
        self.set_x(20 + indent)
        self.kr(9)
        self.cell(lw, 0, '', border='T')
        self.cell(rw, 0, '', border='T')
        self.ln(4)


# ══════════════════════════════════════════════════════════════
# PDF 생성
# ══════════════════════════════════════════════════════════════
pdf = ExamPDF()
pdf.alias_nb_pages()
pdf.set_line_width(0.4)

# ══════════════════════════════════════════════════════════════
# PAGE 1
# ══════════════════════════════════════════════════════════════
pdf.add_page()

pdf.kr(10)
pdf.cell(95, 6, '학번: _______________________________')
pdf.cell(95, 6, '이름: _______________________')
pdf.ln(3)
pdf.kr(8.5)
pdf.set_text_color(80, 80, 80)
pdf.multi_cell(0, 5,
    '  ※ 특별한 언급이 없는 한, 32bit x86 프로세서의 protected mode에서 MASM을 사용함을 가정함\n'
    '  ※ 총 9문제, 100점 만점  |  답은 각 문제 아래 답안 영역에 작성')
pdf.set_text_color(0, 0, 0)
pdf.ln(3)

# ── Q1 [10pt] ──────────────────────────────────────────────
pdf.question_title('1', 10,
    '다음은 Assembly Language 및 어셈블-링크-실행 사이클에 관한 설명이다. '
    '옳지 않은 설명을 모두 고르시오.')
pdf.answer_box('답: ____________________', width=90, indent=8)

pdf.bullet([
    '①  Assembly Language는 기계(CPU)에 의해 직접 실행될 수 있는 언어이다.',
    '②  Assembly Language 소스 파일(.asm)은 Assembler에 의해 Object 파일(.obj)로 변환되며,\n'
    '       이 Object 파일은 Linker 없이도 바로 실행이 가능하다.',
    '③  Linker는 Object 파일과 라이브러리(.lib) 파일을 결합하여 실행 파일(.exe)을 생성한다.',
    '④  Assembly Language는 Machine Language와 1대1 대응 관계에 있으므로,\n'
    '       소스 코드의 각 라인은 반드시 하나의 Machine Language 명령어로 번역된다.',
    '⑤  Assembly Language는 특정 CPU 아키텍처에 종속적이므로,\n'
    '       C/C++와 같은 High Level Language에 비해 이식성(portability)이 낮다.',
], indent=12)

pdf.divider()

# ── Q2 [5pt] ───────────────────────────────────────────────
pdf.question_title('2', 5,
    'x86 시스템에서 부호있는 8비트 정수(SBYTE)의 범위를 쓰시오. (계산식으로 표현해도 됨)')
pdf.set_x(28)
pdf.kr(9.5)
pdf.cell(14, 6, '최소: ')
pdf.rect(pdf.get_x(), pdf.get_y(), 55, 6)
pdf.set_x(pdf.get_x() + 60)
pdf.cell(14, 6, '  ~  최대: ')
pdf.rect(pdf.get_x(), pdf.get_y(), 55, 6)
pdf.ln(10)

pdf.divider()

# ── Q3 [10pt] ──────────────────────────────────────────────
pdf.question_title('3', 10,
    '폰 노이만(Von Neumann) 컴퓨터 구조에 관한 다음 물음에 답하시오.')

pdf.sub_q('1', 4, '이전의 컴퓨터들과 대비되는 폰 노이만 컴퓨터 구조의 주된 특징은 무엇인가?')
pdf.write_area(h=18, indent=10)

pdf.sub_q('2', 3, '폰 노이만 구조의 주된 병목지점(Bottleneck)을 설명하시오.')
pdf.write_area(h=15, indent=10)

pdf.sub_q('3', 3, '3-②의 병목지점을 완화하기 위해 일반적으로 널리 쓰이는 방법을 설명하시오.')
pdf.write_area(h=15, indent=10)

pdf.divider()

# ══════════════════════════════════════════════════════════════
# PAGE 2
# ══════════════════════════════════════════════════════════════
pdf.add_page()

# ── Q4 [10pt] ──────────────────────────────────────────────
pdf.question_title('4', 10,
    '다음은 CPU 명령어 실행 사이클(Instruction Execution Cycle)에서 수행하는 '
    '핵심 세 단계에 대한 설명이다. 주어진 괄호를 채우시오.\n'
    '(괄호 하나당 하나의 단어/구문만 필요하며, 단어들은 서로 중복될 수 있음)')
pdf.ln(1)

# 표
col_a, col_b = 40, 130
pdf.set_x(28)
pdf.kr(9, bold=True)
pdf.cell(col_a, 6, '단계', border=1, align='C')
pdf.cell(col_b, 6, '설명', border=1, align='C')
pdf.ln(6)
pdf.kr(9)
rows = [
    ('1단계  (Fetch)',    '( 1)                    )(으)로부터  ( 2)                      )을/를 가져온다.'),
    ('2단계  (Decode)',   '( 3)                    )을/를           ( 4)                      )한다.'),
    ('3단계  (Execute)',  '( 5)                    )을/를           ( 6)                      )한다.'),
]
for step, desc in rows:
    pdf.set_x(28)
    pdf.cell(col_a, 8, step, border=1, align='C')
    pdf.cell(col_b, 8, '  ' + desc, border=1)
    pdf.ln(8)
pdf.ln(3)

pdf.divider()

# ── Q5 [10pt] ──────────────────────────────────────────────
pdf.question_title('5', 10,
    'x86 프로세서의 real address 모드에서는 16비트 segment와 16비트 offset을 이용해 '
    '물리 주소를 구성한다.\n'
    'real address 모드에서 접근 가능한 주소 공간의 최대 크기를 계산하시오. (계산 과정 필요)')

pdf.body('물리 주소 = segment × 16 + offset   (segment, offset 각각 16비트)', indent=10)
pdf.body('(최댓값: segment = FFFFh, offset = FFFFh)', indent=10)
pdf.ln(1)
pdf.write_area(h=32, indent=10)

pdf.divider()

# ── Q6 [15pt] ──────────────────────────────────────────────
pdf.question_title('6', 15,
    '다음 어셈블리 코드의 마지막 명령어 실행 후 플래그 값을 답하시오.')

pdf.sub_q('1', 6, '아래 코드 실행 후 CF, OF, SF, ZF 값을 표에 채우시오. (세트=1, 클리어=0)', indent=8)
pdf.code_block([
    'MOV AX, 1A64h    ; AL = 64h (= 100)',
    'MOV BX, 2B50h    ; BL = 50h (= 80)',
    'ADD AL, BL       ; 8bit ADD',
], indent=10)
pdf.flag_table(flags=('CF', 'OF', 'SF', 'ZF'), indent=10)

pdf.sub_q('2', 9,
    'CPU가 각 플래그를 어떻게 탐지하는지 이진수 계산 과정과 함께 설명하시오.', indent=8)
pdf.body('1) CF  (Carry Flag) :', indent=12)
pdf.write_area(h=14, indent=12)
pdf.body('2) OF  (Overflow Flag) :', indent=12)
pdf.write_area(h=14, indent=12)
pdf.body('3) SF / ZF :', indent=12)
pdf.write_area(h=10, indent=12)

# ══════════════════════════════════════════════════════════════
# PAGE 3
# ══════════════════════════════════════════════════════════════
pdf.add_page()

# ── Q7 [15pt] ──────────────────────────────────────────────
pdf.question_title('7', 15,
    '다음 어셈블리 프로그램들에 대한 물음에 답하시오.')

# Q7-(1)  리틀 엔디안 메모리 배치
pdf.sub_q('1', 5,
    '다음 data segment가 메모리에 저장될 때, #1 ~ #4에 들어갈 16진수 값을 채우시오.\n'
    '(그림에서 위쪽이 더 낮은 주소이며, x86 리틀 엔디안 방식으로 저장됨)', indent=8)
pdf.code_block([
    '.data',
    '    ARRAY  WORD  0AB12h, 0CD34h',
], indent=10)

y_mem = pdf.get_y()
# 왼쪽: 메모리 표
pdf.set_x(30)
pdf.kr(8.5, bold=True)
pdf.cell(32, 5.5, '주소 (오프셋)', border=1, align='C')
pdf.cell(28, 5.5, '저장된 값', border=1, align='C')
pdf.ln(5.5)
for lbl in ['ARRAY+0  (#1)', 'ARRAY+1  (#2)', 'ARRAY+2  (#3)', 'ARRAY+3  (#4)']:
    pdf.set_x(30)
    pdf.kr(8.5)
    pdf.cell(32, 7, lbl, border=1)
    pdf.cell(28, 7, '', border=1, align='C')
    pdf.ln(7)

# 오른쪽: 힌트박스
pdf.set_xy(103, y_mem)
pdf.kr(8.5, bold=True)
pdf.cell(84, 5, '[힌트] 리틀 엔디안(Little-Endian) 저장 규칙', border='TLR', align='C')
pdf.ln(5)
hint_lines = [
    '낮은 주소에 LSB(하위 바이트)를 먼저 저장',
    'WORD 0AB12h -> [12h][ABh] 순서로 저장',
    'WORD 0CD34h -> [34h][CDh] 순서로 저장',
    'ARRAY 시작 주소부터 순서대로 채울 것',
]
for h in hint_lines:
    pdf.set_x(103)
    pdf.kr(8)
    pdf.cell(84, 5.5, '  ' + h, border='LR')
    pdf.ln(5.5)
pdf.set_x(103)
pdf.cell(84, 0, '', border='BLR')
pdf.ln(4)

# Q7-(2)  WORD PTR / 리틀 엔디안
pdf.sub_q('2', 5,
    '다음 프로그램 실행 후 AX에 저장될 값을 16진수로 쓰시오.\n'
    '(어셈블 오류 발생 시: 어느 구문에서 왜 오류인지 설명할 것)', indent=8)
pdf.code_block([
    '.data',
    '    VAR1  WORD   0FFFFh',
    '    VAR2  SWORD  256         ; = 0100h',
    '.code',
    '    MOV ESI, OFFSET VAR1',
    '    MOV AX,  WORD PTR [ESI+1]',
], indent=10)
pdf.set_x(30)
pdf.kr(9.5)
pdf.cell(28, 6, 'AX = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 55, 6)
pdf.set_x(pdf.get_x() + 60)
pdf.kr(8.5)
pdf.set_text_color(80,80,80)
pdf.cell(0, 6, '(오류 발생 시 이유: _________________________________)')
pdf.set_text_color(0,0,0)
pdf.ln(9)

# Q7-(3)  LOOP 프로그램
pdf.sub_q('3', 5,
    '다음 프로그램의 실행 결과 SUM에 저장될 값을 10진수로 쓰시오.\n'
    '(어셈블 오류 발생 시: 어느 구문에서 왜 오류인지 설명할 것)', indent=8)
pdf.code_block([
    '.data',
    '    ARRAY  BYTE  10, 20, 30, 40, 50',
    '    SUM    BYTE  0',
    '.code',
    '    MOV ECX, LENGTHOF ARRAY',
    '    MOV ESI, 0',
    'L1:',
    '    ADD SUM, ARRAY[ESI]',
    '    INC ESI',
    '    LOOP L1',
], indent=10)
pdf.set_x(30)
pdf.kr(9.5)
pdf.cell(28, 6, 'SUM = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 55, 6)
pdf.set_x(pdf.get_x() + 60)
pdf.kr(8.5)
pdf.set_text_color(80,80,80)
pdf.cell(0, 6, '(오류 발생 시 이유: _________________________________)')
pdf.set_text_color(0,0,0)
pdf.ln(4)

# ══════════════════════════════════════════════════════════════
# PAGE 4  (Q8 + Q9)
# ══════════════════════════════════════════════════════════════
pdf.add_page()

# ── Q8 [10pt] ──────────────────────────────────────────────
pdf.question_title('8', 10,
    '다음의 C/C++ 프로그램을 어셈블리어 프로그램으로 변환하도록 빈칸 (#1), (#2)를 채우시오.')

cpp = [
    'char arr[] = {10, 20, 30, 40, 50};',
    'char sum = 0;',
    'for (int i = 0; i < sizeof(arr); ++i)',
    '{',
    '    sum += arr[i];',
    '}',
]
asm = [
    '.data',
    '    ARR  BYTE  10, 20, 30, 40, 50',
    '    SUM  BYTE  0',
    '.code',
    '    (#1)____________________________',
    '    MOV ESI, 0',
    'L1:',
    '    ADD SUM, ARR[ESI]',
    '    INC ESI',
    '    (#2)____________________________',
]
pdf.two_col_table(cpp, asm, lw=82, rw=88, indent=0)

pdf.kr(9.5)
pdf.set_x(28)
pdf.cell(20, 6, '(#1) = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 110, 6)
pdf.ln(8)
pdf.set_x(28)
pdf.cell(20, 6, '(#2) = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 110, 6)
pdf.ln(8)

# ── Q9 [15pt] ──────────────────────────────────────────────
pdf.question_title('9', 15,
    '스택(Stack)과 프로시저(Procedure)에 관한 다음 물음에 답하시오.')

# Q9-(1)
pdf.sub_q('1', 5,
    'call MySub 명령이 실행된 직후 ESP와 EIP에 저장될 값을 예상하시오.\n'
    '(단, call 명령 실행 직전의 ESP = 0000FF00h 로 가정)', indent=8)
pdf.code_block([
    'main PROC',
    '    00000010    push eax',
    '    00000011    call MySub       ; <<-- Execute this CALL',
    '    00000016    mov  ebx, eax',
    '    ...',
    'MySub PROC',
    '    00000040    mov  eax, edx',
    '    ...',
    '    ret',
    'MySub ENDP',
], indent=10)
pdf.set_x(30)
pdf.kr(9.5)
pdf.cell(32, 6, 'EIP = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 55, 6)
pdf.set_x(135)
pdf.cell(20, 6, 'ESP = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 40, 6)
pdf.ln(10)

# Q9-(2)
pdf.sub_q('2', 10,
    '다음 프로그램에서 ★ 표시된 명령(ADD eax, 64)이 실행된 직후,\n'
    'ESP가 가리키고 있는 값을 16진수로 쓰시오.', indent=8)
pdf.code_block([
    '.code',
    'main PROC',
    '    MOV eax, -1         ; EAX = FFFFFFFFh',
    '    MOV ax,  128        ; AX  = 0080h  (upper 16 bits preserved)',
    '    PUSH eax',
    '    CALL mysub',
    '[*] ADD eax, 64         ; <<-- What does ESP point to at THIS moment?',
    '    INVOKE ExitProcess, 0',
    'main ENDP',
    '',
    'mysub PROC',
    '    ADD eax, 32',
    '    ret',
    'mysub ENDP',
    'END main',
], indent=10)

pdf.body('[ 풀이 과정: 각 명령 실행 후 EAX, ESP 변화를 단계별로 기술 ]', indent=10)
pdf.write_area(h=30, indent=10)

pdf.set_x(30)
pdf.kr(9.5)
pdf.cell(50, 7, 'ESP가 가리키는 값 = ')
pdf.rect(pdf.get_x(), pdf.get_y(), 65, 7)
pdf.ln(10)

pdf.divider()

# ── 메모 공간 ───────────────────────────────────────────────
pdf.kr(9, bold=True)
pdf.set_text_color(100, 100, 100)
pdf.cell(0, 5, '[ 여분 공간 — 검산, 메모 등 ]', align='L')
pdf.set_text_color(0, 0, 0)
pdf.ln(4)
pdf.write_area(h=28, indent=0)

# ══════════════════════════════════════════════════════════════
# 저장
# ══════════════════════════════════════════════════════════════
out = 'C:/Users/user/Desktop/System-programming-Example/docs/2025_예상_시스템프로그래밍_중간고사.pdf'
pdf.output(out)
print(f'[완료] {out}')
