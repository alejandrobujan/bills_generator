# BillsGenerator.Umbrella

Esto está aún en pruebas. El código en la app BillsGenerator es una copia de bills_pipeline.

# Testing

Lanzar postgres en el puerto 5432 con user y pass `postgres`

```console
docker pull postgres
docker run -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres
mix ecto.create
mix ecto.migrate
mix phx.server
curl localhost:4000/api/bills -X POST -H "Content-Type: application/json" -d @data.json
wget localhost:4000/api/bills/1
```
