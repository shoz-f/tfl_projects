defmodule TflDemoWeb.YoloXLive do
  use TflDemoWeb, :live_view
  import TflDemo, only: [init_file: 2, path_static: 1, unique_key: 1]

  @target  "/images/yolox_src.jpg"
  @applied "/images/yolox_res.jpg"

  @impl true
  def mount(_params, _session, socket) do
    yolox = {@target, "/images/dog.jpg"}
      |> init_file(&path_static/1)
      |> TflDemo.YoloX.apply_yolox()

    if yolox do
      CImg.save(yolox, path_static(@applied))
    end

    socket = socket
      |> assign(:content, @target)
      |> assign(:applied, @applied)
      |> allow_upload(:content, accept: ~w(.jpg .jpeg), progress: &handle_upload/3, auto_upload: true)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp handle_upload(:content, entry, socket) do
    if entry.done? do
      socket = assign(socket, :content, unique_key(@target))

      yolox = path_static(@target)
        |> tap(&consume_uploaded_entry(socket, entry, fn %{path: path} -> File.copy!(path, &1) end))
        |> TflDemo.YoloX.apply_yolox()

      if yolox do
        CImg.save(yolox, path_static(@applied))
        {:noreply, assign(socket, :applied, unique_key(@applied))}
      else
        {:noreply, socket}
      end
   else
      {:noreply, socket}
    end
  end
end
