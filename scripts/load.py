import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

load_dotenv(ROOT / ".env")

partition_dir = ROOT / "data" / "raw_partitioned"

engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

table_name = "general_payment_2025"

for i, csv_file in enumerate(sorted(partition_dir.glob("part_*.csv"))):

    print(f"Loading {csv_file.name}...")

    df = pd.read_csv(csv_file)

    df.to_sql(
        table_name,
        engine,
        if_exists="replace" if i == 0 else "append",
        index=False,
        chunksize=50000
    )

    print(f"{csv_file.name} uploaded")

    del df

print("Complete!")