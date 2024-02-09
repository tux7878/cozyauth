defmodule Supapasskeys.Repo do
  alias Supapasskeys.Servers.Server

  use Ecto.Repo,
    otp_app: :supapasskeys,
    adapter: Ecto.Adapters.Postgres

  def with_dynamic_repo(nil, fun) do
    fun.()
  end

  def with_dynamic_repo(%Server{database_url: url}, fun) do
    default_dynamic_repo = get_dynamic_repo()

    {:ok, repo} =
      start_link(
        url: url,
        after_connect: {Postgrex, :query!, ["SET search_path TO supapasskeys", []]}
      )

    try do
      put_dynamic_repo(repo)
      fun.()
    after
      put_dynamic_repo(default_dynamic_repo)
      Supervisor.stop(repo)
    end
  end
end
