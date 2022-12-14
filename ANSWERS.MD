Q1: Please explain what is the advantage of using SQS in this solution.
A:  1. Easy to setup - no infrastructure is required and we can simply use the API to manage SQS
    2  Queues gets automatically scaled as the number of message increases and de-scales when message decreases.
    3. Deduplication - SQS FIFO queues are ideal for taking care of any duplicate messages.


Q2: Compare SQS to a message broker you have used before. What are the differences? Strong/weak points? (If you did not use such a solution, please skip this question)
A:  No experience with broker services(skipping this question)


Q3: If we run multiple instances of this tool, what prevents a message from processed twice?
A: Visibilitytimeout - period of time during which Amazon SQS prevents other consumers from receiving and processing the message.


Q4: In very rough terms, can you suggest an alternative solution aside from using SQS from your previous experience using different technologies?
A: RabbitMQ can be good alternative for queuing messages.