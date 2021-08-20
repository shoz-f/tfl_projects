defmodule DemoYolo3 do
  @moduledoc """
  Documentation for `DemoYolo3`.
  """


  @doc """
  """
  def test() do
    img =
      CImg.create("test/dog.jpg")
      |> CImg.resize([416,416])
      |> CImg.to_flatnorm()
    
    TflInterp.set_input_tensor(0, img.data)
    TflInterp.invoke()
    TflInterp.non_max_suppression_multi_class(0, 1)
  end
end
