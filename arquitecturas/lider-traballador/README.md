# Arquitectura do Software

## Segunda práctica (curso 2021/2022)

### Duxir

> Dux (en latín, líder) + Elixir

A arquitectura escollida para esta práctica é a **arquitectura líder-traballador**.

A aplicación implementada é un sistema no que se permite rexistrar servizos ([Servizo1](lib/services/service_1.ex) e
[Servizo2](lib/services/service_2.ex) son exemplos de servizos, que implementan o _behaviour_ [StandardServer](lib/core/standard*server.ex)), e permite realizar peticións `get` aos servizos rexistrados.

Xa que a lóxica dos servizos é _dummy_, na petición `get` non se manda ningún argumento, o servizo dúrmese un tempo determinado, e
responde sempre a mesma mensaxe.

O sistema consiste nun líder que é un punto centralizado onde se reciben as peticións. Os clientes non teñen que saber
os _pid_ dos servizos para realizarlles unha petición, basta só con facer unha petición ao líder co nome co que se rexistraron os servizos.
Ata aquí, a funcionalidade deste compoñente é parecida á que tería un _reverse proxy_, ou a un directorio dunha arquitectura cliente-servidor.

Entón, o que fai que a arquitectura deste sistema sexa de líder-traballador, é que o líder xestiona un ou máis traballadores
para cada servizo rexistrado, redirixindo as peticións que recibe aos traballadores correspondentes e realizando un balanceo
das mesmas entre os traballadores libres, según unha estratexia de cola FIFO (First In First Out). Ademáis disto, o sistema
consulta periódicamente (configurado agora mesmo cada 5 segundos) o estado da carga de cada servizo,
é dicir, o porcentaxe dos traballadores totales que están ocupados en cada servizo.
Se un servizo está sobrecargado, o líder intenta regular a carga, creando máis traballadores para dito servizo.
En cambio, se un servizo está infrautilizado, o líder fai parar algúns traballadores para non malgastar recursos do sistema.

A política actual de actuar ou non sobre a carga nun sistema é a seguinte: intentaremos sempre que a carga do sistema
se encontre entre un 30% e un 80%, pero para non reaccionar de forma excesiva se a carga se pasa un pouco dos umbrales,
téñense dous valores de _trigger_ que funcionan como un marxe, sendo o de mínimo un 20% e o de máximo un 90%. Se a carga é inferior ao _trigger_ mínimo ou excede o _trigger_ máximo,
é cando se van realizar as accións de regulación dos traballadores para aumentar ou rebaixar a carga ao 30% ou 80%, respectivamente.
Estos valores son heurísticos e configurables no líder.

Con esta arquitectura, conseguimos que se un servizo empeza a recibir moitas peticións, o líder detectará esto
e actuará en consecuencia, aumentando o número de traballadores pouco a pouco, ata chegar a un punto de equilibrio
no que o sistema poida responder ben as peticións que lle chegaron, e as que lle poden chegar nun futuro. En cambio,
se o sistema ten moitos traballadores e nun momento deixa de recibir peticións, irá parando os traballadores
pouco a pouco, para aforrar recursos.

### Compilación e test

Primeiro, temos que descargar as dependencias do proxecto:

```console
mix deps.get
```

Despois, podemos compilar e lanzar os test do proxecto para ver que todo esté funcionando correctamente:

```console
mix compile
mix test --no-start
```

> Nota: o parámetro `--no-start` é necesario para que os tests non lancen a aplicación, xa que senón os tests
> unitarios e os de integración non funcionarían correctamente, porque que xa existiría un proceso líder creado polo supervisor da aplicación.

### Execución

Para poder probar como funciona a aplicación, e xa que non se dispón dun
proceso 'cliente' que faga as peticións, imos lanzar unha consola interactiva e facer as peticións manualmente.

Para lanzar a consola interactiva de elixir, executamos o seguinte comando:

```console
iex -S mix
```

Como recomendación, xa que se mandan bastantes mensaxes aos logs (para poder analizar ben o comportamento do sistema), é mellor copiar e pegar os comandos
na consola interactiva de elixir, en vez de escribilos á man.

Ahora, podemos realizar as peticións ao líder da seguinte maneira:

```elixir
iex> Core.Leader.get(:service_1)
{:ok, "Im Service1"}
```

Pero así lanzamos unha petición síncrona e non podemos ver que é o que ocorre
se lanzamos varias xa que se bloquea a entrada da consola, entón, para lanzar unha petición asíncrona:

```elixir
iex> Task.start(fn -> Core.Leader.get(:service_1) end)
```

Así, podemos ver nos logs que se mandou a petición, ou facer un await máis adiante da tarea que acabamos de lanzar.

Pero desta maneira é complicado probar que efectivamente o número de traballadores varía. Imos aumentar a carga do sistema realizando múltiples
peticións ao líder:

```elixir
iex> 1..60 |> Enum.each(fn _ -> Task.start(fn -> Core.Leader.get(:service_1) end) end)
```

Desta maneira lanzamos 60 peticións ao servizo, e podemos ver nos logs que cada 5s se vai realizar unha comprobación da carga por parte do líder, e como
a carga do `:service_1` é do 100% durante varios ciclos, vemos como nos logs tamén se ve a información de que se van creando novos traballadores. O `:service_1` ten configurado como mínimo 3 traballadores, polo que se non se incrementase o número deles, tardaríanse 20s en ter todas as respostas, pero podemos ver que como se van incrementando o número de traballadores, tardamos menos tempo en ter todas as respostas.

Unha vez finalizan as peticións, que no `:service_1` están configuradas para que cada unha tarde 1s, podemos ver que pouco a pouco se van parando os traballadores do `:service_1`, xa que a carga é do 0% en varios ciclos.

Para ver mellor este fenómeno, pódense facer as peticións ao `service_2`,
o cal tarda 30s en responder e non se produce tanto _flood_ na saída da consola, e podemos analizar mellor os logs.

```elixir
iex> 1..60 |> Enum.each(fn _ -> Task.start(fn -> Core.Leader.get(:service_2) end) end)
```

Neste caso, se solo se tivera un traballador, tardaríanse 30 minutos en ter todas as respostas, pero podemos ver que en realidade tárdase moito menos.

### Documentación

Para xerar a documentación do código en formato HTML, executar:

```console
mix docs
```

Agora, podemos ver a documentación abrindo no navegador o archivo `doc/index.html`.

Ademáis, proporciónanse os diagramas dos distintos niveis do modelo C4:

- [Diagrama de contexto](doc/duxir_context.pdf)
- [Diagrama de contedor](doc/duxir_container.pdf)
- [Diagrama de compoñente](doc/duxir_component.pdf)
- [Diagrama de código](doc/duxir_code.pdf)
