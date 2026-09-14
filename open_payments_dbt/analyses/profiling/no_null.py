import pandas as pd

df = pd.read_csv('null_counts.csv')

zero_nulls = df[df["null_count"] == 0]

print(zero_nulls)