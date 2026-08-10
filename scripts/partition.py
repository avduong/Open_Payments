import pandas as pd
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

input_file = ROOT / "data" / "raw" / "general_payment_data_2025.csv"
partitioned_folder = ROOT / "data" / "raw_partitioned"
rows_per_file = 1000000  

for i, chunk in enumerate(pd.read_csv(input_file, chunksize=rows_per_file)):
    output_file = partitioned_folder / f"part_{i+1}.csv"
    chunk.to_csv(output_file, index=False)

print("Done!")