import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from prophet import Prophet
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import pytz
import time
from google.auth.exceptions import GoogleAuthError
import grpc

# Initialize Firestore client
def initialize_firestore():
    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(r"E:\AI Powered system\perfomance_prediction\myProject_file.json")
            firebase_admin.initialize_app(cred)
            print("Firestore initialized successfully!")
        return firestore.client()
    except Exception as e:
        print(f"Error initializing Firestore: {e}")
        return None

# Fetch all user IDs
def fetch_all_user_ids(db):
    print("Fetching all user IDs...")
    user_ids = []
    staff_ref = db.collection('staff')
    staff_docs = staff_ref.stream()
    for doc in staff_docs:
        data = doc.to_dict()
        if 'userId' in data:
            user_ids.append(data['userId'])
    print(f"Total users found: {len(user_ids)}")
    return user_ids

# Fetch work_hours and tasks data for a user with retry logic
def fetch_data_with_retries(db, user_id, retries=3, delay=5):
    attempt = 0
    while attempt < retries:
        try:
            print(f"Fetching data for user: {user_id}")

            # Fetch work hours
            work_docs = list(db.collection('work_hours')
                                .where('userId', '==', user_id)
                                .stream())
            work_data = [doc.to_dict() for doc in work_docs]

            # Fetch tasks
            task_docs = list(db.collection('tasks')
                                .where('employeeId', '==', user_id)
                                .stream())
            task_data = [doc.to_dict() for doc in task_docs]

            return work_data, task_data

        except Exception as e:
            attempt += 1
            print(f"Attempt {attempt}/{retries} failed due to error: {e}. Retrying in {delay} seconds...")
            time.sleep(delay)

    print(f"All attempts failed for user {user_id}. Skipping.")
    return [], []


# Preprocess the data
def preprocess_data(work_data, task_data):
    print("Preprocessing data...")

    work_df = pd.DataFrame(work_data)
    if work_df.empty:
        print("No work_hours data found.")
        return None

    work_df['date'] = pd.to_datetime(work_df['date']).dt.date
    work_df['hours'] = pd.to_numeric(work_df['hours'], errors='coerce')

    task_df = pd.DataFrame(task_data)
    if task_df.empty:
        print("No tasks data found.")
        return None

    task_df['submissionDate'] = pd.to_datetime(task_df['submissionDate']).dt.date
    task_df['dueDate'] = pd.to_datetime(task_df['dueDate']).dt.date

    task_df['task_status'] = (task_df['submissionDate'] <= task_df['dueDate']).astype(int)

    task_status_df = task_df.groupby('submissionDate').agg({'task_status': 'mean'}).reset_index()
    task_status_df = task_status_df.rename(columns={'submissionDate': 'date'})

    combined_df = pd.merge(work_df, task_status_df, on='date', how='left')
    combined_df['task_status'] = combined_df['task_status'].fillna(1)

    return combined_df

# Forecast performance
def forecast_performance(db, user_id):
    print(f"Starting forecast for user {user_id}...")

    # Fetch data with retry logic
    work_data, task_data = fetch_data_with_retries(db, user_id)
    combined_df = preprocess_data(work_data, task_data)

    if combined_df is None:
        print(f"Skipping user {user_id} due to insufficient data.")
        return

    df = combined_df.rename(columns={'date': 'ds', 'hours': 'y'})
    df['ds'] = pd.to_datetime(df['ds'])
    df['task_status'] = pd.to_numeric(df['task_status'], errors='coerce')

    model = Prophet()
    model.add_regressor('task_status')
    model.fit(df)

    future = model.make_future_dataframe(periods=7)
    future = future.merge(df[['ds', 'task_status']], on='ds', how='left')
    future['task_status'] = future['task_status'].fillna(1)

    forecast = model.predict(future)

    print(f"Forecast completed for user {user_id}.\n")

    # ✅ Save forecast results to Firestore
    try:
        forecast_result = forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].tail(7)
        forecast_result['ds'] = forecast_result['ds'].dt.strftime('%Y-%m-%d %H:%M:%S')
        forecast_result = forecast_result.to_dict(orient='records')

        # Format actual data
        actual_result = df[['ds', 'y']].copy()
        actual_result['ds'] = actual_result['ds'].dt.strftime('%Y-%m-%d %H:%M:%S')
        actual_result = actual_result.to_dict(orient='records')

        result_data = {
            "actual": actual_result,
            "forecast": forecast_result,
            "generated_at": datetime.now(pytz.UTC).isoformat()
        }

        # Optional: Delete old data first
        db.collection("performance_results").document(user_id).delete()

        # Save new performance prediction
        db.collection("performance_results").document(user_id).set(result_data)

        print(f"✅ Performance prediction saved for user {user_id}")

    except Exception as e:
        print(f"❌ Failed to save performance prediction for user {user_id}: {e}")

# Main run
if __name__ == "__main__":
    db = initialize_firestore()
    if db:
        user_ids = fetch_all_user_ids(db)
        for user_id in user_ids:
            forecast_performance(db, user_id)
