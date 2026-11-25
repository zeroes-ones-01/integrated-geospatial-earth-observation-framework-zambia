
from pathlib import Path
import warnings

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# ------------------------------------------------------------
# PROJECT PATHS AND SETTINGS
# ------------------------------------------------------------

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data" / "processed"
REFERENCE = ROOT / "data" / "reference"
OUTPUT = ROOT / "outputs" / "figures"

START_YEAR = 1991
END_YEAR = 2020
YEARS = list(range(START_YEAR, END_YEAR + 1))

OUTPUT.mkdir(parents=True, exist_ok=True)

sns.set_theme(
    style="whitegrid",
    context="paper",
    font_scale=1.15
)

plt.rcParams.update({
    "figure.figsize": (10, 6),
    "figure.dpi": 120,
    "savefig.dpi": 300,
    "font.family": "DejaVu Sans",
    "axes.titleweight": "bold",
    "axes.labelweight": "medium",
    "axes.spines.top": False,
    "axes.spines.right": False,
    "legend.frameon": False,
})


# ------------------------------------------------------------
# DATA LOADING
# ------------------------------------------------------------

def load_csv(path):
    if not path.exists():
        raise FileNotFoundError(f"Required input not found: {path}")
    return pd.read_csv(path)


production = load_csv(DATA / "agricultural" / "production.csv")
area = load_csv(DATA / "agricultural" / "area_harvested.csv")
yields = load_csv(DATA / "agricultural" / "yields.csv")
fertiliser = load_csv(
    DATA / "agricultural" / "fertilizer_by_nutrient.csv"
)
rainfall = load_csv(DATA / "climate" / "Rainfall.csv")
temperature = load_csv(DATA / "climate" / "Temperature.csv")
emissions = load_csv(DATA / "emissions" / "co2_equivalent.csv")
crops = load_csv(REFERENCE / "crops.csv")


# ------------------------------------------------------------
# DATA VALIDATION
# ------------------------------------------------------------

def validate_years(df, column, expected, label):
    actual = sorted(pd.to_numeric(df[column]).unique().tolist())
    if actual != expected:
        raise ValueError(
            f"{label}: unexpected years. Expected {expected[0]}–"
            f"{expected[-1]}, received {actual}"
        )


def validate_unique(df, columns, label):
    if df.duplicated(columns).any():
        raise ValueError(f"{label}: duplicate records found for {columns}")


def validate_units(df, column, expected, label):
    actual = df[column].dropna().astype(str).unique().tolist()
    if actual != [expected] and set(actual) != {expected}:
        raise ValueError(
            f"{label}: expected unit {expected}; received {actual}"
        )


for frame, year_column, label in [
    (production, "year", "Production"),
    (area, "year", "Harvested area"),
    (yields, "year", "Yield"),
    (fertiliser, "Year", "Fertiliser"),
    (rainfall, "year", "Rainfall"),
    (temperature, "year", "Temperature"),
    (emissions, "Year", "Emissions"),
]:
    validate_years(frame, year_column, YEARS, label)

validate_unique(production, ["crop_id", "year"], "Production")
validate_unique(area, ["crop_id", "year"], "Harvested area")
validate_unique(yields, ["crop_id", "year"], "Yield")
validate_unique(fertiliser, ["nutrient", "Year"], "Fertiliser")
validate_unique(emissions, ["Item", "Year"], "Emissions")
validate_unique(rainfall, ["year"], "Rainfall")
validate_unique(temperature, ["year"], "Temperature")

if len(crops) != 11 or crops["crop_id"].duplicated().any():
    raise ValueError("Crop lookup must contain 11 unique crop IDs.")

crop_ids = set(crops["crop_id"])
for frame, label in [
    (production, "Production"),
    (area, "Harvested area"),
    (yields, "Yield"),
]:
    if set(frame["crop_id"]) != crop_ids:
        raise ValueError(f"{label}: crop IDs do not match the crop lookup.")

validate_units(production, "unit", "t", "Production")
validate_units(area, "unit", "ha", "Harvested area")
validate_units(yields, "unit", "kg/ha", "Yield")
validate_units(fertiliser, "Unit", "t", "Fertiliser")
validate_units(emissions, "Unit", "kt", "Emissions")

expected_counts = {
    "production": 330,
    "area": 330,
    "yields": 330,
    "fertiliser": 90,
    "rainfall": 30,
    "temperature": 30,
    "emissions": 120,
}

actual_counts = {
    "production": len(production),
    "area": len(area),
    "yields": len(yields),
    "fertiliser": len(fertiliser),
    "rainfall": len(rainfall),
    "temperature": len(temperature),
    "emissions": len(emissions),
}

if actual_counts != expected_counts:
    raise ValueError(
        f"Record-count validation failed: {actual_counts}"
    )

print("All input validation checks passed.")
print(f"Validated period: {START_YEAR}–{END_YEAR}")
print(f"Validated records: {sum(actual_counts.values()):,}")


# ------------------------------------------------------------
# PREPARE ANALYTICAL DATA
# ------------------------------------------------------------

production["crop_id"] = production["crop_id"].astype(int)
area["crop_id"] = area["crop_id"].astype(int)
yields["crop_id"] = yields["crop_id"].astype(int)
crops["crop_id"] = crops["crop_id"].astype(int)

crop_names = crops.set_index("crop_id")["crop_name"].to_dict()

# Correct the display spelling without changing the source CSV.
crop_names = {
    key: ("Sweet potatoes" if value == "Sweat potatoes" else value)
    for key, value in crop_names.items()
}

for frame in [production, area, yields]:
    frame["crop_name"] = frame["crop_id"].map(crop_names)

production["value"] = pd.to_numeric(production["value"])
area["value"] = pd.to_numeric(area["value"])
yields["value"] = pd.to_numeric(yields["value"])

production["year"] = production["year"].astype(int)
area["year"] = area["year"].astype(int)
yields["year"] = yields["year"].astype(int)

annual_production = (
    production.groupby("year")["value"].sum().rename("production_t")
)
annual_area = (
    area.groupby("year")["value"].sum().rename("area_ha")
)

annual = pd.concat([annual_production, annual_area], axis=1).reset_index()
annual["yield_t_ha"] = annual["production_t"] / annual["area_ha"]
annual["production_million_t"] = annual["production_t"] / 1_000_000
annual["area_million_ha"] = annual["area_ha"] / 1_000_000

climate = (
    rainfall.merge(temperature, on="year", validate="one_to_one")
    .merge(
        annual[["year", "yield_t_ha"]],
        on="year",
        validate="one_to_one"
    )
)

fertiliser["Year"] = fertiliser["Year"].astype(int)
fertiliser["Value"] = pd.to_numeric(fertiliser["Value"])

emissions["Year"] = emissions["Year"].astype(int)
emissions["Value"] = pd.to_numeric(emissions["Value"])

# The four categories included in the processed emissions dataset.
emissions_wide = emissions.pivot(
    index="Year", columns="Item", values="Value"
).sort_index()

if emissions_wide.isna().any().any():
    raise ValueError("Missing emissions category values detected.")

emissions_wide["total_kt"] = emissions_wide.sum(axis=1)

# Convert kt CO2e to kg CO2e and divide by crop production in tonnes.
emissions_wide = emissions_wide.merge(
    annual[["year", "production_t"]],
    left_index=True,
    right_on="year",
    validate="one_to_one"
)

emissions_wide["intensity_kg_per_t"] = (
    emissions_wide["total_kt"] * 1_000_000
    / emissions_wide["production_t"]
)


# ------------------------------------------------------------
# SAFE FIGURE EXPORT
# ------------------------------------------------------------

planned_names = [
    "01_annual_crop_production",
    "02_annual_harvested_area",
    "03_aggregate_crop_yield",
    "04_crop_production_comparison",
    "05_crop_yield_comparison",
    "06_annual_rainfall",
    "07_annual_temperature",
    "08_rainfall_yield_relationship",
    "09_temperature_yield_relationship",
    "10_agricultural_emissions_by_source",
    "11_fertiliser_nutrient_trends",
    "12_emissions_intensity",
]

planned_files = [
    OUTPUT / f"{name}.{extension}"
    for name in planned_names
    for extension in ("png", "svg")
]

def finish_figure(fig, name):
    created = []
    preserved = []

    for extension in ("png", "svg"):
        output_path = OUTPUT / f"{name}.{extension}"

        if output_path.exists():
            preserved.append(output_path.name)
            continue

        fig.savefig(
            output_path,
            bbox_inches="tight",
            facecolor="white"
        )
        created.append(output_path.name)

    plt.close(fig)

    if created:
        print("Created: " + ", ".join(created))

    if preserved:
        print("Preserved existing: " + ", ".join(preserved))


# ------------------------------------------------------------
# 1. ANNUAL CROP PRODUCTION
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=annual,
    x="year",
    y="production_million_t",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Annual Production of Selected Crops in Zambia",
    xlabel="Year",
    ylabel="Production (million tonnes)"
)
finish_figure(fig, planned_names[0])


# ------------------------------------------------------------
# 2. ANNUAL HARVESTED AREA
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=annual,
    x="year",
    y="area_million_ha",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Annual Harvested Area of Selected Crops in Zambia",
    xlabel="Year",
    ylabel="Harvested area (million hectares)"
)
finish_figure(fig, planned_names[1])


# ------------------------------------------------------------
# 3. AGGREGATE CROP YIELD
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=annual,
    x="year",
    y="yield_t_ha",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Aggregate Crop Yield in Zambia",
    xlabel="Year",
    ylabel="Weighted yield (tonnes per hectare)"
)
finish_figure(fig, planned_names[2])


# ------------------------------------------------------------
# 4. CROP PRODUCTION: 1991 VERSUS 2020
# ------------------------------------------------------------

crop_production = (
    production[production["year"].isin([START_YEAR, END_YEAR])]
    .pivot(index="crop_name", columns="year", values="value")
)

crop_production = crop_production.sort_values(END_YEAR)

fig, ax = plt.subplots(figsize=(10, 7))
crop_production.plot(kind="barh", ax=ax, width=0.8)
ax.set(
    title="Crop Production Comparison: 1991 and 2020",
    xlabel="Production (tonnes)",
    ylabel="Crop"
)
ax.legend(title="Year")
finish_figure(fig, planned_names[3])


# ------------------------------------------------------------
# 5. CROP YIELD: 1991 VERSUS 2020
# ------------------------------------------------------------

crop_yield = (
    yields[yields["year"].isin([START_YEAR, END_YEAR])]
    .pivot(index="crop_name", columns="year", values="value")
)

crop_yield = crop_yield.sort_values(END_YEAR)

fig, ax = plt.subplots(figsize=(10, 7))
crop_yield.plot(kind="barh", ax=ax, width=0.8)
ax.set(
    title="Crop Yield Comparison: 1991 and 2020",
    xlabel="Yield (kg per hectare)",
    ylabel="Crop"
)
ax.legend(title="Year")
finish_figure(fig, planned_names[4])


# ------------------------------------------------------------
# 6. ANNUAL RAINFALL
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=climate,
    x="year",
    y="rainfall",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Annual Rainfall in Zambia",
    xlabel="Year",
    ylabel="Annual rainfall (mm)"
)
finish_figure(fig, planned_names[5])


# ------------------------------------------------------------
# 7. ANNUAL TEMPERATURE
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=climate,
    x="year",
    y="avg_temperature",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Annual Mean Temperature in Zambia",
    xlabel="Year",
    ylabel="Mean temperature (°C)"
)
finish_figure(fig, planned_names[6])


# ------------------------------------------------------------
# 8–9. CLIMATE–YIELD RELATIONSHIPS
# ------------------------------------------------------------

def relationship_plot(x, xlabel, title, name):
    fig, ax = plt.subplots()
    sns.regplot(
        data=climate,
        x=x,
        y="yield_t_ha",
        scatter_kws={"s": 55, "alpha": 0.8},
        line_kws={"linewidth": 2},
        ax=ax
    )
    correlation = climate[x].corr(climate["yield_t_ha"])
    ax.text(
        0.04, 0.96,
        f"Pearson correlation (r) = {correlation:.3f}",
        transform=ax.transAxes,
        va="top"
    )
    ax.set(
        title=title,
        xlabel=xlabel,
        ylabel="Aggregate crop yield (tonnes per hectare)"
    )
    finish_figure(fig, name)
    return correlation


rainfall_r = relationship_plot(
    "rainfall",
    "Annual rainfall (mm)",
    "Annual Rainfall and Aggregate Crop Yield",
    planned_names[7]
)

temperature_r = relationship_plot(
    "avg_temperature",
    "Annual mean temperature (°C)",
    "Annual Mean Temperature and Aggregate Crop Yield",
    planned_names[8]
)


# ------------------------------------------------------------
# 10. EMISSIONS BY SOURCE
# ------------------------------------------------------------

category_columns = [
    column for column in emissions_wide.columns
    if column not in ["total_kt", "production_t", "year",
                      "intensity_kg_per_t"]
]

fig, ax = plt.subplots()
emissions_wide.set_index("year")[category_columns].plot(
    kind="area",
    stacked=True,
    alpha=0.8,
    ax=ax
)
ax.set(
    title="Agricultural Greenhouse-Gas Emissions by Included Source",
    xlabel="Year",
    ylabel="Emissions (kt CO₂-equivalent)"
)
ax.legend(title="Source category", loc="upper left")
finish_figure(fig, planned_names[9])


# ------------------------------------------------------------
# 11. FERTILISER NUTRIENT TRENDS
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=fertiliser,
    x="Year",
    y="Value",
    hue="nutrient",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Annual Fertiliser Nutrient Application",
    xlabel="Year",
    ylabel="Nutrient quantity (tonnes)"
)
ax.legend(title="Nutrient")
finish_figure(fig, planned_names[10])


# ------------------------------------------------------------
# 12. EMISSIONS INTENSITY
# ------------------------------------------------------------

fig, ax = plt.subplots()
sns.lineplot(
    data=emissions_wide,
    x="year",
    y="intensity_kg_per_t",
    marker="o",
    linewidth=2,
    ax=ax
)
ax.set(
    title="Emissions Intensity of Included Agricultural Sources",
    xlabel="Year",
    ylabel="kg CO₂-equivalent per tonne of crop production"
)
ax.text(
    0.02, 0.02,
    "Based on the four emissions categories in the processed dataset.",
    transform=ax.transAxes,
    fontsize=8
)
finish_figure(fig, planned_names[11])


# ------------------------------------------------------------
# SUMMARY STATISTICS
# ------------------------------------------------------------

print("\n========== ANALYTICAL SUMMARY ==========")
print(
    "Rainfall–yield Pearson correlation:",
    round(rainfall_r, 4)
)
print(
    "Temperature–yield Pearson correlation:",
    round(temperature_r, 4)
)
print(
    "Production range (million tonnes):",
    round(annual["production_million_t"].min(), 3),
    "to",
    round(annual["production_million_t"].max(), 3)
)
print(
    "Aggregate yield range (t/ha):",
    round(annual["yield_t_ha"].min(), 3),
    "to",
    round(annual["yield_t_ha"].max(), 3)
)
print(
    "Emissions intensity range (kg CO2e/t):",
    round(emissions_wide["intensity_kg_per_t"].min(), 3),
    "to",
    round(emissions_wide["intensity_kg_per_t"].max(), 3)
)

print("\n========== FIGURE GENERATION COMPLETE ==========")
print(f"Figure directory: {OUTPUT}")
print(f"Figures generated: {len(planned_names)}")
print(f"Files exported: {len(planned_files)}")
