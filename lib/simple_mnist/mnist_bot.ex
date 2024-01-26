defmodule SimpleMnist.MnistBot do
  alias SimpleMnist.MNIST

  use GenServer

  def predict(image) do
    GenServer.call(__MODULE__, {:predict, image})
  end

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg, {:continue, :gen_model}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def handle_call({:predict, image}, _from, params) do
    tensor = MNIST.predict(params, image)
    {:reply, {:ok, tensor}, params}
  end

  @impl GenServer
  def handle_continue(:gen_model, _) do
    IO.puts("#{inspect(self())} generating model")
    params = MNIST.train_model()
    {:noreply, params}
  end
end
