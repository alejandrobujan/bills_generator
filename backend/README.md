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

- [ ] Mejorar el latex generado en el formatter. Estaría bien incluír divisas, precio con y sin tasas, descuento aplicado por ítem o en global...Añadir logo de la empresa? no sé como iría en el json... Podría ir un link a una imagen, y que en un filtro se descargase? No me convence mucho.

- [ ] Internationalization en el latex formatter? puede ser un requisito no funcional.

- [ ] Diagramas c4 y documentación de las funciones

- [x] Hacer tests, tanto de integración, como de cada filtro individualmente. Para algunos de integración/unitarios, podemos consultar los que tengo hecho para mi lider-trabajador (práctica anterior). Hacer muchos tests para validar las facturas correctas, ese trabajo lo hace el filtro BillValidator. Podemos hacer esto último de dos maneras, coger el valor que sale del filtro y testear eso, pero para eso necesitaríamos simular todo lo anterior. O bien, hacer que se procese el filtro al completo y consultar el valor introducido en la base de datos. El primero sería más bien un test unitario de ese filtro, y el segundo un test de integración completa.

- [x] Hice algunos tests unitarios para las entidades. Aún falta hacer algunos para las que quedan. Para eso, mirar el directorio `backend/apps/bills_generator/test/entities/`, y los doctest de las entities.

- [x] Limpiar código del GenFilter y ServiceHandler (mejor eso lo hago yo(jorge)), en el mapa de busy_workers se guarda el cliente. Dejarlo así? Podría ser útil para los logs... pero no sé si está bien dejarlo. Utilizar otra estructura que no sea un mapa me parece poco eficiente.

- [x] Capa de validación de la bill request? Deberíamos comprobar que el user no es vacío, que el title tampoco,
      que las properties no sean nulas... Estaría bien tenerlo centralizado en una capa. Ahora mismo, solo se hace esa comprobación en el JSONParser, para el config.

- [x] Componente en la sombra para monitorizar los líderes? Podríamos guardar en un log el número de workers que tienen en cada instante. Útil para sacar gráficas del comportamiento del sistema. Para esto, habría que modificar el GenFilter para que se le pueda preguntar el número de trabajadores. Además, podría ser una medida de prevención de errores.

- [x] Una vez tenemos un monitor en la sombra que registre el número de trabajadores por filtro... Podríamos hacer que cuando falle un filtro y lo reinicie el genserver, que cuando se vuelva a iniciar le consulte a este componente cuántos trabajadores tenía, para no tener que empezar de 0. Esto sería una estrategia de respuesto para los GenFilter.

- [ ] Ahora mismo, si la llamada al process_filter del worker falla, el líder falla y lo reinicia el supervisor. Se puede hacer que el líder haga catch de la señal de exit de su proceso hijo, y en vez de morirse también, lo que haga sea lanzar un nuevo worker con el service handler??. Además de catchear esa situación, si el worker muere de una manera normal (Process.stop(:kill)), el líder al mandarle un mensaje petaría y lo reiniciaría el genserver. Estaría bien que se comprobase con isAlive y si está muerto, lanzar uno nuevo en el service handler??

- [ ] Paginar las peticiones a /bills? Pueden ser muchas para ser mandadas el front... Si da mucho trabajo, mejor pasar de esto. Permitir más parámetros? por ejemplo, filtrar las bills por rango de fecha...

# Notas

Permitir borrar el 0 en los input de cantidad...@frontend

Limitar el número de trabajadores a los threads del procesador? Si hay demasiados, puede
ir aún más lento...

- He implementado la estrategia de respuesto, con el FilterStash. Solo guardo el estado
  cuando el genserver llama a terminate, o cuando se hace el trap_exit de un worker. debería hacerlo más amenudo? Por ejemplo, cada X segundos? Por ejemplo,
  para no perder ninguna request, se debería mandar la copia del estado al Stash cada vez que nos llega alguna request?. Si un worker muere, el líder hace trap de su exit y también va a terminar, pero guardando el estado.

- El test de crash (en integration_test), debería hacerse con filter.stop()? o con que función?
