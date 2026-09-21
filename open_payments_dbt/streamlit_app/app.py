import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(
    page_title="Open Payments 2025 Analytics",
    layout="wide"
)

conn = st.connection("postgresql", type="sql")

with st.spinner("Loading dbt marts from PostgreSQL..."):
    df_seasonal = conn.query("SELECT * FROM dbt_dev.mart_seasonal_payments", ttl=600)
    df_shares = conn.query("SELECT * FROM dbt_dev.mart_manufacturer_shares", ttl=600)
    df_incentives = conn.query("SELECT * FROM dbt_dev.mart_provider_incentives", ttl=600)