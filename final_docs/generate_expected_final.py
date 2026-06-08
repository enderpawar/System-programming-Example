"""
2025 System Programming expected final exam generator.

This script uses matplotlib only, because it is available in the current local
environment. It creates two PDF files in final_docs:
- 2025_예상_시스템프로그래밍_기말고사.pdf
- 2025_예상_시스템프로그래밍_기말고사_해설.pdf
"""
from pathlib import Path
import textwrap

import matplotlib
matplotlib.use("Agg")
from matplotlib import font_manager
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle


ROOT = Path(__file__).resolve().parent
FONT_R = "C:/Windows/Fonts/malgun.ttf"
FONT_B = "C:/Windows/Fonts/malgunbd.ttf"
KR = font_manager.FontProperties(fname=FONT_R)
KRB = font_manager.FontProperties(fname=FONT_B)
MONO = font_manager.FontProperties(family="DejaVu Sans Mono")


class SimplePDF:
    def __init__(self, path, title, footer):
        self.path = ROOT / path
        self.title = title
        self.footer = footer
        self.pdf = PdfPages(self.path)
        self.page_no = 0
        self.fig = None
        self.ax = None
        self.y = 0.0

    def close(self):
        if self.fig is not None:
            self._save_page()
        self.pdf.close()

    def _new_page(self):
        if self.fig is not None:
            self._save_page()
        self.page_no += 1
        self.fig = plt.figure(figsize=(8.27, 11.69))
        self.ax = self.fig.add_axes([0, 0, 1, 1])
        self.ax.set_xlim(0, 1)
        self.ax.set_ylim(0, 1)
        self.ax.axis("off")
        self.ax.text(0.07, 0.965, "System Programming", fontproperties=KRB, fontsize=10, va="top")
        self.ax.text(0.50, 0.965, self.title, fontproperties=KRB, fontsize=10, va="top", ha="center")
        self.ax.text(0.93, 0.965, f"page {self.page_no}", fontproperties=KRB, fontsize=10, va="top", ha="right")
        self.ax.plot([0.07, 0.93], [0.94, 0.94], color="black", linewidth=0.7)
        self.ax.text(0.5, 0.025, self.footer, fontproperties=KR, fontsize=8, color="0.45", ha="center", va="bottom")
        self.y = 0.915

    def _save_page(self):
        self.pdf.savefig(self.fig)
        plt.close(self.fig)
        self.fig = None
        self.ax = None

    def ensure(self, height):
        if self.fig is None:
            self._new_page()
        if self.y - height < 0.055:
            self._new_page()

    def text(self, s, size=9.2, bold=False, x=0.07, width=92, line_h=0.018, gap=0.006):
        lines = []
        for para in s.split("\n"):
            if not para:
                lines.append("")
                continue
            lines.extend(textwrap.wrap(para, width=width, break_long_words=False, replace_whitespace=False))
        height = line_h * max(1, len(lines)) + gap
        self.ensure(height)
        fp = KRB if bold else KR
        for line in lines:
            self.ax.text(x, self.y, line, fontproperties=fp, fontsize=size, va="top")
            self.y -= line_h
        self.y -= gap

    def question(self, label, pts, title):
        self.text(f"{label}. [{pts}pt] {title}", size=10, bold=True, width=86, line_h=0.020, gap=0.008)

    def sub(self, label, pts, title):
        self.text(f"({label}) [{pts}pt] {title}", size=9.3, bold=True, x=0.095, width=82, gap=0.004)

    def code(self, lines):
        line_h = 0.017
        height = line_h * len(lines) + 0.018
        self.ensure(height + 0.006)
        self.ax.add_patch(Rectangle((0.095, self.y - height + 0.006), 0.81, height, facecolor="#f4f4f4", edgecolor="#cccccc"))
        y = self.y - 0.006
        for line in lines:
            self.ax.text(0.112, y, line, fontproperties=MONO, fontsize=8.3, va="top")
            y -= line_h
        self.y -= height + 0.008

    def blank(self, height=0.055):
        self.ensure(height + 0.008)
        self.ax.add_patch(Rectangle((0.095, self.y - height), 0.81, height, fill=False, edgecolor="#777777", linewidth=0.6))
        self.y -= height + 0.012

    def line(self, label, width=0.48):
        self.ensure(0.026)
        self.ax.text(0.095, self.y, label, fontproperties=KR, fontsize=9.2, va="top")
        self.ax.add_patch(Rectangle((0.17, self.y - 0.015), width, 0.020, fill=False, edgecolor="#777777", linewidth=0.6))
        self.y -= 0.032

    def blue_header(self, label, pts, title):
        self.ensure(0.040)
        self.ax.add_patch(Rectangle((0.07, self.y - 0.026), 0.86, 0.030, facecolor="#224578", edgecolor="#224578"))
        self.ax.text(0.083, self.y - 0.003, f"{label}. [{pts}pt] {title}", fontproperties=KRB, fontsize=10, color="white", va="top")
        self.y -= 0.040


def build_exam():
    p = SimplePDF(
        "2025_예상_시스템프로그래밍_기말고사.pdf",
        "2025 Final Exam [Expected]",
        "2023/2024 기출 및 기말 범위 강의자료 기반 예상문제 - 학습용",
    )
    p.text(
        "Student No.___________________________    Name:_________________________\n"
        "특별한 언급이 없는 한, 32bit x86 protected mode에서 MASM을 사용한다고 가정한다.\n"
        "문항 스타일은 2023/2024 중간고사 및 기말고사 기출 형식을 반영하였다.",
        size=9,
        width=88,
    )

    p.question("1", 10, "Boolean 명령어와 CMP 명령어 실행 후 flag 및 조건 점프 결과를 답하시오.")
    p.code(["mov al, 11010110b", "and al, 00111100b", "cmp al, 20h"])
    p.text("(1) AND 실행 직후 AL, CF, OF, SF, ZF, PF 값을 쓰시오.", x=0.095, width=82)
    p.blank(0.045)
    p.text("(2) CMP 실행 직후 CF, OF, SF, ZF 값을 쓰고, JB와 JL이 각각 jump하는지 답하시오.", x=0.095, width=82)
    p.blank(0.050)

    p.question("2", 10, "다음 조건부 점프 명령어들의 실행 조건을 flag 값 또는 flag 간 관계로 표현하시오.")
    for name in ["JA", "JB", "JBE", "JE", "JG", "JL", "JGE", "JNE", "JO", "JS"]:
        p.line(f"{name} = ", 0.62)

    p.question("3", 10, "다음 C/C++ 코드를 조건 점프 명령어만 사용하여 MASM 코드로 작성하시오. VAR1~VAR5는 4byte signed int라 가정한다.")
    p.code(["if ((VAR1 <= VAR2) && (VAR3 != VAR4))", "    VAR5 = 1;", "else", "    VAR5 = 0;"])
    p.code([
        ".data", "VAR1 DWORD ?", "VAR2 DWORD ?", "VAR3 DWORD ?", "VAR4 DWORD ?", "VAR5 DWORD ?", "",
        ".code", "    mov eax, VAR1", "    cmp eax, VAR2", "", "    mov eax, VAR3", "    cmp eax, VAR4", "",
        "L_TRUE:", "    mov VAR5, 1", "    jmp L_END", "L_FALSE:", "    mov VAR5, 0", "L_END:",
    ])
    p.blank(0.075)

    p.question("4", 10, "shift 연산을 이용하여 unsigned 곱셈을 최적화한다고 할 때, 아래 IMUL을 사용하지 않는 코드로 완성하시오.")
    p.code([".data", "var DWORD ?", ".code", "mov eax, var", "imul eax, 45        ; eax = var * 45"])
    p.text("힌트: 45 = 32 + 8 + 4 + 1", x=0.095, width=82)
    p.blank(0.105)

    p.question("5", 15, "곱셈과 나눗셈 명령어에 관한 물음에 답하시오.")
    p.sub("1", 5, "다음 설명 중 옳지 않은 것을 모두 고르시오.")
    p.text(
        "1. MUL r/m8은 AL과 피연산자를 곱하고 결과를 AX에 저장한다.\n"
        "2. DIV에서 divisor가 0이면 divide error가 발생한다.\n"
        "3. IDIV 전에 CDQ를 사용하면 EAX의 부호가 EDX로 확장된다.\n"
        "4. unsigned DIV에서 dividend는 항상 divisor와 같은 크기이므로 overflow가 발생하지 않는다.\n"
        "5. IMUL의 2-operand 형식은 destination operand에 결과의 하위 절반을 저장할 수 있다.",
        x=0.095,
        width=82,
    )
    p.line("답: ", 0.42)
    p.sub("2", 10, "다음 C/C++ 식을 MASM으로 작성하시오. VAR1~VAR4는 signed DWORD이다.")
    p.code(["VAR4 = (-VAR1 * 7) / (VAR2 - VAR3);"])
    p.code([".data", "VAR1 SDWORD ?", "VAR2 SDWORD ?", "VAR3 SDWORD ?", "VAR4 SDWORD ?", ".code"])
    p.blank(0.120)

    p.question("6", 15, "다음 C의 swap 함수를 STDCALL calling convention을 사용하는 MASM 프로시저로 작성하시오. enter와 leave는 사용할 수 없다.")
    p.code(["void swap(int *a, int *b) {", "    int temp = *a;", "    *a = *b;", "    *b = temp;", "}"])
    p.code(["swap PROC", "", "", "", "", "", "", "", "", "", "", "", "", "swap ENDP"])
    p.blank(0.055)

    p.question("7", 10, "문제 6의 swap 프로시저를 STDCALL 방식으로 호출하는 코드를 작성하시오. invoke는 사용할 수 없다.")
    p.code([".data", "x DWORD 1", "y DWORD 2", ".code", "main PROC", "    ; swap(&x, &y)", "", "", "", "main ENDP"])
    p.blank(0.060)

    p.question("8", 10, "다음 프로그램이 실행된 직후 요구되는 값을 답하시오. 에러가 발생하면 어느 명령에서 어떤 에러인지 설명하시오.")
    p.sub("1", 5, "EAX의 값을 16진수로 답하시오.")
    p.code(["mov eax, -1", "mov cl, 4", "sar eax, cl", "shl eax, 1"])
    p.line("EAX = ", 0.42)
    p.sub("2", 5, "화면에 출력되는 문자 개수와 DIV 실행 결과를 설명하시오.")
    p.code(["mov ecx, 5", "L1: mov al, '*'", "    ; call WriteChar", "    loop L1", "mov ax, 00FFh", "mov bl, 10h", "div bl"])
    p.blank(0.060)

    p.question("9", 10, "부동소수점 표현에 관한 물음에 답하시오.")
    p.sub("1", 5, "10진수 0.15625가 REAL4 변수 num에 저장될 때, 메모리에 저장되는 4바이트 값을 낮은 주소부터 16진수로 쓰시오.")
    p.line("offset 100부터: ", 0.55)
    p.sub("2", 5, "REAL4의 16진수 bit pattern이 3FC00000h일 때 저장된 10진수 값을 쓰시오.")
    p.line("값: ", 0.42)

    p.question("10", 10, "메모리 관리에 관한 다음 설명 중 옳은 것을 모두 고르시오.")
    p.text(
        "1. 프로시저의 지역변수는 일반적으로 stack frame 안에 위치한다.\n"
        "2. HeapAlloc으로 할당한 블록은 프로시저가 ret되면 자동으로 해제된다.\n"
        "3. HeapCreate는 현재 프로세스 안에 private heap을 만들 수 있다.\n"
        "4. paging을 사용하는 시스템에서 linear address는 page translation을 거쳐 physical address로 변환된다.\n"
        "5. page fault는 요청한 page가 메모리에 없거나 접근 권한 문제가 있을 때 발생할 수 있다.",
        x=0.095,
        width=82,
    )
    p.line("답: ", 0.46)

    p.close()
    return p.path


def build_answers():
    p = SimplePDF(
        "2025_예상_시스템프로그래밍_기말고사_해설.pdf",
        "2025 Final Exam [Answers]",
        "2025 예상 기말고사 정답 및 해설 - 학습용",
    )
    p.blue_header("1", 10, "Boolean/CMP flags")
    p.text("AND 결과: AL=14h. AND는 CF=0, OF=0으로 만들고, 결과가 0이 아니므로 ZF=0, sign bit가 0이므로 SF=0, 14h는 1 bit가 2개라 PF=1.")
    p.text("CMP AL,20h는 14h-20h를 수행한다. 결과는 F4h이므로 CF=1, OF=0, SF=1, ZF=0. 따라서 unsigned 비교인 JB는 jump, signed 비교인 JL도 SF != OF이므로 jump.")

    p.blue_header("2", 10, "조건부 점프")
    p.text("JA: CF=0 AND ZF=0\nJB: CF=1\nJBE: CF=1 OR ZF=1\nJE: ZF=1\nJG: ZF=0 AND SF=OF\nJL: SF != OF\nJGE: SF=OF\nJNE: ZF=0\nJO: OF=1\nJS: SF=1")

    p.blue_header("3", 10, "조건문")
    p.code([
        "    mov eax, VAR1", "    cmp eax, VAR2", "    jg  L_FALSE",
        "    mov eax, VAR3", "    cmp eax, VAR4", "    je  L_FALSE",
        "L_TRUE:", "    mov VAR5, 1", "    jmp L_END", "L_FALSE:", "    mov VAR5, 0", "L_END:",
    ])

    p.blue_header("4", 10, "45배 shift 최적화")
    p.code([
        "mov eax, var", "mov ebx, eax", "shl eax, 5", "mov edx, ebx", "shl edx, 3",
        "add eax, edx", "mov edx, ebx", "shl edx, 2", "add eax, edx", "add eax, ebx",
    ])

    p.blue_header("5", 15, "MUL/DIV와 signed 식")
    p.text("(1) 옳지 않은 설명: 4. DIV의 dividend는 피연산자보다 2배 큰 AX, DX:AX, EDX:EAX 형태이며 quotient가 목적지 크기에 맞지 않으면 divide error가 발생한다.")
    p.code(["mov eax, VAR1", "neg eax", "imul eax, 7", "mov ebx, VAR2", "sub ebx, VAR3", "cdq", "idiv ebx", "mov VAR4, eax"])

    p.blue_header("6", 15, "STDCALL swap")
    p.code([
        "swap PROC", "    push ebp", "    mov  ebp, esp", "    sub  esp, 4",
        "    push eax", "    push ebx", "    mov  eax, [ebp+8]", "    mov  ebx, [eax]",
        "    mov  [ebp-4], ebx", "    mov  ebx, [ebp+12]", "    mov  edx, [ebx]",
        "    mov  [eax], edx", "    mov  edx, [ebp-4]", "    mov  [ebx], edx",
        "    pop  ebx", "    pop  eax", "    mov  esp, ebp", "    pop  ebp", "    ret  8", "swap ENDP",
    ])

    p.blue_header("7", 10, "STDCALL 호출")
    p.code(["    push OFFSET y", "    push OFFSET x", "    call swap"])
    p.text("STDCALL은 callee가 ret 8로 인자를 정리하므로 caller가 add esp,8을 수행하지 않는다.")

    p.blue_header("8", 10, "실행 결과")
    p.text("(1) EAX=FFFFFFFEh. -1을 산술 오른쪽 shift하면 계속 FFFFFFFFh이고, 이를 왼쪽으로 1bit shift하면 FFFFFFFEh.")
    p.text("(2) '*'가 5개 출력된다. 이후 AX=00FFh, BL=10h에서 255/16은 quotient=0Fh, remainder=0Fh이므로 AL=0Fh, AH=0Fh이며 divide error는 없다.")

    p.blue_header("9", 10, "REAL4")
    p.text("(1) 0.15625 = 1.25 * 2^-3. sign=0, exponent=124(7Ch), fraction=010... 이므로 bit pattern은 3E200000h. little endian 메모리에는 00 00 20 3E.")
    p.text("(2) 3FC00000h는 sign=0, exponent=127, fraction=.5이므로 1.5 * 2^0 = 1.5.")

    p.blue_header("10", 10, "메모리 관리")
    p.text("정답: 1, 3, 4, 5\nHeapAlloc으로 할당한 메모리는 stack frame 해제와 무관하므로 직접 HeapFree 등으로 반환해야 한다.")

    p.close()
    return p.path


if __name__ == "__main__":
    print(build_exam())
    print(build_answers())
