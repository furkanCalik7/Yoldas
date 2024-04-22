NUMBER_OF_CALLS = 5
# Overall point calculation:
# 1. AVG_RATING_WEIGHT of the overall point is the average rating of the consultant
# 2. CALL_RATIO_WEIGHT of the overall point is the number of calls the consultant has answered (no_of_calls_completed) divided by the total number of calls (no_of_calls_received)
#    2.1. If the consultant has not received any calls, the points are calculated as the average rating
# 3. COMPLAINT_WEIGHT of the (Complaint Count × NORMALIZATION_FACTOR / Total Calls)
#    3.1. If the consultant has not completed any calls, the points are calculated as the average rating
AVG_RATING_WEIGHT = 0.6
CALL_RATIO_WEIGHT = 0.3
COMPLAINT_WEIGHT = 0.1
NORMALIZATION_FACTOR = 5

CALL_TIMEOUT = 20  # seconds
MAX_RETRY_COUNT = 3  # times
