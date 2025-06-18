import firebase_admin
from firebase_admin import credentials, firestore
from statistics import mean
from datetime import datetime
import pytz
from calendar import monthrange

print("🚀 Script started")

cred = credentials.Certificate(r"E:\AI Powered system\finalFolder\finalDecision.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def should_evaluate(threshold_day=22):
    today = datetime.now()
    _, total_days = monthrange(today.year, today.month)
    result = threshold_day <= today.day <= total_days
    print(f"⏰ Checking date: {today.day}, should evaluate? {result}")
    return result

def evaluate_decisions_from_forecasts():
    if not should_evaluate():
        print("⏳ Too early in the month to evaluate.")
        return

    forecast_docs = db.collection('forecast_results').stream()

    for doc in forecast_docs:
        user_id = doc.id
        print(f"\n🔍 Checking user: {user_id}")

        attendance_doc = db.collection('forecast_results').document(user_id).get()
        performance_doc = db.collection('performance_results').document(user_id).get()

        if not attendance_doc.exists:
            print(f"⚠️ No attendance doc for {user_id}")
            continue
        if not performance_doc.exists:
            print(f"⚠️ No performance doc for {user_id}")
            continue

        attendance_data = attendance_doc.to_dict()
        performance_data = performance_doc.to_dict()

        print(f"Attendance data: {attendance_data}")
        print(f"Performance data: {performance_data}")

        actual_attendance = attendance_data.get('actual', None)
        forecast_performance = performance_data.get('forecast', None)

        if actual_attendance is None:
            print(f"⚠️ Missing 'actual' attendance for {user_id}")
            continue
        if forecast_performance is None:
            print(f"⚠️ Missing 'forecast' performance for {user_id}")
            continue

        if not isinstance(actual_attendance, list):
            print(f"⚠️ 'actual' attendance is not a list for {user_id}: {actual_attendance}")
            continue
        if not isinstance(forecast_performance, list):
            print(f"⚠️ 'forecast' performance is not a list for {user_id}: {forecast_performance}")
            continue

        # Debug: Print sample entries
        if len(actual_attendance) > 0:
            print(f"Sample attendance entry keys: {list(actual_attendance[0].keys())}")
        if len(forecast_performance) > 0:
            print(f"Sample performance entry keys: {list(forecast_performance[0].keys())}")

        # Extract attendance 'y' values
        attendance_values = []
        for entry in actual_attendance:
            y_val = entry.get('y')
            if y_val is not None:
                attendance_values.append(y_val)
            else:
                print(f"⚠️ Attendance entry missing 'y': {entry}")

        if not attendance_values:
            print(f"⚠️ No valid attendance 'y' values for {user_id}")
            continue

        avg_attendance = mean(attendance_values)

        # Extract performance 'yhat' values and normalize
        performance_values = []
        for entry in forecast_performance:
            yhat_val = entry.get('yhat')
            if yhat_val is not None:
                normalized = max(0.0, min(yhat_val / 10.0, 1.0))
                performance_values.append(normalized)
            else:
                print(f"⚠️ Performance entry missing 'yhat': {entry}")

        if not performance_values:
            print(f"⚠️ No valid performance 'yhat' values for {user_id}")
            continue

        avg_performance = mean(performance_values)

        print(f"Avg Attendance: {avg_attendance:.2f}, Avg Performance: {avg_performance:.2f}")

        # Decision logic
        if avg_attendance >= 0.8 and avg_performance >= 0.8:
            decision = "Reward: 20% salary bonus"
        elif avg_attendance < 0.6 and avg_performance < 0.5:
            decision = "Warning: Risk of termination"
        else:
            decision = "No Action"

        # Save decision to Firestore
        db.collection('employee_decisions').document(user_id).set({
            'userId': user_id,
            'average_attendance_pct': round(avg_attendance * 100, 2),
            'average_performance_pct': round(avg_performance * 100, 2),
            'decision': decision,
            'evaluated_at': datetime.now(pytz.UTC).isoformat()
        })

        print(f"✅ Decision for {user_id}: {decision}")

if __name__ == "__main__":
    print("▶️ Calling evaluate_decisions_from_forecasts()")
    evaluate_decisions_from_forecasts()
