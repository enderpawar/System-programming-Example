const fs = require("fs");
const path = require("path");
const cheerio = require("cheerio");
const PDFDocument = require("pdfkit");

const baseDir = __dirname;
const input = path.join(baseDir, "기말고사_06-09_핵심개념_빈출정리.html");
const output = path.join(baseDir, "기말고사_06-09_핵심개념_빈출정리.pdf");
const fontRegular = "C:\\Windows\\Fonts\\malgun.ttf";
const fontBold = "C:\\Windows\\Fonts\\malgunbd.ttf";

const html = fs.readFileSync(input, "utf8");
const $ = cheerio.load(html, { decodeEntities: true });

const doc = new PDFDocument({
  size: "A4",
  margins: { top: 42, bottom: 42, left: 42, right: 42 },
  bufferPages: true,
  info: {
    Title: "기말 06-09장 핵심개념 빈출정리",
    Author: "System Programming Study Notes",
  },
});

doc.registerFont("regular", fontRegular);
doc.registerFont("bold", fontBold);
doc.pipe(fs.createWriteStream(output));

const page = {
  width: doc.page.width - doc.page.margins.left - doc.page.margins.right,
  left: doc.page.margins.left,
  right: doc.page.width - doc.page.margins.right,
  bottom: doc.page.height - doc.page.margins.bottom,
};

function clean(text) {
  return String(text || "")
    .replace(/\u00a0/g, " ")
    .replace(/[ \t]+\n/g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function ensure(height) {
  if (doc.y + height > page.bottom) doc.addPage();
}

function paragraph(text, options = {}) {
  text = clean(text);
  if (!text) return;
  const size = options.size || 10.2;
  ensure(size * 3);
  doc
    .font(options.bold ? "bold" : "regular")
    .fontSize(size)
    .fillColor(options.color || "#243041")
    .text(text, page.left, doc.y, {
      width: page.width,
      lineGap: options.lineGap ?? 2.5,
      align: options.align || "left",
    });
  doc.moveDown(options.after ?? 0.45);
}

function heading(text, level) {
  text = clean(text);
  if (!text) return;
  const sizes = { 1: 22, 2: 17, 3: 13 };
  const colors = { 1: "#111827", 2: "#0f766e", 3: "#1f3a5f" };
  ensure(level === 1 ? 52 : 34);
  if (level === 2 && doc.y > doc.page.margins.top + 20) doc.moveDown(0.25);
  doc
    .font("bold")
    .fontSize(sizes[level])
    .fillColor(colors[level])
    .text(text, page.left, doc.y, { width: page.width, lineGap: 1.5 });
  doc.moveDown(level === 1 ? 0.55 : 0.35);
}

function callout(text, kind) {
  text = clean(text);
  if (!text) return;
  const color = kind === "hot" ? "#b91c1c" : kind === "warn" ? "#a16207" : "#0f766e";
  const bg = kind === "hot" ? "#fff1f2" : kind === "warn" ? "#fff7ed" : "#f0fdfa";
  const startY = doc.y;
  const h = doc.heightOfString(text, { width: page.width - 22, lineGap: 2.5 }) + 18;
  ensure(h + 6);
  doc.roundedRect(page.left, doc.y, page.width, h, 5).fill(bg);
  doc.rect(page.left, doc.y, 4, h).fill(color);
  doc
    .font("regular")
    .fontSize(9.7)
    .fillColor("#243041")
    .text(text, page.left + 12, startY + 9, { width: page.width - 22, lineGap: 2.5 });
  doc.y = startY + h + 8;
}

function codeBlock(text) {
  text = clean(text);
  if (!text) return;
  const size = 8.7;
  const h = doc.heightOfString(text, { width: page.width - 18, lineGap: 1.7 }) + 16;
  ensure(Math.min(h, page.bottom - doc.page.margins.top));
  const startY = doc.y;
  doc.roundedRect(page.left, startY, page.width, h, 5).fill("#111827");
  doc
    .font("regular")
    .fontSize(size)
    .fillColor("#e5e7eb")
    .text(text, page.left + 9, startY + 8, { width: page.width - 18, lineGap: 1.7 });
  doc.y = startY + h + 8;
}

function list($items, ordered) {
  $items.each((i, el) => {
    const marker = ordered ? `${i + 1}.` : "•";
    const text = clean($(el).text());
    if (!text) return;
    ensure(28);
    const y = doc.y;
    doc.font("bold").fontSize(9.8).fillColor("#0f766e").text(marker, page.left, y, { width: 22 });
    doc.font("regular").fontSize(9.8).fillColor("#243041").text(text, page.left + 24, y, {
      width: page.width - 24,
      lineGap: 2.2,
    });
    doc.moveDown(0.25);
  });
  doc.moveDown(0.25);
}

function table($table) {
  const rows = [];
  $table.find("tr").each((_, tr) => {
    const cells = [];
    $(tr).children("th,td").each((__, td) => cells.push(clean($(td).text())));
    if (cells.length) rows.push(cells);
  });
  if (!rows.length) return;
  const cols = Math.max(...rows.map((r) => r.length));
  const colW = page.width / cols;
  doc.moveDown(0.2);
  rows.forEach((row, rIdx) => {
    const heights = row.map((cell) =>
      doc.heightOfString(cell, { width: colW - 10, lineGap: 1.5 })
    );
    const h = Math.max(24, Math.max(...heights) + 12);
    ensure(h + 2);
    const y = doc.y;
    row.forEach((cell, cIdx) => {
      const x = page.left + colW * cIdx;
      doc.rect(x, y, colW, h).fillAndStroke(rIdx === 0 ? "#eef2ff" : "#ffffff", "#d7dce3");
      doc
        .font(rIdx === 0 ? "bold" : "regular")
        .fontSize(8.6)
        .fillColor("#111827")
        .text(cell, x + 5, y + 6, { width: colW - 10, lineGap: 1.5 });
    });
    doc.y = y + h;
  });
  doc.moveDown(0.7);
}

function renderElement(el) {
  const $el = $(el);
  const tag = el.tagName ? el.tagName.toLowerCase() : "";
  if (!tag || tag === "script" || tag === "style" || tag === "nav") return;
  if (tag === "h1") return heading($el.text(), 1);
  if (tag === "h2") return heading($el.text(), 2);
  if (tag === "h3") return heading($el.text(), 3);
  if (tag === "p") return paragraph($el.text());
  if (tag === "pre" || tag === "codeblock") return codeBlock($el.text());
  if (tag === "ul" || tag === "ol") return list($el.children("li"), tag === "ol");
  if (tag === "table") return table($el);
  if ($el.hasClass("hot") || $el.hasClass("must") || $el.hasClass("warn")) {
    return callout($el.text(), $el.hasClass("hot") ? "hot" : $el.hasClass("warn") ? "warn" : "must");
  }
  if ($el.hasClass("mini")) {
    ensure(40);
    const startY = doc.y;
    doc.roundedRect(page.left, startY, page.width, 1, 0).fill("#d7dce3");
    doc.y = startY + 7;
    $el.children().each((_, child) => renderElement(child));
    return;
  }
  $el.children().each((_, child) => renderElement(child));
}

heading($("title").text() || "기말 06-09장 핵심개념 빈출정리", 1);
const subtitle = clean($("header .sub").first().text());
if (subtitle) paragraph(subtitle, { size: 10.5, color: "#5b6675" });
$("main").children().each((_, el) => renderElement(el));

const range = doc.bufferedPageRange();
for (let i = range.start; i < range.start + range.count; i++) {
  doc.switchToPage(i);
  doc.font("regular").fontSize(8).fillColor("#64748b");
  doc.text(`Page ${i + 1} / ${range.count}`, page.left, doc.page.height - 30, {
    width: page.width,
    align: "center",
  });
}

doc.end();
