import pandas as pd
from rapidfuzz import process, fuzz
import re

# ── CONFIG ───────────────────────────────────────────────────────────────────
BASE_DIR   = "/Users/andyxin/Desktop/ECON135/FinalProject/"
IPEDS_PATH = BASE_DIR + "d3_ipeds.dta"

SPORTS = ["baseball", "mbb", "mlax", "msoc", "softball", "wbb", "wlax", "wsoc"]

MATCH_THRESHOLD = 50
# ─────────────────────────────────────────────────────────────────────────────


def normalize(name: str) -> str:
    if not isinstance(name, str):
        return ""
    s = name.lower().strip()
    s = re.sub(r"[^\w\s]", "", s)
    s = re.sub(r"\s+", " ", s)
    s = re.sub(r"\buniversity of\b", "", s)
    s = re.sub(r"\bcollege of\b", "", s)
    s = re.sub(r"\buniversity\b", "", s)
    s = re.sub(r"\bcollege\b", "", s)
    s = re.sub(r"\bthe\b", "", s)
    return s.strip()


def build_crosswalk(sport: str, ipeds: pd.DataFrame) -> dict:
    sport_df = pd.read_excel(BASE_DIR + f"{sport}.xlsx")

    for col in ["year", "school", f"{sport}_confchamp", f"{sport}_ncaa"]:
        assert col in sport_df.columns, f"{sport}.xlsx missing column '{col}'"

    sport_df["_norm"] = sport_df["school"].apply(normalize)

    ipeds_names  = ipeds["_norm"].dropna().unique().tolist()
    sport_unique = sport_df["_norm"].dropna().unique().tolist()

    name_map = {}
    unmatched = []

    for s_norm in sport_unique:
        result = process.extractOne(
            s_norm,
            ipeds_names,
            scorer=fuzz.token_sort_ratio,
            score_cutoff=MATCH_THRESHOLD,
        )
        sport_orig = sport_df.loc[sport_df["_norm"] == s_norm, "school"].iloc[0]
        if result:
            matched_norm, score, _ = result
            ipeds_orig = ipeds.loc[ipeds["_norm"] == matched_norm, "school"].iloc[0]
            name_map[sport_orig] = ipeds_orig
        else:
            unmatched.append(sport_orig)

    if unmatched:
        print(f"  [{sport}] WARNING — {len(unmatched)} unmatched schools: {unmatched}")
    else:
        print(f"  [{sport}] All schools matched.")

    return name_map


def merge_sport(base: pd.DataFrame, sport: str, name_map: dict) -> pd.DataFrame:
    sport_df = pd.read_excel(BASE_DIR + f"{sport}.xlsx")
    sport_df["school_matched"] = sport_df["school"].map(name_map)

    # Drop rows where match failed
    sport_df = sport_df[sport_df["school_matched"].notna()]

    merged = base.merge(
        sport_df[["year", "school_matched", f"{sport}_confchamp", f"{sport}_ncaa"]],
        left_on=["year", "school"],
        right_on=["year", "school_matched"],
        how="left",
    ).drop(columns=["school_matched"])

    n_matched = merged[f"{sport}_ncaa"].notna().sum()
    print(f"  [{sport}] {n_matched} school-year observations matched.")

    return merged


# ── MAIN ─────────────────────────────────────────────────────────────────────
print("Loading IPEDS...")
ipeds = pd.read_stata(IPEDS_PATH)
ipeds["_norm"] = ipeds["school"].apply(normalize)

# Build school -> unitid map from IPEDS
school_unitid = (
    ipeds[["school", "unitid"]]
    .drop_duplicates()
    .set_index("school")["unitid"]
    .to_dict()
)

# Create a complete panel skeleton including 2013 and 2014
all_unitids = ipeds[["unitid", "school"]].drop_duplicates()
extra_years = pd.DataFrame({"year": [2013, 2014]})
skeleton    = all_unitids.merge(extra_years, how="cross")

# Append skeleton rows to IPEDS base so all schools appear in 2013 and 2014
base = pd.concat([skeleton, ipeds.copy()], ignore_index=True)
base["_norm"] = base["school"].apply(normalize)

print("\nBuilding crosswalks and merging sports...")
for sport in SPORTS:
    print(f"\n{sport.upper()}")
    name_map = build_crosswalk(sport, ipeds)
    base     = merge_sport(base, sport, name_map)

# Drop the working _norm column
base = base.drop(columns=["_norm"])

# Sort for cleanliness
base = base.sort_values(["unitid", "year"]).reset_index(drop=True)
base = base.drop_duplicates(subset=["unitid", "year"], keep="first")

# ── SAVE ─────────────────────────────────────────────────────────────────────
OUT = BASE_DIR + "d3_ipeds_with_sports.csv"
base.to_csv(OUT, index=False)
print(f"\nDone. Saved to: {OUT}")
print(f"Rows: {len(base)}")
print(f"Years present: {sorted(base['year'].unique())}")
print(f"Columns added: {[c for c in base.columns if any(s in c for s in SPORTS)]}")