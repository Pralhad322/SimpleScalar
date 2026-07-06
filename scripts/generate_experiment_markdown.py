#!/usr/bin/env python3
"""Generate student-friendly Markdown handouts from experiment LaTeX files."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPERIMENTS = ROOT / "SimpleScalar" / "experiments"


def clean_inline(text: str) -> str:
    text = text.strip()
    text = re.sub(r"\\label\{[^}]*\}", "", text)
    text = re.sub(r"\\texttt\{([^{}]*)\}", r"`\1`", text)
    text = re.sub(r"\\path\{([^{}]*)\}", r"`\1`", text)
    text = re.sub(r"\\shortstack\{([^{}]*)\}", lambda m: m.group(1).replace(r"\\", " "), text)
    text = re.sub(r"\\href\{([^{}]*)\}\{([^{}]*)\}", r"[\2](\1)", text)
    text = text.replace(r"\_", "_")
    text = text.replace(r"\%", "%")
    text = text.replace(r"\&", "&")
    text = text.replace(r"\#", "#")
    text = text.replace(r"\$", "$")
    text = text.replace(r"\\", " ")
    text = text.replace("~", " ")
    return text.strip()


def table_row(line: str) -> list[str] | None:
    line = line.strip()
    if not line or line.startswith("%"):
        return None
    ignored = (
        r"\hline",
        r"\toprule",
        r"\midrule",
        r"\bottomrule",
        r"\endfirsthead",
        r"\endhead",
        r"\normalsize",
    )
    if line in ignored or line.startswith(r"\setlength") or line.startswith(r"\renewcommand"):
        return None
    if "&" not in line or not line.rstrip().endswith(r"\\"):
        return None
    line = re.sub(r"\\\\\s*$", "", line)
    cells = [clean_inline(cell) for cell in line.split("&")]
    return cells


def flush_table(rows: list[list[str]], out: list[str]) -> None:
    if not rows:
        return
    width = max(len(row) for row in rows)
    normalized = [row + [""] * (width - len(row)) for row in rows]
    header = normalized[0]
    out.append("| " + " | ".join(header) + " |")
    out.append("| " + " | ".join(["---"] * width) + " |")
    previous = header
    for row in normalized[1:]:
        if row == previous:
            continue
        out.append("| " + " | ".join(row) + " |")
        previous = row
    out.append("")


def convert_tex(path: Path) -> str:
    lines = path.read_text().splitlines()
    out: list[str] = []
    table_rows: list[list[str]] = []
    in_code = False
    in_table = False
    table_pending = ""
    in_document = False
    ordered = False
    unordered = False
    title = None

    for raw in lines:
        line = raw.rstrip()

        m = re.match(r"\\title\{(.+)\}", line)
        if m:
            title = clean_inline(m.group(1))
            continue

        if line.startswith(r"\begin{document}"):
            in_document = True
            if title:
                out.append(f"# {title}")
                out.append("")
            continue
        if not in_document:
            continue
        if line.startswith(r"\end{document}"):
            break

        if line.startswith(r"\begin{lstlisting}"):
            flush_table(table_rows, out)
            table_rows = []
            in_code = True
            out.append("```bash")
            continue
        if line.startswith(r"\end{lstlisting}"):
            in_code = False
            out.append("```")
            out.append("")
            continue
        if in_code:
            out.append(line)
            continue

        if line.startswith(r"\begin{table}") or line.startswith(r"\begin{center}"):
            in_table = True
            table_rows = []
            table_pending = ""
            continue
        if line.startswith(r"\begin{tabular") or line.startswith(r"\begin{longtable}"):
            in_table = True
            table_rows = []
            table_pending = ""
            continue
        if line.startswith(r"\end{tabular") or line.startswith(r"\end{longtable}"):
            if table_pending.strip():
                row = table_row(table_pending)
                if row:
                    table_rows.append(row)
                table_pending = ""
            flush_table(table_rows, out)
            table_rows = []
            continue
        if line.startswith(r"\end{table}") or line.startswith(r"\end{center}"):
            if table_pending.strip():
                row = table_row(table_pending)
                if row:
                    table_rows.append(row)
                table_pending = ""
            flush_table(table_rows, out)
            table_rows = []
            in_table = False
            continue
        if in_table:
            caption = re.match(r"\\caption\{(.+)\}", line)
            if caption:
                out.append(f"**Table: {clean_inline(caption.group(1))}**")
                out.append("")
                continue
            if line.strip() == r"\profiletableheader":
                table_rows.append(
                    [
                        "Benchmark",
                        "Total insts",
                        "Load",
                        "Store",
                        "Uncond. branch",
                        "Cond. branch",
                        "Integer compute",
                        "Floating pt. compute",
                    ]
                )
                continue
            if line.strip().startswith(r"\footnotesize"):
                out.append(clean_inline(line.replace(r"\footnotesize", "", 1)))
                out.append("")
                continue
            if table_pending:
                table_pending = (table_pending + " " + line).strip()
                if table_pending.rstrip().endswith(r"\\"):
                    row = table_row(table_pending)
                    if row:
                        table_rows.append(row)
                    table_pending = ""
                continue
            row = table_row(line)
            if row:
                table_rows.append(row)
            elif "&" in line:
                table_pending = (table_pending + " " + line).strip()
                if table_pending.rstrip().endswith(r"\\"):
                    row = table_row(table_pending)
                    if row:
                        table_rows.append(row)
                    table_pending = ""
            continue

        if line.startswith(r"\maketitle") or line.startswith(r"\author") or line.startswith(r"\date"):
            continue
        if line.startswith(r"\begin{enumerate}"):
            ordered = True
            continue
        if line.startswith(r"\end{enumerate}"):
            ordered = False
            out.append("")
            continue
        if line.startswith(r"\begin{itemize}"):
            unordered = True
            continue
        if line.startswith(r"\end{itemize}"):
            unordered = False
            out.append("")
            continue

        section = re.match(r"\\section\{(.+)\}", line)
        if section:
            out.append(f"## {clean_inline(section.group(1))}")
            out.append("")
            continue
        subsection = re.match(r"\\subsection\{(.+)\}", line)
        if subsection:
            out.append(f"### {clean_inline(subsection.group(1))}")
            out.append("")
            continue

        item = re.match(r"\\item\s*(.*)", line)
        if item:
            prefix = "1." if ordered else "-"
            out.append(f"{prefix} {clean_inline(item.group(1))}")
            continue

        cleaned = clean_inline(line)
        if cleaned:
            out.append(cleaned)
        elif out and out[-1] != "":
            out.append("")

    while out and out[-1] == "":
        out.pop()
    return "\n".join(out) + "\n"


def main() -> None:
    for tex in sorted(EXPERIMENTS.glob("*.tex")):
        md = tex.with_suffix(".md")
        md.write_text(convert_tex(tex))
        print(md.relative_to(ROOT))


if __name__ == "__main__":
    main()
