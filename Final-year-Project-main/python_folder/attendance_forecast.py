from prophet import Prophet
from datetime import datetime, timedelta
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# ✅ Initialize Firebase
cred_path = "E:/AI Powered system/python_folder/myserviceaccount.json"
cred = credentials.Certificate(cred_path)

if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ✅ Fetch attendance for a single user
def fetch_attendance_for_user(user_id):
    collection_ref = db.collection('attendance')
    today = datetime.now()
    start_of_month = datetime(today.year, today.month, 1)

    # Fetch attendance records for this user for the current month
    docs = collection_ref \
        .where(filter=firestore.FieldFilter('userId', '==', user_id)) \
        .where(filter=firestore.FieldFilter('timestamp', '>=', start_of_month)) \
        .stream()

    # Create a map of all days (default 0 = absent)
    all_days = pd.date_range(start=start_of_month, end=today)
    attendance_map = {day.date(): 0 for day in all_days}

    for doc in docs:
        data = doc.to_dict()
        # Safely convert Firestore timestamp to Python date
        ts = data['timestamp'].timestamp()
        timestamp = datetime.fromtimestamp(ts).date()
        attendance_map[timestamp] = 1  # Present

    # Convert to DataFrame with datetime (not date!)
    df = pd.DataFrame({
        'ds': [datetime.combine(d, datetime.min.time()) for d in attendance_map.keys()],
        'y': list(attendance_map.values())
    })

    return df

# ✅ Generate forecast using Prophet
def generate_forecast_for_user(user_id):
    df = fetch_attendance_for_user(user_id)

    m = Prophet(
        daily_seasonality=True,
        weekly_seasonality=True,
        changepoint_prior_scale=0.01  # Sensitive to changes
    )
    m.fit(df)

    future = m.make_future_dataframe(periods=7)
    forecast = m.predict(future)

    # Only next 7 days
    forecast_data = forecast[['ds', 'yhat']].tail(7).to_dict(orient='records')
    actual_data = df.to_dict(orient='records')

    # Upload result to Firestore
    db.collection('forecast_results').document(user_id).set({
        'actual': actual_data,
        'forecast': forecast_data,
        'updatedAt': firestore.SERVER_TIMESTAMP
    })

# ✅ Run forecast for all users in 'staff' collection
def run_forecast_for_all_users():
    staff_docs = db.collection('staff').stream()
    for doc in staff_docs:
        user_id = doc.id
        try:
            generate_forecast_for_user(user_id)
            print(f"✅ Forecast generated for user: {user_id}")
        except Exception as e:
            print(f"❌ Error for user {user_id}: {e}")

# 🚀 Run it
if __name__ == "__main__":
    run_forecast_for_all_users()
