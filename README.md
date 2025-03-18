# 590-assignment-5

## Team Members 
Madison Roberts and Ashley Price

## Design Rationale 

Barber: the barber process handles haircuts. It sleeps when no customers are available and wakes up when a customer arrives. This process is designed to be hot-swappable, allowing changes in haircut duration or behavior without restarting the system. 
Waiting room: A FIFO queue is used to manage waiting customers, ensuring fairness. Queue size limited to 6. 
Receptionist: greets customers and either sends them to the waiting room or turns them away if full. 
Customer Processes: Each customer is a separate process that waits for service or leaves if the room is full. .The custumer code is hot-swappable, so new customers always use the latest. 
Customer spawner: simulates random customers arrivals by spawning new customer processes at random intervals 

## Running the Program 

To start the program run: 

    elixir sleeping_barber.exs