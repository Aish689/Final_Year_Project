from forecast_model import fetch_data, preprocess_data

def predict_performance(employee_id):
    # Fetch the merged data using the updated function
    work_data, task_data = fetch_data(employee_id)
    
    # Merge the work hours and task data (assuming preprocess_data handles this)
    combined_data = preprocess_data(work_data, task_data)
    
    # Check if the data is available
    if combined_data.empty:
        print("No data available for prediction.")
        return

    # Example of processing prediction (you can add your actual prediction model here)
    print("--- Combined Data ---")
    print(combined_data)
    
    # You can add your prediction logic below
    # For instance, you can predict based on work hours and tasks or any other features from combined_data
    # Here you can use machine learning models, statistical analysis, etc.
    
    # Example: Just a placeholder for future prediction logic
    prediction_result = combined_data["hours"].mean()  # This is a simple example, replace with your model

    print(f"Predicted Performance for employee {employee_id}: {prediction_result}")

# Example calling the function with an employee ID
employee_id = "YI4oCo82nJTDT3jMm9cj515ULmY2"
predict_performance(employee_id)
