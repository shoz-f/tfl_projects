defmodule TflDemo.YoloX do
  alias TflDemo.YoloX.Prediction

  def apply_yolox(img_file) do
    img = CImg.load(img_file)

    # yolox prediction
    {:ok, res} = Prediction.apply(img)

    # draw result
    Enum.reduce(res, CImg.dup(img), &draw_object(&2, &1))
  end                                                                                                       

  defp draw_object(cimg, {_name, boxes}) do
    Enum.reduce(boxes, cimg, fn [_score|box], img ->
      [x0, y0, x1, y1] = Enum.map(box, &round(&1))
      CImg.draw_rect(img, x0, y0, x1, y1, {255,0,0})
    end)
  end
end

defmodule TflDemo.YoloX.Prediction do
  use TflInterp, model: "priv/yolox_s.tflite", label: "priv/coco.label"

  @yolox_shape {640, 640}

  def apply(img) do
    # preprocess
    bin = 
      CImg.dup(img)
      |> CImg.get_resize(@yolox_shape, :ul, 114)
      |> CImg.to_flat([{:range, {0.0, 255.0}}, :nchw, :bgr])

    # prediction
    outputs =
      TflDemo.YoloX.Prediction
      |> TflInterp.set_input_tensor(0, bin.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)
      |> Nx.from_binary({:f, 32}) |> Nx.reshape({:auto, 85})

    # postprocess
    boxes  = extract_boxes(outputs, scale(img))
    scores = extract_scores(outputs)

    TflInterp.non_max_suppression_multi_class(__MODULE__,
      Nx.shape(scores), Nx.to_binary(boxes), Nx.to_binary(scores)
    )
  end

  defp extract_boxes(tensor, scale \\ 1.0) do
    {grid, strides} = grid_strides(@yolox_shape, [8, 16, 32])

    [
      Nx.add(Nx.slice_axis(tensor, 0, 2, 1), grid),
      Nx.exp(Nx.slice_axis(tensor, 2, 2, 1))
    ]
    |> Nx.concatenate(axis: 1) |> Nx.multiply(strides) |> Nx.multiply(scale)
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

  defp extract_scores(tensor) do
    Nx.multiply(Nx.slice_axis(tensor, 4, 1, 1), Nx.slice_axis(tensor, 5, 80, 1))
  end
  
  defp scale(img) do
    {w, h, _, _}   = CImg.shape(img)
    {wsize, hsize} = @yolox_shape
    max(w/wsize, h/hsize)
  end
end
