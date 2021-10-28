defmodule TflDemo.YoloX.Prediction do
  use TflInterp, model: "priv/yolox_s.tflite", label: "priv/coco.label"
end

defmodule TflDemo.YoloX do
  @yolox_shape {640, 640}

  @doc false
  def apply_yolox(img_file) do
    # preprocess
    img = CImg.create(img_file)

    bin = img
      |> CImg.get_packed([640,640], 114)
      |> CImg.to_flatf4(true, true)

    # prediction
    outputs =
      TflDemo.YoloX.Prediction
      |> TflInterp.set_input_tensor(0, bin.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)
      |> Nx.from_binary({:f, 32}) |> Nx.reshape({:auto, 85})

    # postprocess
    boxes  = extract_boxes(outputs)
    scores = extract_scores(outputs)

    {:ok, res} = TflInterp.non_max_suppression_multi_class(TflDemo.YoloX.Prediction,
      Nx.shape(scores), Nx.to_binary(boxes), Nx.to_binary(scores)
    )
    
    # draw result
    {w, h, _, _}   = CImg.shape(img)
    {wsize, hsize} = @yolox_shape
    scale = max(w/wsize, h/hsize)

    Enum.reduce(res, CImg.dup(img), &draw_object(&2, &1, scale))
  end

  @doc false
  def extract_boxes(tensor) do
    {grid, strides} = grid_strides(@yolox_shape, [8, 16, 32])

    [
      Nx.add(Nx.slice_axis(tensor, 0, 2, 1), grid),
      Nx.exp(Nx.slice_axis(tensor, 2, 2, 1))
    ]
    |> Nx.concatenate(axis: 1) |> Nx.multiply(strides)
  end

  defp grid_strides({wsize, hsize}, block) do
    reso = Enum.map(block, fn x -> {div(hsize, x), div(wsize, x), x} end)
    {
      Enum.map(reso, &grid/1)    |> Nx.concatenate(axis: 0),
      Enum.map(reso, &strides/1) |> Nx.concatenate(axis: 0)
    }
  end

  defp grid({hsize, wsize, _}) do
    xv = Nx.iota({wsize}) |> Nx.tile([hsize, 1])
    yv = Nx.iota({hsize}) |> Nx.tile([wsize, 1]) |> Nx.transpose
    Nx.stack([xv, yv], axis: 2) |> Nx.reshape({:auto, 2})
  end
  
  defp strides({hsize, wsize, stride}) do
    Nx.tensor(stride) |> Nx.tile([hsize*wsize, 1])
  end

  @doc false
  def extract_scores(tensor) do
    Nx.multiply(Nx.slice_axis(tensor, 4, 1, 1), Nx.slice_axis(tensor, 5, 80, 1))
  end

  @doc false
  def draw_object(cimg, {_name, boxes}, scale) do
    Enum.reduce(boxes, cimg, fn [_score|box], img ->
      [x0, y0, x1, y1] = Enum.map(box, &round(scale * &1))
      CImg.draw_rect(img, x0, y0, x1, y1, {255,255,0})
    end)
  end
end
