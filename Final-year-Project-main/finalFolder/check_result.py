import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Sample Data (you can replace this with your actual data from Firestore)
employee_ids = ['HiuG25i7JCduFa4vG9drxs3H0HA2', 'YI4oCo82nJTDT3jMm9cj515ULmY2']
attendance = [0.8, 0.85]  # Attendance percentages
performance = [0.9, 0.88]  # Performance scores
reward = ['Reward: 20% salary bonus', 'Reward: 20% salary bonus']  # Rewards or None

# Create DataFrame
data = {
    'Employee ID': employee_ids,
    'Attendance': attendance,
    'Performance': performance,
    'Reward': reward
}

df = pd.DataFrame(data)

# Plotting
fig, ax = plt.subplots(figsize=(10, 6))

# Plot Attendance and Performance
ax.scatter(df['Attendance'], df['Performance'], c='blue', label='Employee')

# Annotate reward status
for i, txt in enumerate(df['Reward']):
    ax.annotate(txt, (df['Attendance'][i], df['Performance'][i]), fontsize=9, ha='right')

# Adding labels and title
ax.set_xlabel('Attendance (%)')
ax.set_ylabel('Performance (%)')
ax.set_title('Employee Attendance vs Performance')

# Show grid and legend
ax.grid(True)
plt.legend()

# Show the plot
plt.show()
