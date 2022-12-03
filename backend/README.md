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

- [ ] Mejorar configs (más configs, y más valores permitidos de las que ya hay)

- [ ] Mejorar el latex generado en el formatter.

- [ ] Diagramas c4 y documentación de las funciones

- [ ] Hacer tests, tanto de integración, como de cada filtro individualmente. Para algunos de integración/unitarios, podemos consultar los que tengo hecho para mi lider-trabajador (práctica anterior). Hacer muchos tests para validar las facturas correctas, ese trabajo lo hace el filtro BillValidator. Podemos hacer esto último de dos maneras, coger el valor que sale del filtro y testear eso, pero para eso necesitaríamos simular todo lo anterior. O bien, hacer que se procese el filtro al completo y consultar el valor introducido en la base de datos. El primero sería más bien un test unitario de ese filtro, y el segundo un test de integración completa.

- [ ] Limpiar código del StandardLeader y ServiceHandler (mejor eso lo hago yo(jorge)), en el mapa de busy_workers se guarda el cliente. Dejarlo así? Podría ser útil para los logs... pero no sé si está bien dejarlo. Utilizar otra estructura que no sea un mapa me parece poco eficiente.

- [x] Capa de validación de la bill request? Deberíamos comprobar que el user no es vacío, que el title tampoco,
      que las properties no sean nulas... Estaría bien tenerlo centralizado en una capa. Ahora mismo, solo se hace esa comprobación en el JSONParser, para el config.

- [ ] Componente en la sombra para monitorizar los líderes? Podríamos guardar en un log el número de workers que tienen en cada instante. Útil para sacar gráficas del comportamiento del sistema. Para esto, habría que modificar el StandardLeader para que se le pueda preguntar el número de trabajadores. Además, podría ser una medida de prevención de errores.

- [ ] Paginar las peticiones a /bills? Pueden ser muchas para ser mandadas el front... Si da mucho trabajo, mejor pasar de esto. Permitir más parámetros? por ejemplo, filtrar las bills por rango de fecha...

# Notas

Tenemos táctica de repuesto en los workers, debido a que si uno peta, el leader también peta al estar linkeado, y también petaría el supervisor. Entonces, se volvería a lanzar el líder y funcionaría bien.

Al modificar algún campo de input en el front, se tiene que quitar el botón de download bill. Además, una vez se le de al botón, no debería quitarse y poner generate, ya que la bill debería ser la misma y no hace falta volver a generarla.
