# Development

Instalar docker y docker-compose.

Desde la carpeta `backend/`

```console
docker-compose up -d
mix ecto.create && mix ecto.migrate && mix phx.server
curl localhost:4000/api/bills -X POST -H "Content-Type: application/json" -d @example.json
wget localhost:4000/api/bills/1/download -O bill.pdf
```

Para lanzar el frontend:

```console
cd ../frontend
npm install
npm run dev
```

Se debería poder ver el frontend en `localhost:3000`.

Para ver los logs de la base de datos: `docker-compose logs`

## Testing

Para lanzar los tests, se tiene que tener la base de datos
lanzada de la misma forma que en el apartado anterior, y ejecutar, desde la carpeta `backend/`:

```console
mix test
```
