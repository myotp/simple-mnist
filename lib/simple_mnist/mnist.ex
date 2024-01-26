defmodule SimpleMnist.MNIST do
  import Nx.Defn

  defn init_random_params do
    key = Nx.Random.key(42)
    {w1, new_key} = Nx.Random.normal(key, 0.0, 0.1, shape: {784, 128}, names: [:input, :layer])
    {b1, new_key} = Nx.Random.normal(new_key, 0.0, 0.1, shape: {128}, names: [:layer])

    {w2, new_key} =
      Nx.Random.normal(new_key, 0.0, 0.1, shape: {128, 10}, names: [:layer, :output])

    {b2, _new_key} = Nx.Random.normal(new_key, 0.0, 0.1, shape: {10}, names: [:output])
    {w1, b1, w2, b2}
  end

  defn softmax(logits) do
    Nx.exp(logits) / Nx.sum(Nx.exp(logits), axes: [:output], keep_axes: true)
  end

  defn predict({w1, b1, w2, b2}, batch) do
    batch
    |> Nx.dot(w1)
    |> Nx.add(b1)
    |> Nx.sigmoid()
    |> Nx.dot(w2)
    |> Nx.add(b2)
    |> softmax()
  end

  defn accuracy({w1, b1, w2, b2}, batch_images, batch_labels) do
    Nx.mean(
      Nx.equal(
        Nx.argmax(batch_labels, axis: :output),
        Nx.argmax(predict({w1, b1, w2, b2}, batch_images), axis: :output)
      )
    )
  end

  defn loss({w1, b1, w2, b2}, batch_images, batch_labels) do
    preds = predict({w1, b1, w2, b2}, batch_images)
    -Nx.sum(Nx.mean(Nx.log(preds) * batch_labels, axes: [:output]))
  end

  defn update({w1, b1, w2, b2} = params, batch_images, batch_labels, step) do
    {grad_w1, grad_b1, grad_w2, grad_b2} = grad(params, &loss(&1, batch_images, batch_labels))

    {
      w1 - grad_w1 * step,
      b1 - grad_b1 * step,
      w2 - grad_w2 * step,
      b2 - grad_b2 * step
    }
  end

  defn update_with_averages({_, _, _, _} = cur_params, imgs, tar, avg_loss, avg_accuracy, total) do
    batch_loss = loss(cur_params, imgs, tar)
    batch_accuracy = accuracy(cur_params, imgs, tar)
    avg_loss = avg_loss + batch_loss / total
    avg_accuracy = avg_accuracy + batch_accuracy / total
    {update(cur_params, imgs, tar, 0.01), avg_loss, avg_accuracy}
  end

  def train_epoch(fun, cur_params, imgs, labels) do
    total_batches = Enum.count(imgs)

    imgs
    |> Stream.zip(labels)
    |> Enum.reduce({cur_params, Nx.tensor(0.0), Nx.tensor(0.0)}, fn
      {imgs, tar}, {cur_params, avg_loss, avg_accuracy} ->
        fun.(cur_params, imgs, tar, avg_loss, avg_accuracy, total_batches)
    end)
  end

  def train(fun, imgs, labels, params, opts \\ []) do
    epochs = opts[:epochs] || 5

    for epoch <- 1..epochs, reduce: params do
      cur_params ->
        {time, {new_params, epoch_avg_loss, epoch_avg_acc}} =
          :timer.tc(__MODULE__, :train_epoch, [fun, cur_params, imgs, labels])

        epoch_avg_loss =
          epoch_avg_loss
          |> Nx.backend_transfer()
          |> Nx.to_number()

        epoch_avg_acc =
          epoch_avg_acc
          |> Nx.backend_transfer()
          |> Nx.to_number()

        IO.puts("Epoch #{epoch} Time: #{time / 1_000_000}s")
        IO.puts("Epoch #{epoch} average loss: #{inspect(epoch_avg_loss)}")
        IO.puts("Epoch #{epoch} average accuracy: #{inspect(epoch_avg_acc)}")
        IO.puts("\n")
        new_params
    end
  end

  def load(images_file, labels_file) do
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      read_and_unzip!(images_file)

    train_images =
      images
      |> Nx.from_binary({:u, 8})
      |> Nx.reshape({n_images, n_rows * n_cols}, names: [:batch, :input])
      |> Nx.divide(255)
      |> Nx.to_batched(30)

    IO.puts("#{n_images} #{n_rows}x#{n_cols} images\n")

    <<_::32, n_labels::32, labels::binary>> = read_and_unzip!(labels_file)

    train_labels =
      labels
      |> Nx.from_binary({:u, 8})
      |> Nx.reshape({n_labels, 1}, names: [:batch, :output])
      |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
      |> Nx.to_batched(30)

    IO.puts("#{n_labels} labels\n")

    {train_images, train_labels}
  end

  defp read_and_unzip!(filename) do
    filename
    |> File.read!()
    |> :zlib.gunzip()
  end
end