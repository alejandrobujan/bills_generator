# BillsGenerator.Umbrella

Esto está aún en pruebas. El código en la app BillsGenerator es una copia de bills_pipeline.

# Testing

Instalar docker y docker-compose.

Desde la carpeta `backend/`

```console
docker-compose up -d
mix ecto.create && mix ecto.migrate && mix phx.server
curl localhost:4000/api/bills -X POST -H "Content-Type: application/json" -d @data.json
wget localhost:4000/api/bills/1 -O bill.pdf
```

Para lanzar el frontend:

```console
cd ../frontend
npm install
npm run dev
```

Se debería poder ver el frontend en `localhost:3000`.

Para ver los logs de la base de datos: `docker-compose logs`

# TO-DO

[ ] Mejorar configs (más configs, y más valores permitidos de las que ya hay)

[ ] Mejorar el latex generado en el formatter.

[ ] Limpiar código del StandardLeader y ServiceHandler (mejor eso lo hago yo(jorge)), en el mapa de busy_workers se guarda el cliente. Dejarlo así? Podría ser útil para los logs... pero no sé

[x] Capa de validación de la bill request? Deberíamos comprobar que el user no es vacío, que el title tampoco,
que las properties no sean nulas... Estaría bien tenerlo centralizado en una capa. Ahora mismo, solo se hace esa comprobación en el JSONParser, para el config.

[ ] Componente en la sombra para monitorizar los líderes? Podríamos guardar en un log el número de workers que tienen en cada instante. Útil para sacar gráficas del comportamiento del sistema. Para esto, habría que modificar el StandardLeader para que se le pueda preguntar el número de trabajadores. Además, podría ser una medida de prevención de errores.

[ ] Táctica de disponibilidad de repuesto. Ahora mismo, en el ServiceHandler, en la función assignJob, asumo que mis trabajadores pueden recibir mensajes. Estaría bien hacer una comprobación de si está vivo/puede recibir mensajes,y si no lo está, spawnear un nuevo worker en su lugar. Se puede spawnear con la función spawn_worker, pero el nuevo worker se irá al final de la cola y responderá otro worker, o podríamos spawnear un nuevo worker y mandarle el trabajo a ese. Para esto último no tendríamos que usar la función spawn_workers.

[ ] Hacer tests, tanto de integración, como de cada filtro individualmente. Para algunos de integración/unitarios, podemos consultar los que tengo hecho para mi lider-trabajador (práctica anterior). Hacer muchos tests para validar las facturas correctas, ese trabajo lo hace el filtro BillValidator. Podemos hacer esto último de dos maneras, coger el valor que sale del filtro y testear eso, pero para eso necesitaríamos simular todo lo anterior. O bien, hacer que se procese el filtro al completo y consultar el valor introducido en la base de datos. El primero sería más bien un test unitario de ese filtro, y el segundo un test de integración completa.

[ ] El servidor debería responder en los endpoints directamente? La idea es que funcione como un directorio
y tenga el mínimo trabajo posible...La lógica de descargar, ver las bills,etc... debería estar en otro componente?
