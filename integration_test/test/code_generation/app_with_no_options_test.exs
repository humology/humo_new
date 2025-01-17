defmodule Humo.Integration.CodeGeneration.AppWithNoOptionsTest do
  use Humo.Integration.CodeGeneratorCase, async: true

  @epoch {{1970, 1, 1}, {0, 0, 0}}

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_no_options", fn tmp_dir ->
      {app_root_path, _} =
        generate_humo_app(tmp_dir, "phx_blog", [
          "--no-html",
          "--no-gettext",
          "--no-dashboard"
        ])

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
      assert_tests_pass(app_root_path)
    end)
  end

  test "development workflow works as expected" do
    with_installer_tmp("development_workflow", fn tmp_dir ->
      {app_root_path, _} =
        generate_humo_app(tmp_dir, "phx_blog", [
          "--no-gettext",
          "--no-dashboard"
        ])

      assert_no_compilation_warnings(app_root_path)

      File.touch!(Path.join(app_root_path, "lib/phx_blog_web/views/page_view.ex"), @epoch)

      mix_run!(["ecto.drop"], app_root_path)
      mix_run!(["ecto.create"], app_root_path)

      with_phx_server(app_root_path, fn ->
        :inets.start()
        {:ok, response} = request_with_retries("http://localhost:4000")
        assert response.status_code == 200
        assert response.body =~ "PhxBlog"
      end)

      assert File.stat!(Path.join(app_root_path, "lib/phx_blog_web/views/page_view.ex")).atime > @epoch
      assert_passes_formatter_check(app_root_path)
      assert_tests_pass(app_root_path)
    end)
  end

  defp with_phx_server(app_root_path, function) do
    port = Port.open({:spawn, "iex -S mix phx.server"}, [:binary, {:cd, app_root_path}])
    function.()
    send(port, {self(), :close})
  end

  defp request_with_retries(url, retries \\ 10)

  defp request_with_retries(_url, 0), do: {:error, :out_of_retries}

  defp request_with_retries(url, retries) do
    case url |> to_charlist() |> :httpc.request() do
      {:ok, httpc_response} ->
        {{_, status_code, _}, raw_headers, body} = httpc_response

        {:ok,
         %{
           status_code: status_code,
           headers: for({k, v} <- raw_headers, do: {to_string(k), to_string(v)}),
           body: to_string(body)
         }}

      {:error, {:failed_connect, _}} ->
        Process.sleep(1_000)
        request_with_retries(url, retries - 1)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
