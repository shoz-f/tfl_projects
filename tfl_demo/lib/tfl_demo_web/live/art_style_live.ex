defmodule TflDemoWeb.ArtStyleLive do
  use TflDemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    style    = "/images/style23.jpg"
    content  = "/images/belfry-2611573_1280.jpg"
    applied  = "/images/art.jpg"

    artistic = TflDemo.ArtStyle.opening(images_path(style), images_path(content))
    if artistic do
      CImg.save(artistic, images_path(applied))
    end
    
    socket = socket
      |> assign(:style,   style)
      |> assign(:content, content)
      |> assign(:applied, applied)
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
      style_file = update_img(:style, entry, socket)

      applied = TflDemo.ArtStyle.set_style(images_path(style_file))
      if applied do
        File.rm!(images_path(socket.assigns[:applied]))

        path = unique_path("/images/art")
        CImg.save(applied, images_path(path))

        {:noreply, assign(socket, :applied, path)}
      else
        {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  defp handle_upload(:content, entry, socket) do
    if entry.done? do
      content_file = update_img(:content, entry, socket)
      socket = assign(socket, :content, content_file)

      applied = TflDemo.ArtStyle.artistic(images_path(content_file))
      if applied do
        File.rm!(images_path(socket.assigns[:applied]))

        path = unique_path("/images/art")
        CImg.save(applied, images_path(path))

        {:noreply, assign(socket, :applied, path)}
      else
        {:noreply, socket}
      end
   else
      {:noreply, socket}
    end
  end

  defp update_img(key, entry, socket) do
    # remove old image
    File.rm!(images_path(socket.assigns[key]))

    # get new image
    consume_uploaded_entry(socket, entry, fn %{path: path} ->
      Path.join("/images", "#{Path.basename(path)}.jpg")
      |> tap(&File.cp!(path, images_path(&1)))
    end)
  end
  
  defp images_path(path) do
    Path.join([Application.app_dir(:tfl_demo), "/priv/static", path])
  end

  defp unique_path(prefix, surfix \\ ".jpg") do
    "#{prefix}-#{:os.system_time(:second)}-#{:rand.uniform(999_999_999_999_999)}-#{:erlang.system_info(:scheduler_id)}#{surfix}"
  end
end
