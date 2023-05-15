# Pricing calculator

**The goal**: You should know how much does your project cost now, with 10x or 100x load.


## Deliveries

### Estimated target price for 1K, 100K and 10M HTTP function invocation per month

- 1K invocations: [My Estimate - AWS Pricing Calculator 1K.pdf](My%20Estimate%20-%20AWS%20Pricing%20Calculator%201K.pdf)
- 100K invocations: [My Estimate - AWS Pricing Calculator 100K.pdf](My%20Estimate%20-%20AWS%20Pricing%20Calculator%20100K.pdf)
- 10M invocations: [My Estimate - AWS Pricing Calculator 10M.pdf](My%20Estimate%20-%20AWS%20Pricing%20Calculator%2010M.pdf)

|Service|1K calls|100K calls|10M calls|
|---|---|---|---|
|AWS Lambda|$0.00|$0.02|$2.03|
|AWS RDS|$65.13|$65.13|$65.13|
|AWS Kinesis|$26.28|$26.28|$26.28|
|---|---|---|---|
|**Total**|$91.41|$91.43|$93.44|


### Conclusion:
- The most expensive part of the project is *AWS RDS*.
- There is a way to reduce the bill if to try to get away from using AWS RDS and use AWS DynamoDB instead.
- The total price changes linearly, and its caused by increasing the price change for using AWS Lambda as the number of feature calls grows.
