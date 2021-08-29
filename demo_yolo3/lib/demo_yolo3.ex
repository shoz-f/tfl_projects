defmodule DemoYolo3 do
  @moduledoc """
  Documentation for `DemoYolo3`.
  """

  alias DemoYolo3.Yolo3

  @doc """
  """
  def test() do
    img =
      CImg.create("test/dog.jpg")
      |> CImg.resize([416,416])
      |> CImg.to_flatnorm()
    
    TflInterp.set_input_tensor(Yolo3, 0, img.data)
    TflInterp.invoke(Yolo3)
    TflInterp.non_max_suppression_multi_class(Yolo3, 0, 1, 0.5, 0.25, 0.0)
  end
end
