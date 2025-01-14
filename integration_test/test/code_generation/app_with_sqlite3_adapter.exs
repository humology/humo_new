defmodule Humo.Integration.CodeGeneration.AppWithSQLite3AdapterTest do
  use Humo.Integration.CodeGeneratorCase, async: true

  describe "phx.gen.html" do
    @tag :skip
    @tag database: :sqlite3
    test "has a passing test suite" do
      with_installer_tmp("app_with_defaults", fn tmp_dir ->
        {app_root_path, _} =
          generate_humo_app(tmp_dir, "default_sqlite3_app", ["--database", "sqlite3"])

        mix_run!(~w(phx.gen.html Blog Post posts title body:string status:enum:unpublished:published:deleted), app_root_path)

        modify_file(Path.join(app_root_path, "lib/default_sqlite3_app_web/router.ex"), fn file ->
          inject_before_final_end(file, """

            scope "/", DefaultMysqlAppWeb do
              pipe_through [:browser]

              resources "/posts", PostController
            end
          """)
        end)

        drop_test_database(app_root_path)
        assert_tests_pass(app_root_path)
      end)
    end
  end

  describe "phx.gen.json" do
    @tag :skip
    @tag database: :sqlite3
    test "has a passing test suite" do
      with_installer_tmp("app_with_defaults", fn tmp_dir ->
        {app_root_path, _} =
          generate_humo_app(tmp_dir, "default_sqlite3_app", ["--database", "sqlite3"])

        mix_run!(~w(phx.gen.json Blog Post posts title body:string status:enum:unpublished:published:deleted), app_root_path)

        modify_file(Path.join(app_root_path, "lib/default_sqlite3_app_web/router.ex"), fn file ->
          inject_before_final_end(file, """

            scope "/", DefaultMysqlAppWeb do
              pipe_through [:api]

              resources "/posts", PostController, except: [:new, :edit]
            end
          """)
        end)

        drop_test_database(app_root_path)
        assert_tests_pass(app_root_path)
      end)
    end
  end

  describe "phx.gen.live" do
    @tag :skip
    @tag database: :sqlite3
    test "has a passing test suite" do
      with_installer_tmp("app_with_defaults", fn tmp_dir ->
        {app_root_path, _} =
          generate_humo_app(tmp_dir, "default_sqlite3_app", ["--database", "sqlite3", "--live"])

        mix_run!(~w(phx.gen.live Blog Post posts title body:string status:enum:unpublished:published:deleted), app_root_path)

        modify_file(Path.join(app_root_path, "lib/default_sqlite3_app_web/router.ex"), fn file ->
          inject_before_final_end(file, """

            scope "/", DefaultMysqlAppWeb do
              pipe_through [:browser]

              live "/posts", PostLive.Index, :index
              live "/posts/new", PostLive.Index, :new
              live "/posts/:id/edit", PostLive.Index, :edit

              live "/posts/:id", PostLive.Show, :show
              live "/posts/:id/show/edit", PostLive.Show, :edit
            end
          """)
        end)

        drop_test_database(app_root_path)
        assert_tests_pass(app_root_path)
      end)
    end
  end
end
