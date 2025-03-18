# team members: Madison Roberts and Ashley Price 

defmodule SleepingBarber do
  def start do
    # Start the barber process
    IO.puts("Starting barber process...")
    barber_pid = spawn_link(__MODULE__, :barber_loop, [self()])

    # Start the waiting room process
    IO.puts("Starting waiting room process...")
    waiting_room_pid = spawn_link(__MODULE__, :waiting_room_loop, [barber_pid, []])

    # Start the receptionist process
    IO.puts("Starting receptionist process...")
    receptionist_pid = spawn_link(__MODULE__, :receptionist_loop, [waiting_room_pid])

    # Start the customer spawner process
    IO.puts("Starting customer spawner process...")
    customer_spawner(receptionist_pid)
  end

  def barber_loop(manager) do
    receive do
      {:cut_hair, customer} ->
        IO.puts("Barber is cutting hair...")
        :timer.sleep(:rand.uniform(3000))  # Simulate cutting hair
        send(customer, :done)
        send(manager, :next_customer)
        barber_loop(manager)

    after 5000 ->  # Wait if no customers
      IO.puts("Barber is sleeping...")
      barber_loop(manager)
    end
  end

  def waiting_room_loop(barber, queue) do
    IO.puts("Waiting room loop is running... Current queue length: #{length(queue)}")
    receive do
      {:arrive, customer} ->
        IO.puts("Customer arrived at waiting room...")
        case length(queue) do
          x when x < 6 ->  # If space in waiting room
            IO.puts("Customer added to waiting room")
            send(barber, {:cut_hair, customer})
            waiting_room_loop(barber, queue ++ [customer])

          _ ->  # If no space
            IO.puts("Waiting room full, customer leaving")
            send(customer, :full)
            waiting_room_loop(barber, queue)
        end

      :next_customer ->
        IO.puts("Processing next customer in waiting room...")
        case queue do
          [next | rest] ->
            send(barber, {:cut_hair, next})
            waiting_room_loop(barber, rest)
          [] ->
            waiting_room_loop(barber, [])
        end
    end
  end

  def receptionist_loop(waiting_room) do
    IO.puts("Receptionist loop is running... Waiting for customers...")
    receive do
      :ready ->
        IO.puts("Receptionist is ready to receive customers...")
        send(waiting_room, :ready)  # Notify waiting room it is ready
        loop_with_ready(waiting_room)
    end
  end

  defp loop_with_ready(waiting_room) do
    receive do
      {:new_customer, customer} ->
        IO.puts("Receptionist received customer, sending to waiting room...")
        send(waiting_room, {:arrive, customer})  # Send the customer to waiting room
        loop_with_ready(waiting_room)
    end
  end

  def customer_spawner(receptionist) do
    spawn(fn ->
      customer_spawner_loop(receptionist)
    end)
  end

  defp customer_spawner_loop(receptionist) do
    IO.puts("Spawning a new customer...")
    :timer.sleep(:rand.uniform(5000))  # Wait for random time before sending customer

    # Wait for the receptionist to be ready
    send(receptionist, :ready)  # Signal that we are ready to send a customer
    receive do
      :ready ->  # Once the receptionist is ready, send the customer
        customer_pid = spawn(__MODULE__, :customer_loop, [])
        IO.puts("Customer spawned, sending to receptionist...")
        send(receptionist, {:new_customer, customer_pid})  # Send customer to receptionist
        customer_spawner_loop(receptionist)  # Recursively spawn new customers
    end
  end

  def customer_loop do
    receive do
      :done -> IO.puts("Customer got a haircut and leaves.")
      :full -> IO.puts("Customer leaves because waiting room is full.")
    end
  end
end

# Start the simulation
SleepingBarber.start()