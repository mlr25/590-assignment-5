# Team Members: Madison Roberts and Ashley Price
defmodule WaitingRoom do
  use GenServer
  
  @max_size 6
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  
  def has_space? do
    GenServer.call(__MODULE__, :has_space)
  end
  
  def add_customer(customer_pid) do
    GenServer.cast(__MODULE__, {:add_customer, customer_pid})
  end
  
  def get_next_customer do
    GenServer.call(__MODULE__, :get_next_customer)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call(:has_space, _from, state) do
    {:reply, length(state) < @max_size, state}
  end
  
  def handle_call(:get_next_customer, _from, [next | rest]) do
    {:reply, next, rest}
  end
  def handle_call(:get_next_customer, _from, []), do: {:reply, :empty, []}
  
  def handle_cast({:add_customer, customer_pid}, state) when length(state) < @max_size do
    IO.puts("WaitingRoom: Customer #{inspect customer_pid} added to queue.")
    {:noreply, state ++ [customer_pid]}
  end
  def handle_cast({:add_customer, _}, state) do
    IO.puts("WaitingRoom: Queue full, rejecting customer.")
    {:noreply, state}
  end
end

# Receptionist Process
defmodule Receptionist do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{waiting_room: WaitingRoom}, name: __MODULE__)
  end

  def new_customer(customer_pid) do
    IO.puts("Receptionist: Greeting customer #{inspect customer_pid}.")
    GenServer.cast(__MODULE__, {:new_customer, customer_pid})
  end

  def init(state), do: {:ok, state}

  def handle_cast({:new_customer, customer_pid}, state) do
    if WaitingRoom.has_space?() do
      IO.puts("Receptionist: Sending customer #{inspect customer_pid} to waiting room.")
      WaitingRoom.add_customer(customer_pid)
    else
      IO.puts("Receptionist: Customer #{inspect customer_pid} turned away, no space.")
    end
    {:noreply, state}
  end
end

# Barber Process
defmodule Barber do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{waiting_room: WaitingRoom}, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :next_customer, 1000)
    {:ok, state}
  end

  def handle_info(:next_customer, state) do
    case WaitingRoom.get_next_customer() do
      :empty -> 
        IO.puts("Barber: No customers, going to sleep.")
      customer -> 
        IO.puts("Barber: Cutting hair for #{inspect customer}...")
        :timer.sleep(:rand.uniform(3000)) # Random haircut time
        IO.puts("Barber: Finished haircut for #{inspect customer}.")
    end
    Process.send_after(self(), :next_customer, 1000)
    {:noreply, state}
  end
end

# Customer Process
defmodule Customer do
  def start_link(id) do
    spawn(fn -> arrive(id) end)
  end

  defp arrive(id) do
    IO.puts("Customer #{id} arriving at shop.")
    Receptionist.new_customer(self())
  end
end

# Simulation
defmodule BarberShop do
  def start do
    {:ok, _} = WaitingRoom.start_link([])
    {:ok, _} = Receptionist.start_link([])
    {:ok, _} = Barber.start_link([])
    spawn(&generate_customers/0)
    :timer.sleep(:infinity) # KEEP MAIN PROCESS ALIVE
  end
  
  defp generate_customers do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.each(fn id ->
      :timer.sleep(:rand.uniform(2000)) # Random arrival times
      Customer.start_link(id)
    end)
  end
end

# Start Simulation
BarberShop.start()
