# import library
import pandas as pd
import matplotlib.pyplot as plt

# Read in the data
schools = pd.read_csv("schools.csv")

# Preview the data
schools.head()

# 1. Which NYC school have the best math results?

# The best math results are at least 80% of the maximum possible score
best_math_score = 800*0.8
print(best_math_score)


best_math_schools = schools[schools["average_math"]>best_math_score][["school_name", "average_math"]].sort_values(by = "average_math", ascending = False)


print(best_math_schools)

# 2. What are the top 10 performing schools based on the combined SAT scores?

# create average SAT score column
schools['total_SAT'] = (schools['average_math']+schools['average_reading']+schools['average_writing'])

# subset school and sorting data to find 10 schools
top_10_schools = schools[["school_name", "total_SAT"]].sort_values(by = "total_SAT", ascending = False).head(10)

print(top_10_schools)

# 3. Which single borough has the largest standard deviation in the combined SAT score?
largest_std_dev = schools.groupby("borough").agg(num_schools = ("school_name", "count"), average_SAT = ("total_SAT", "mean"), std_SAT = ("total_SAT", "std")).round(2).sort_values(by = "std_SAT", ascending = False).head(1)

print(largest_std_dev)
