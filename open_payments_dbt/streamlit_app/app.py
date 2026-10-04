import plotly.express as px
import streamlit as st

st.set_page_config(page_title="Open Payments 2025 Analytics", layout="wide")

conn = st.connection("postgresql", type="sql")

with st.spinner("Loading dbt marts from PostgreSQL..."):
    df_payment = conn.query("SELECT * FROM dbt_dev.mart_payment_aggregates", ttl=600)
    df_shares = conn.query("SELECT * FROM dbt_dev.mart_manufacturer_shares", ttl=600)
    df_incentives = conn.query(
        "SELECT * FROM dbt_dev.mart_provider_incentives", ttl=600
    )

st.sidebar.title("Navigation")
dashboard_mode = st.sidebar.selectbox(
    "Select View",
    [
        "Macro Seasonality",
        "Recipient Type Trends",
        "Payment Nature Trends",
        "Manufacturers & Concentration",
        "Dental vs. General Medicine",
    ],
)

selected_sector = st.sidebar.selectbox(
    "Filter Market Sector", ["All Sectors", "Dental Only", "General Medicine Only"]
)

selected_size = st.sidebar.selectbox(
    "Payment Scale Filter",
    ["All Payments", "$1M+ Payments Only", "Under $1M Payments"],
)


# Comprehensive helper function to apply both sector and size filters locally
def apply_filters(df):
    # 1. Sector Filter
    if selected_sector == "Dental Only" and "is_dental_sector" in df.columns:
        df = df[df["is_dental_sector"] == True]
    elif (
        selected_sector == "General Medicine Only"
        and "is_dental_sector" in df.columns
    ):
        df = df[df["is_dental_sector"] == False]

    # 2. Size Filter ($1M+ Payments)
    if (
        selected_size == "$1M+ Payments Only"
        and "is_million_plus_payment" in df.columns
    ):
        df = df[df["is_million_plus_payment"] == True]
    elif (
        selected_size == "Under $1M Payments"
        and "is_million_plus_payment" in df.columns
    ):
        df = df[df["is_million_plus_payment"] == False]

    return df


if dashboard_mode == "Macro Seasonality":
    st.title("Open Payments: Seasonality & Recipient Dynamics")

    df_pay_filtered = apply_filters(df_payment)

    # Seasonality Analysis
    st.subheader(
        "Are there predictable structural cycles or seasonality in cash outflows?"
    )

    monthly_trend = (
        df_pay_filtered.groupby("payment_month", as_index=False)
        .agg(
            {
                "total_payment_amount_usd": "sum",
                "total_payment_volume": "sum",
            }
        )
        .sort_values("payment_month")
    )

    col1, col2 = st.columns(2)
    with col1:
        fig_amount = px.bar(
            monthly_trend,
            x="payment_month",
            y="total_payment_amount_usd",
            title="Total Outflow Amount ($) by Month",
            labels={
                "payment_month": "Month",
                "total_payment_amount_usd": "Total Amount ($)",
            },
        )
        st.plotly_chart(fig_amount, use_container_width=True)

    with col2:
        fig_volume = px.line(
            monthly_trend,
            x="payment_month",
            y="total_payment_volume",
            markers=True,
            title="Payment Transaction Volume by Month",
            labels={
                "payment_month": "Month",
                "total_payment_volume": "Transaction Count",
            },
        )
        st.plotly_chart(fig_volume, use_container_width=True)

elif dashboard_mode == "Recipient Type Trends":
    st.title("Recipient Type Trends")

    df_seas_filtered = apply_filters(df_payment)

    st.subheader(
        "How do payment volumes and amounts differ across recipient types?"
    )

    recip_summary = (
        df_seas_filtered.groupby("recipient_type", as_index=False)
        .agg({"total_payment_amount_usd": "sum", "total_payment_volume": "sum"})
        .sort_values(by="total_payment_amount_usd", ascending=False)
    )

    fig_recip = px.bar(
        recip_summary,
        x="recipient_type",
        y="total_payment_amount_usd",
        title="Total Spend by Recipient Type",
        color="total_payment_volume",
        labels={
            "recipient_type": "Recipient Type",
            "total_payment_amount_usd": "Total Amount ($)",
        },
    )
    st.plotly_chart(fig_recip, use_container_width=True)

    

elif dashboard_mode == "Payment Nature Trends":
    st.title("Payment Nature Trends")

    df_pay_filtered = apply_filters(df_payment)

    st.subheader(
        "How does the total payment and payment volume vary depending on payment nature?"
    )
    
    nature_summary = (
        df_pay_filtered.groupby("payment_nature", as_index=False)
        .agg(
            {
                "total_payment_amount_usd": "sum",
                "total_payment_volume": "sum",
            }
        )
        .sort_values(by="total_payment_amount_usd", ascending=False)
    )
    
    # Map your long category names to clean, short display names
    nature_mapping = {
        "Compensation for services other than consulting, including serving as faculty or as a speaker at a venue other than a continuing education program": "Non-services compensation",
        "Paste Your Second Super Long Payment Nature Here": "Short Name 2",
    }
    nature_summary["payment_nature_display"] = nature_summary["payment_nature"].replace(nature_mapping)

    # Chart 1: Transaction Volume
    fig_nature_vol = px.bar(
        nature_summary,
        y="payment_nature_display",
        x="total_payment_volume",
        title="Transaction Volume by Nature",
        orientation="h",
        hover_data={"payment_nature": True, "payment_nature_display": False},
        labels={
            "payment_nature_display": "Payment Nature",
            "total_payment_volume": "Transaction Volume",
        },
    )
    fig_nature_vol.update_layout(
        yaxis={"categoryorder": "total ascending"},
        margin=dict(l=150)
    )
    st.plotly_chart(fig_nature_vol, use_container_width=True)

    # Chart 2: Total Payment Amount ($)
    fig_nature_amt = px.bar(
        nature_summary,
        y="payment_nature_display",
        x="total_payment_amount_usd",
        title="Total Amount ($) by Nature",
        orientation="h",
        hover_data={"payment_nature": True, "payment_nature_display": False},
        labels={
            "payment_nature_display": "Payment Nature",
            "total_payment_amount_usd": "Total Amount ($)",
        },
    )
    fig_nature_amt.update_layout(
        yaxis={"categoryorder": "total ascending"},
        margin=dict(l=150)
    )
    st.plotly_chart(fig_nature_amt, use_container_width=True)

elif dashboard_mode == "Manufacturers & Concentration":
    st.title("Manufacturer/GPO Market Share & Concentration")

    df_shares_filtered = apply_filters(df_shares)

    st.subheader(
        "Which manufacturers/GPOs account for the largest payment amounts?"
    )

    top_mfg = (
        df_shares_filtered.groupby("manufacturer_gpo_name", as_index=False)
        .agg({"total_payment_amount_usd": "sum", "total_volume": "sum"})
        .sort_values(by="total_payment_amount_usd", ascending=False)
        .head(15)
    )

    fig_mfg = px.bar(
        top_mfg,
        y="manufacturer_gpo_name",
        x="total_payment_amount_usd",
        orientation="h",
        title="Top 15 Manufacturers/GPOs by Total Payment Amount",
        labels={
            "manufacturer_gpo_name": "Manufacturer / GPO",
            "total_payment_amount_usd": "Total Amount ($)",
        },
    )
    fig_mfg.update_layout(yaxis={"categoryorder": "total ascending"})
    st.plotly_chart(fig_mfg, use_container_width=True)

    with st.expander("View Raw Data Table"):
        st.dataframe(top_mfg, use_container_width=True)

elif dashboard_mode == "Dental vs. General Medicine":
    st.title("Dental Sector Deep Dive & Market Comparison")

    st.markdown(
        "Contrasting dental-specific provider incentives against the broader"
        " medical landscape."
    )

    df_incentives_filtered = apply_filters(df_incentives)
    df_shares_filtered = apply_filters(df_shares)

    comp_summary = (
        df_incentives_filtered.groupby("is_dental_sector", as_index=False)
        .agg({
            "total_vendor_spend_usd": "sum",
            "benefits_in_kind_usd": "sum",
            "direct_cash_compensation_usd": "sum",
        })
    )

    dental_row = comp_summary[comp_summary["is_dental_sector"] == True]
    general_row = comp_summary[comp_summary["is_dental_sector"] == False]

    col1, col2, col3 = st.columns(3)
    with col1:
        d_spend = (
            dental_row["total_vendor_spend_usd"].values[0]
            if not dental_row.empty
            else 0
        )
        st.metric(label="Total Dental Market Spend", value=f"${d_spend:,.0f}")
    with col2:
        if not dental_row.empty:
            d_cash = dental_row["direct_cash_compensation_usd"].values[0]
            d_inkind = dental_row["benefits_in_kind_usd"].values[0]
            d_ratio = (d_inkind / d_cash) if d_cash > 0 else 0
            st.metric(
                label="Dental In-Kind vs. Direct Cash Ratio", value=f"{d_ratio:.2f}"
            )
    with col3:
        if not general_row.empty:
            g_cash = general_row["direct_cash_compensation_usd"].values[0]
            g_inkind = general_row["benefits_in_kind_usd"].values[0]
            g_ratio = (g_inkind / g_cash) if g_cash > 0 else 0
            st.metric(
                label="General Med In-Kind vs. Cash Ratio", value=f"{g_ratio:.2f}"
            )

    st.subheader("Top Dental Product Manufacturers & Suppliers")

    dental_mfg = (
        df_shares_filtered[df_shares_filtered["is_dental_sector"] == True]
        .groupby("manufacturer_gpo_name", as_index=False)
        .agg({"total_payment_amount_usd": "sum"})
        .sort_values(by="total_payment_amount_usd", ascending=False)
        .head(10)
    )

    fig_dmfg = px.bar(
        dental_mfg,
        x="manufacturer_gpo_name",
        y="total_payment_amount_usd",
        title="Top 10 Dental Sector Incentive Providers",
        labels={
            "manufacturer_gpo_name": "Manufacturer",
            "total_payment_amount_usd": "Total Dental Spend ($)",
        },
    )
    st.plotly_chart(fig_dmfg, use_container_width=True)