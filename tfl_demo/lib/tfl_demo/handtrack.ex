defmodule TflDemo.Handtrack do
  alias TflDemo.Handtrack.Prediction

  def apply(img_file) do
    img = CImg.load(img_file)

    Prediction.apply(img)
    |> Nx.to_batched_list(1)
    |> Enum.reduce(CImg.builder(img), &draw_object(&2, &1))
  end
  
  def draw_object(builder, box) do
    [y1, x1, y2, x2] = Nx.to_flat_list(box)
    CImg.draw_rect(builder, x1, y1, x2, y2, {255,0,0})
  end
end


defmodule TflDemo.Handtrack.Prediction do
  use TflInterp, model: "priv/model.tflite"

  @handtrack_shape {300, 300}
  @threshold 0.9
  
  def apply(img) do
    # preprocess
    bin =
      CImg.dup(img)
      |> CImg.get_resize(@handtrack_shape)
#      |> CImg.transpose()
      |> CImg.to_flat(range: {-1.0, 1.0})

    # prediction
    __MODULE__
    |> TflInterp.set_input_tensor(0, bin.data)
    |> TflInterp.invoke()

    [bboxes, scores] = for i <- [0, 2] do
      TflInterp.get_output_tensor(__MODULE__, i)
      |> Nx.from_binary({:f, 32})
      |> Nx.reshape({10, :auto})
    end

    # postprocess
    index = Nx.to_flat_list(scores)
      |> Enum.with_index()
      |> (&for {score, index} <- &1, score >= @threshold do index end).()

    bboxes |> Nx.take(Nx.tensor(index))
  end
end
