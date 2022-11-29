# BillsGenerator.Umbrella

Esto está aún en pruebas. El código en la app BillsGenerator es una copia de bills_pipeline.

# Testing

Instalar docker y docker-compose.

Desde la carpeta `backend/`

```console
docker-compose up -d
mix ecto.create
mix ecto.migrate
mix phx.server
curl localhost:4000/api/bills -X POST -H "Content-Type: application/json" -d @data.json
wget localhost:4000/api/bills/1 -O bill.pdf
```

Para ver los logs de la base de datos: `docker-compose logs`
