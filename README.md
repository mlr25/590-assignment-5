# 590-assignment-5

## Team Members 
Madison Roberts and Ashley Price

## Design Rationale 

This project simulates the Sleeping Barber Problem using Elixir and its concurrency model. The system consists of several components: a waiting room, a receptionist, a barber, and customers. It demonstrates how multiple processes can interact asynchronously to simulate a real-world barber shop scenario.

WaitingRoom (GenServer):
- Manages the queue of customers waiting for a haircut.
- Supports checking if space is available, adding customers, and retrieving the next customer.
- The waiting room has a maximum capacity (@max_size).

Receptionist (GenServer):
- Greets customers and directs them to the waiting room if there is space.
- Rejects customers if the waiting room is full.

Barber (GenServer):
- Cuts hair for one customer at a time.
- Goes to sleep if there are no customers in the waiting room.
- Checks the waiting room periodically to see if there are customers to serve.

Customer (Process):
- Simulates customers arriving at the barber shop.
- Each customer is represented by a unique id and arrives at random intervals.

BarberShop (Main Simulation):
- Starts all necessary processes (WaitingRoom, Receptionist, and Barber).
- Generates customers at random intervals to simulate customer arrivals.

## Running the Program 

To start the program run: 

    elixir sleeping_barber.exs