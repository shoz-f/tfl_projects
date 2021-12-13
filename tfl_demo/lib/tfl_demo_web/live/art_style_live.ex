defmodule TflDemoWeb.ArtStyleLive do
  use TflDemoWeb, :live_view
  import TflDemo, only: [init_files: 2, path_static: 1, unique_key: 1]

  @style   "/images/art_style.jpg"
  @target  "/images/atr_src.jpg"
  @applied "/images/art_res.jpg"

  @impl true
  def mount(_params, _session, socket) do
    artistic = [{@style, "/images/style23.jpg"}, {@target, "/images/belfry-2611573_1280.jpg"}]
      |> init_files(&path_static/1)
      |> (fn [style, target] -> TflDemo.ArtStyle.opening(style, target) end).()

    if artistic do
      CImg.save(artistic, path_static(@applied))
    end

    socket = socket
      |> assign(:style,   @style)
      |> assign(:content, @target)
      |> assign(:applied, @applied)
      |> allow_upload(:style,   accept: ~w(.jpg .jpeg), progress: &handle_upload/3, auto_upload: true)
      |> allow_upload(:content, accept: ~w(.jpg .jpeg), progress: &handle_upload/3, auto_upload: true)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp handle_upload(:style, entry, socket) do
    if entry.done? do
      socket = assign(socket, :style, unique_key(@style))

      artistic = path_static(@style)
        |> tap(&consume_uploaded_entry(socket, entry, fn %{path: path} -> File.copy!(path, &1) end))
        |> TflDemo.ArtStyle.set_style()

      if artistic do
        CImg.save(artistic, path_static(@applied))
        {:noreply, assign(socket, :applied, unique_key(@applied))}
      else
        {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  defp handle_upload(:content, entry, socket) do
    if entry.done? do
      socket = assign(socket, :content, unique_key(@target))

      artistic = path_static(@target)
        |> tap(&consume_uploaded_entry(socket, entry, fn %{path: path} -> File.copy!(path, &1) end))
        |> TflDemo.ArtStyle.artistic()

      if artistic do
        CImg.save(artistic, path_static(@applied))
        {:noreply, assign(socket, :applied, unique_key(@applied))}
      else
        {:noreply, socket}
      end
   else
      {:noreply, socket}
    end
  end
end
