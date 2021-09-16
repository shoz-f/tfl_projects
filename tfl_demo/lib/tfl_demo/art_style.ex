defmodule TflDemo.ArtStyle.Prediction do
  use TflInterp, model: "priv/magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite"
end

defmodule TflDemo.ArtStyle.Transfer do
  use TflInterp, model: "priv/magenta_arbitrary-image-stylization-v1-256_int8_transfer_1.tflite"
end

defmodule TflDemo.ArtStyle do
  use GenServer

  defstruct style: nil, content: nil, shape: nil

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, %__MODULE__{}}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_style, img_file}, _from, state) do
    sample =
      CImg.create(img_file)
      |> CImg.resize([256,256])
      |> CImg.to_flatnorm()
    state = %{state| style: get_style(sample)}

    if state.content do
      {:reply, apply_style(state.content, state.style, state.shape), state}
    else
      {:reply, nil, state}
    end
  end
  
  def handle_call({:apply_style, img_file}, _from, state) do
    content = CImg.create(img_file)
    state = %{state|
      content: CImg.to_flatnorm(CImg.get_resize(content, [384,384])),
      shape:   CImg.shape(content)
    }

    if state.style do
      {:reply, apply_style(state.content, state.style, state.shape), state}
    else
      {:reply, nil, state}
    end
  end

  defp get_style(img) do
    TflDemo.ArtStyle.Prediction
    |> TflInterp.set_input_tensor(0, img.data)
    |> TflInterp.invoke()
    |> TflInterp.get_output_tensor(0)
  end

  defp apply_style(img, style, {x,y,_,_}) do
    applied =
      TflDemo.ArtStyle.Transfer
      |> TflInterp.set_input_tensor(0, img.data)
      |> TflInterp.set_input_tensor(1, style)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)

    CImg.create_from_f4bin(384, 384, 1, 3, applied)
    |> CImg.resize([x, y])
  end


  def info() do
    GenServer.call(__MODULE__, :info)
  end
  
  def opening(style, content) do
    if info() == %__MODULE__{} do
      set_style(style)
      artistic(content)
    end
  end

  def set_style(img_file) do
    GenServer.call(__MODULE__, {:set_style, img_file})
  end
  
  def artistic(img_file) do
    GenServer.call(__MODULE__, {:apply_style, img_file})
  end
end
