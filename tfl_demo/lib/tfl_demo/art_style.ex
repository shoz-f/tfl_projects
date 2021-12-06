defmodule TflDemo.ArtStyle do
  use GenServer

  alias TflDemo.ArtStyle.Style
  alias TflDemo.ArtStyle.Transfer

  defstruct style: nil, content: nil, shape: nil

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


  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %__MODULE__{}}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_style, img_file}, _from, state) do
    sample = CImg.load(img_file)
    state = %{state| style: Style.get_style(sample)}

    {
      :reply,
      if state.content, do: Transfer.apply_style(state.content, state.style, state.shape),
      state
    }
  end
  
  def handle_call({:apply_style, img_file}, _from, state) do
    content = CImg.load(img_file)
    state = %{state|
      content: CImg.to_flat(CImg.get_resize(content, {384,384})),   # preprocess content image
      shape:   CImg.shape(content)
    }

    {
      :reply,
      if state.style, do: Transfer.apply_style(state.content, state.style, state.shape),
      state
    }
  end
end


defmodule TflDemo.ArtStyle.Style do
  use TflInterp, model: "priv/magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite"
  
  def get_style(img) do
    # preprocess
    bin = img
      |> CImg.get_resize({256,256})
      |> CImg.to_flat()

    # prediction
    __MODULE__
    |> TflInterp.set_input_tensor(0, bin.data)
    |> TflInterp.invoke()
    |> TflInterp.get_output_tensor(0)
  end
end


defmodule TflDemo.ArtStyle.Transfer do
  use TflInterp, model: "priv/magenta_arbitrary-image-stylization-v1-256_int8_transfer_1.tflite"

  def apply_style(img, style, {x,y,_,_}) do
    # prediction
    applied =
      __MODULE__
      |> TflInterp.set_input_tensor(0, img.data)
      |> TflInterp.set_input_tensor(1, style)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)

    # postprocess
    CImg.create_from_bin(applied, 384, 384, 1, 3, "<f4")
    |> CImg.get_resize({x, y})
  end
end
