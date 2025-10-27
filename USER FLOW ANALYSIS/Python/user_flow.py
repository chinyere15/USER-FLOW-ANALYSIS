import pandas as pd
import pyodbc
import matplotlib.pyplot as plt
import seaborn as sns

#connection
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=AYOBAMI-TOPEOJO\SQLEXPRESS;'
    'DATABASE=use flow analysis;'
    'Trusted_Connection=yes;'
)

df = pd.read_sql("SELECT * FROM dbo.user_flow;", conn)
df.head()
print (df.head())

#funnel analysis
funnel = {
    "Signup": len(df),
    "Email Verified": df["email_verified_date"].notna().sum(),
    "Account Created": df["account_created_date"].notna().sum(),
    "First Transaction": df["first_transaction_date"].notna().sum()
}

funnel_df = pd.DataFrame(list(funnel.items()), columns=["Stage", "Users"])
funnel_df

#plotting funnel analyis
sns.barplot(x="Stage", y="Users", data=funnel_df, hue="Stage", palette="Blues_d", legend=False)
plt.title("User Funnel Analysis")
plt.show()

#daily signup rate
df["signup_date"] = pd.to_datetime(df["signup_date"])
trend = (
    df.groupby(df["signup_date"].dt.date)
    .agg({
        "user_id": "count",
        "account_created_date": lambda x: x.notna().sum(),
        "first_transaction_date": lambda x: x.notna().sum()
    })
    .rename(columns={
        "user_id": "Total Signups",
        "account_created_date": "Account Created",
        "first_transaction_date": "First Transactions"
    })
    .reset_index()
)

trend.head()

#visual of daily trends
plt.figure(figsize=(10,5))
sns.lineplot(data=trend, x="signup_date", y="Total Signups", label="Signups")
sns.lineplot(data=trend, x="signup_date", y="Account Created", label="Account Created")
sns.lineplot(data=trend, x="signup_date", y="First Transactions", label="First Transactions")
plt.title("User Signup & Activation Trends")
plt.xlabel("Date")
plt.ylabel("Number of Users")
plt.legend()
plt.show()

#conversion rate by country
country = (
    df.groupby("country")
    .agg({
        "user_id": "count",
        "first_transaction_date": lambda x: x.notna().sum()
    })
    .rename(columns={"user_id": "Total Users", "first_transaction_date": "Transactions"})
    .reset_index()
)

country["Conversion Rate (%)"] = round(100 * country["Transactions"] / country["Total Users"], 2)
country

# visualisation of conversion rate by country
plt.figure(figsize=(8,5))
sns.barplot(data=country, x="Conversion Rate (%)", y="country", palette="crest")
plt.title("Conversion Rate by Country")
plt.show()


#export for power bi
funnel_df.to_csv("cleva_funnel_summary.csv", index=False)
trend.to_csv("cleva_trend_data.csv", index=False)
country.to_csv("cleva_country_conversion.csv", index=False)
