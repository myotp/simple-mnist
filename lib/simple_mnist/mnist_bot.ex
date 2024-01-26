defmodule SimpleMnist.MnistBot do
  alias SimpleMnist.MNIST

  use GenServer

  def predict(image) do
    IO.inspect(Nx.shape(image), label: "Image tensor shape")
    IO.inspect(image, label: "Predict image", limit: 2000)
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
    {:reply, {:ok, tensor_output_to_number(tensor)}, params}
  end

  @impl GenServer
  def handle_continue(:gen_model, _) do
    IO.puts("#{inspect(self())} generating model")
    params = MNIST.train_model()
    {:noreply, params}
  end

  def tensor_output_to_number(tensor) do
    tensor
    |> Nx.to_flat_list()
    |> IO.inspect(label: "Result tensor")
    |> Enum.zip(0..9)
    |> Enum.sort(:desc)
    |> hd()
    |> elem(1)
  end
end
