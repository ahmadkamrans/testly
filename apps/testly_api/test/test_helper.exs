{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Faker.start()

Absinthe.Test.prime(TestlyAPI.Schema)
Ecto.Adapters.SQL.Sandbox.mode(Testly.Repo, :manual)
