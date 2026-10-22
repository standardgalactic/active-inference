#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-granite4.1:8b}"
OUTPUT="overview-summary.md"
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"
CHUNK_CHARS="${CHUNK_CHARS:-10000}"
CONTEXT_SIZE="${CONTEXT_SIZE:-16384}"

command -v python3 >/dev/null || {
    echo "Python 3 is required."
    exit 1
}

python3 - "$MODEL" "$OUTPUT" "$OLLAMA_URL" \
    "$CHUNK_CHARS" "$CONTEXT_SIZE" <<'PY'
import json
import os
import sys
import tempfile
import urllib.request
from datetime import datetime
from pathlib import Path

model = sys.argv[1]
output = Path(sys.argv[2])
url = sys.argv[3].rstrip("/") + "/api/generate"
chunk_chars = int(sys.argv[4])
context_size = int(sys.argv[5])

if chunk_chars < 1000:
    sys.exit("CHUNK_CHARS must be at least 1000.")

files = sorted(
    p for p in Path(".").glob("*.txt")
    if p.name != "file-list.txt"
)

if not files:
    sys.exit("No transcript .txt files found.")

def generate(prompt):
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
        "think": False,
        "options": {
            "num_ctx": context_size,
            "temperature": 0.2
        }
    }

    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )

    with urllib.request.urlopen(
        request, timeout=1800
    ) as response:
        result = json.load(response)

    if result.get("error"):
        raise RuntimeError(result["error"])

    text = result.get("response", "").strip()

    if not text:
        raise RuntimeError("Ollama returned an empty response.")

    return text


def split_text(text, limit):
    """Split text into bounded chunks, preferring line boundaries."""
    chunks = []
    current = ""

    for line in text.splitlines(keepends=True):
        while line:
            space = limit - len(current)

            if space == 0:
                chunks.append(current)
                current = ""
                space = limit

            if len(line) <= space:
                current += line
                break

            if current:
                chunks.append(current)
                current = ""
            else:
                chunks.append(line[:limit])
                line = line[limit:]

    if current.strip():
        chunks.append(current)

    return chunks


def reduce_summaries(parts, title, target_chars=10000):
    """Combine summaries in bounded groups until one remains."""
    level = 0

    while len(parts) > 1:
        level += 1
        groups = []
        group = []
        size = 0

        for part in parts:
            if group and size + len(part) > target_chars:
                groups.append(group)
                group = []
                size = 0

            group.append(part)
            size += len(part)

        if group:
            groups.append(group)

        # Avoid an endless reduction when only one group is formed.
        if len(groups) == 1:
            groups = [[p] for p in parts] if len(parts) > 1 else groups

        next_parts = []

        for i, group in enumerate(groups, 1):
            if len(group) == 1:
                next_parts.append(group[0])
                continue

            print(
                f"  Reduction level {level}, "
                f"group {i}/{len(groups)}",
                flush=True
            )

            prompt = f"""
Combine these partial summaries of "{title}" into
a coherent, shorter academic summary.

Preserve central arguments, important distinctions,
technical terminology, mathematical claims, and
substantive qualifications.

Do not invent claims or add outside information.
Return only the finished summary in connected prose.
Do not include reasoning steps or planning notes.

PARTIAL SUMMARIES:

{chr(10).join(group)}
"""
            next_parts.append(generate(prompt))

        if len(next_parts) >= len(parts):
            # Force pairwise reduction when grouping did not shrink.
            next_parts = []
            for i in range(0, len(parts), 2):
                pair = parts[i:i + 2]
                if len(pair) == 1:
                    next_parts.append(pair[0])
                else:
                    prompt = f"""
Condense these two summaries of "{title}" into
one shorter, coherent academic summary.

Preserve the substantive claims and qualifications.
Do not invent information.
Return only the summary.

{chr(10).join(pair)}
"""
                    next_parts.append(generate(prompt))

        parts = next_parts

    return parts[0]


def clean_output(text):
    """Defensive removal of ANSI controls."""
    import re

    text = re.sub(
        r"\x1b\[[0-?]*[ -/]*[@-~]",
        "",
        text
    )
    text = re.sub(
        r"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)",
        "",
        text
    )
    text = text.replace("\r", "")
    return text.strip()


sections = []
final_summaries = []

for index, path in enumerate(files, 1):
    title = path.stem.replace("_", " ")
    print(
        f"[{index}/{len(files)}] Processing {path.name}",
        flush=True
    )

    text = path.read_text(
        encoding="utf-8",
        errors="replace"
    )

    chunks = split_text(text, chunk_chars)

    if not chunks:
        print("  Skipping empty transcript.")
        continue

    partials = []

    for i, chunk in enumerate(chunks, 1):
        print(
            f"  Chunk {i}/{len(chunks)}",
            flush=True
        )

        prompt = f"""
Summarize this excerpt from the transcript "{title}".

Explain the actual arguments and conceptual distinctions.
Preserve mathematical ideas, terminology, qualifications,
and references to relevant researchers where present.

Do not invent information or supply outside research.
Do not write step-by-step reasoning or an outline.
Return only substantive academic prose in paragraphs.

TRANSCRIPT EXCERPT:

{chunk}
"""
        partials.append(clean_output(generate(prompt)))

    combined = reduce_summaries(partials, title)

    final_prompt = f"""
Produce a coherent academic overview of the lecture
"{title}" from the summary below.

Aim for approximately 500-800 words where the material
supports that length. Explain its central thesis,
principal arguments, mathematical or philosophical
claims, and important qualifications.

Do not invent missing details.
Avoid lists, reasoning steps, and introductory filler.
Return only the finished summary.

SOURCE SUMMARY:

{combined}
"""
    final = clean_output(generate(final_prompt))

    sections.append(f"## {title}\n\n{final}")
    final_summaries.append(f"{title}\n\n{final}")

print("Creating overall synthesis...", flush=True)

if len(final_summaries) == 1:
    synthesis_source = final_summaries[0]
else:
    synthesis_source = reduce_summaries(
        final_summaries,
        "Active Inference transcript collection"
    )

synthesis_prompt = f"""
Write a unified academic synthesis of this collection
of lecture summaries.

Identify shared research questions, theoretical
connections, differences in emphasis, and unresolved
problems.

Discuss active inference, predictive processing,
consciousness, interpretation, and automaticity
only insofar as the source material supports them.

Aim for approximately 800-1200 words where warranted.
Do not invent connections or outside references.
Write in connected prose, without numbered outlines,
reasoning steps, or planning notes.

SOURCE:

{synthesis_source}
"""

synthesis = clean_output(generate(synthesis_prompt))

document = (
    "# Active Inference: Transcript Overview\n\n"
    f"Generated: {datetime.now():%Y-%m-%d %H:%M:%S}\n\n"
    f"Model: `{model}`\n\n"
    + "\n\n".join(sections)
    + "\n\n## Overall Synthesis\n\n"
    + synthesis
    + "\n"
)

# Write atomically, preserving the previous overview on failure.
with tempfile.NamedTemporaryFile(
    mode="w",
    encoding="utf-8",
    dir=".",
    prefix=".overview-summary-",
    suffix=".tmp",
    delete=False
) as temp:
    temp.write(document)
    temporary_path = Path(temp.name)

os.replace(temporary_path, output)

print(f"\nComplete: {output}")
print(f"Summarized {len(final_summaries)} transcript(s).")
PY
