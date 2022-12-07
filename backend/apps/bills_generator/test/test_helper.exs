IO.puts("Starting tests. It may take a while, since some tests need system workload...")
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(BillsGenerator.Repository.Repo, :manual)
