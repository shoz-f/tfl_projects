defmodule TflDemo do
  @moduledoc """
  TflDemo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def init_file({file, init}, path \\ fn x -> x end) do
    file = path.(file)
    init = path.(init)
    File.copy!(init, file)
    file
  end

  def init_files(init_list, path \\ fn x -> x end) do
    Enum.map(init_list, &init_file(&1, path))
  end

  def path_static(path) do
    Path.join([Application.app_dir(:tfl_demo), "/priv/static", path])
  end

  def unique_key() do
    "#{:os.system_time(:second)}-#{:rand.uniform(999_999_999_999_999)}-#{:erlang.system_info(:scheduler_id)}"
  end
  def unique_key(str) do
    "#{str}?" <> unique_key()
  end
end
