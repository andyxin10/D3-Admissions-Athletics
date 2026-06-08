import pandas as pd
from rapidfuzz import process, fuzz
import re

# ── CONFIG ──────────────────────────────────────────────────────────────────
IPEDS_PATH      = "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds.dta"
SPORT_PATH      = "/Users/andyxin/Desktop/ECON135/FinalProject/mlax.xlsx"
SPORT_PREFIX    = "mlax"   # column names: mlax_confchamp, mlax_ncaa
MATCH_THRESHOLD = 50           # rapidfuzz score 0–100; below this = unmatched
# ────────────────────────────────────────────────────────────────────────────


def normalize(name: str) -> str:
    """Lowercase, strip punctuation, expand common truncations."""
    if not isinstance(name, str):
        return ""
    s = name.lower().strip()
    s = re.sub(r"[^\w\s]", "", s)       # remove punctuation
    s = re.sub(r"\s+", " ", s)          # collapse whitespace
    # Strip college/university tokens so truncated names align
    s = re.sub(r"\buniversity of\b", "", s)
    s = re.sub(r"\bcollege of\b", "", s)
    s = re.sub(r"\buniversity\b", "", s)
    s = re.sub(r"\bcollege\b", "", s)
    s = re.sub(r"\bthe\b", "", s)
    s = s.strip()
    return s


# ── LOAD ─────────────────────────────────────────────────────────────────────
ipeds = pd.read_stata(IPEDS_PATH)   # .dta Stata file
sport = pd.read_excel(SPORT_PATH)

# Confirm expected columns
assert "year"   in ipeds.columns, "IPEDS missing 'year'"
assert "school" in ipeds.columns, "IPEDS missing 'school'"
assert "year"   in sport.columns, f"{SPORT_PREFIX} CSV missing 'year'"
assert "school" in sport.columns, f"{SPORT_PREFIX} CSV missing 'school'"
assert f"{SPORT_PREFIX}_confchamp" in sport.columns
assert f"{SPORT_PREFIX}_ncaa"      in sport.columns

# ── NORMALIZE ────────────────────────────────────────────────────────────────
ipeds["_norm"] = ipeds["school"].apply(normalize)
sport["_norm"] = sport["school"].apply(normalize)

# ── FUZZY MATCH (school names only, year-agnostic) ───────────────────────────
ipeds_names = ipeds["_norm"].dropna().unique().tolist()
sport_names = sport["_norm"].dropna().unique().tolist()

records = []
for s_norm in sport_names:
    result = process.extractOne(
        s_norm,
        ipeds_names,
        scorer=fuzz.token_sort_ratio,
        score_cutoff=MATCH_THRESHOLD,
    )
    sport_orig = sport.loc[sport["_norm"] == s_norm, "school"].iloc[0]
    if result:
        matched_norm, score, _ = result
        ipeds_orig = ipeds.loc[ipeds["_norm"] == matched_norm, "school"].iloc[0]
        records.append({
            "sport_school": sport_orig,
            "ipeds_school": ipeds_orig,
            "score":        score,
            "status":       "AUTO" if score >= 95 else "REVIEW",
        })
    else:
        records.append({
            "sport_school": sport_orig,
            "ipeds_school": None,
            "score":        0,
            "status":       "UNMATCHED",
        })

match_df = pd.DataFrame(records).sort_values("score", ascending=False)

# ── REVIEW OUTPUT ─────────────────────────────────────────────────────────────
print("\n===== MATCH REVIEW =====")
print(f"AUTO      (score >= 80) : {(match_df.status == 'AUTO').sum()}")
print(f"REVIEW    (60-79)       : {(match_df.status == 'REVIEW').sum()}")
print(f"UNMATCHED (< {MATCH_THRESHOLD})        : {(match_df.status == 'UNMATCHED').sum()}")
print()
print(match_df.to_string(index=False))

match_df.to_csv("mlax_match_review.csv", index=False)
print("\nSaved: mlax_match_review.csv")
print("  -> Edit 'ipeds_school' for any REVIEW or UNMATCHED rows, then rerun to merge.")

# ── MERGE ─────────────────────────────────────────────────────────────────────
# Build mapping: sport school original name -> ipeds school original name
name_map = (
    match_df[match_df["ipeds_school"].notna()]
    .set_index("sport_school")["ipeds_school"]
    .to_dict()
)

sport["school_matched"] = sport["school"].map(name_map)

merged = ipeds.merge(
    sport[["year", "school_matched", f"{SPORT_PREFIX}_confchamp", f"{SPORT_PREFIX}_ncaa"]],
    left_on=["year", "school"],
    right_on=["year", "school_matched"],
    how="left",
).drop(columns=["school_matched", "_norm"])

merged.to_csv("ipeds_with_mlax.csv", index=False)
print(f"\nSaved: ipeds_with_mlax.csv")
print(f"  Rows: {len(merged)}")
print(f"  Non-null {SPORT_PREFIX}_confchamp: {merged[f'{SPORT_PREFIX}_confchamp'].notna().sum()}")
print(f"  Non-null {SPORT_PREFIX}_ncaa:      {merged[f'{SPORT_PREFIX}_ncaa'].notna().sum()}")