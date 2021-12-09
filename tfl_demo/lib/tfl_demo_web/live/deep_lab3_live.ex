defmodule TflDemoWeb.DeepLab3Live do
  use TflDemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    content = "/images/dog.jpg"
    applied = "/images/deeplab3.jpg"

    deeplab3 = TflDemo.DeepLab3.apply_deeplab3(images_path(content))
    if deeplab3 do
      CImg.save(deeplab3, images_path(applied))
    end

    socket = socket
      |> assign(:content, content)
      |> assign(:applied, applied)
      |> allow_upload(:content, accept: ~w(.jpg .jpeg), progress: &handle_upload/3, auto_upload: true)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp handle_upload(:content, entry, socket) do
    if entry.done? do
      content_file = update_img(:content, entry, socket)
      socket = assign(socket, :content, content_file)

      deeplab3 = TflDemo.DeepLab3.apply_deeplab3(images_path(content_file))
      if deeplab3 do
        File.rm!(images_path(socket.assigns[:applied]))

        applied = unique_path("/images/deeplab3")
        CImg.save(deeplab3, images_path(applied))

        {:noreply, assign(socket, :applied, applied)}
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
