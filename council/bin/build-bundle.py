#!/usr/bin/env python3
"""Assemble the blinded contribution bundle for Sprint 1.

Extracts the abstract and the three contribution candidates from the
manuscript. Each candidate is rendered as its claim and the figures that
support it, with no editorial commentary on the claim's significance --
an earlier draft carried asides ("a prior reviewer judged this close to
definitional", "the paper notes, but does not lead with...") that told the
panel what to think of a candidate rather than letting them judge it, and
those asides landed unevenly across the three. The frame text around the
candidates is written here rather than quoted from the paper because the
paper's own framing is exactly what is under review: quoting it would ask
the panel to endorse the current emphasis instead of choosing one.

Deterministic: the same manuscript produces the same bytes, so the hash in
the council log identifies exactly what was reviewed.
"""
import hashlib
import os
import pathlib
import re
import sys

_SELF = pathlib.Path(__file__).resolve().parents[2]
_REPO = pathlib.Path(os.environ.get("DEFIFORMAL_ROOT", _SELF))
TEX = _REPO / "paper" / "atlas.tex"
OUT = _REPO / "council" / "sprint1" / "BUNDLE-blinded.md"

def between(text, start_pat, end_pat):
    a = re.search(start_pat, text)
    if not a:
        return None
    b = re.search(end_pat, text[a.end():])
    return text[a.end(): a.end() + b.start()].strip() if b else None

def env(text, label):
    """The environment body carrying \\label{label}, with the environment's
    optional \\begin{env}[title] argument dropped. The bundle supplies its
    own heading (CANDIDATE A/B/C); the manuscript's internal title is
    redundant, and on a document whose cover page says author identity is
    sealed, a bracketed phrase standing alone reads as a redaction marker
    rather than a title.
    """
    i = text.find("\\label{%s}" % label)
    if i < 0:
        return None
    start = text.rfind("\\begin{", 0, i)
    if start < 0:
        return None
    endm = re.search(r"\\end\{[a-z]+\}", text[i:])
    if not endm:
        return None
    body = text[start: i + endm.end()]
    return re.sub(r"^(\\begin\{[a-z]+\})\[[^\]]*\]", r"\1", body).strip()

def strip_tex(s):
    # Escaped braces (\{ \}) are literal characters, not grouping syntax --
    # e.g. "$\{Ct, Ex, Li\}$" denotes the set {Ct, Ex, Li}. Shield them before
    # the macro/brace stripping below, then restore as plain "{" "}"
    # afterwards. Left unshielded, the macro regex ignores them (no letter
    # follows the backslash) and the brace-stripping regex then removes only
    # the brace, orphaning the backslash in the output.
    s = s.replace("\\{", "\x00LBRACE\x00").replace("\\}", "\x00RBRACE\x00")
    s = re.sub(r"\\label\{[^}]*\}", "", s)
    s = re.sub(r"\\ref\{[^}]*\}", "[ref]", s)
    s = re.sub(r"\\(begin|end)\{[a-z]+\}", "", s)
    s = re.sub(r"\\[a-zA-Z]+\*?", "", s)
    s = s.replace("$", "").replace("~", " ").replace("\\%", "%")
    # LaTeX's --- em-dash convention is a mechanical-extraction tell if left
    # as three literal hyphens; every hand-written line in this bundle uses
    # a real em dash, so normalise the extracted prose to match.
    s = s.replace("---", "\u2014")
    s = re.sub(r"[{}]", "", s)
    s = s.replace("\x00LBRACE\x00", "{").replace("\x00RBRACE\x00", "}")
    return re.sub(r"\n{3,}", "\n\n", s).strip()

def main():
    if not TEX.is_file():
        print("build-bundle: BLOCKED - no manuscript at %s" % TEX, file=sys.stderr)
        return 3
    tex = TEX.read_text(encoding="utf-8")

    abstract = between(tex, r"\\begin\{abstract\}", r"\\end\{abstract\}")
    perps = env(tex, "meas:perps")
    pairs = env(tex, "meas:pairs")
    if not (abstract and perps and pairs):
        print("build-bundle: BLOCKED - an anchor is missing "
              "(abstract=%s meas:perps=%s meas:pairs=%s)"
              % (bool(abstract), bool(perps), bool(pairs)), file=sys.stderr)
        return 3

    abstract_prose = strip_tex(abstract)
    perps_prose = strip_tex(perps)
    pairs_prose = strip_tex(pairs)
    # meas:pairs closes with "Table~\ref{tab:composition} gives the
    # distribution by category". strip_tex turns the \ref into the
    # placeholder "[ref]", but the table itself isn't part of this bundle,
    # so the sentence points a blinded reader at nothing they can see, and
    # the surviving bracket reads like a redaction on a document whose cover
    # page says identity is sealed. Drop the sentence; the category
    # breakdown it points to isn't a figure this comparison depends on.
    pairs_prose = re.sub(
        r"\s*Table \[ref\] gives the distribution by category\.$", "", pairs_prose)

    L = []
    L.append("# Three candidate results — which one is the contribution?")
    L.append("")
    L.append("A formal vocabulary for decentralised-finance mechanisms: 58 elements,")
    L.append("a requirement/prohibition/consumer algebra, and a 72-protocol corpus of")
    L.append("hand-made decompositions. Every figure below is computed from the corpus")
    L.append("by committed scripts.")
    L.append("")
    L.append("Author identity is sealed. Do not speculate about who wrote this or what")
    L.append("produced it.")
    L.append("")
    L.append("## Abstract as it currently stands")
    L.append("")
    L.append(abstract_prose)
    L.append("")
    L.append("***")
    L.append("")
    L.append("## CANDIDATE A — the microstructure separation")
    L.append("")
    L.append(perps_prose)
    L.append("")
    L.append("Supporting figures: of 72 corpus protocols, 61 satisfy the laws and")
    L.append("warrants; 29 have a canonical form strictly smaller than themselves.")
    L.append("")
    L.append("## CANDIDATE B — the residue")
    L.append("")
    L.append("Across 60 constructions the corpus records 1259 functional obligations.")
    L.append("The vocabulary covers 570 of them. The remaining 689 are residue:")
    L.append("obligations for which the vocabulary has no name at all.")
    L.append("")
    L.append("Coverage is 45.3% permissive, 29.0% strict; 205 rows are approximate")
    L.append("fits, 15 constructions are inadmissible.")
    L.append("")
    L.append("The mechanism claimed for this: a vocabulary whose positive theory")
    L.append("excludes nothing will not fail to cover an obligation by being")
    L.append("over-constrained. It will fail by having no name.")
    L.append("")
    L.append("## CANDIDATE C — where composition actually fails")
    L.append("")
    L.append(pairs_prose)
    L.append("")
    L.append("Supporting figures: attribution of the failures resolves to 15 arcs and")
    L.append("10 elements with a strict below-set.")
    L.append("")
    L.append("***")
    L.append("")
    L.append("## The question")
    L.append("")
    L.append("Which of A, B or C is a result that a competent practitioner could not")
    L.append("have obtained by reading the protocols themselves?")
    L.append("")
    text = "\n".join(L) + "\n"

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    (OUT.parent / "BUNDLE.sha256").write_text(
        "%s  %s\n" % (digest, OUT.name), encoding="utf-8")
    print("wrote %s (%d bytes)\nsha256 %s" % (OUT, len(text), digest))
    return 0

if __name__ == "__main__":
    sys.exit(main())
