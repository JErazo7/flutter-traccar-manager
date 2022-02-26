# Mika GPS padre!
Aplicación móvil  multiplataforma que permite a los padres de familia visualizar el recorrido en tiempo real  de los conductores de buses escolares que utilizan la aplicación Mika Gps conductor.

## Autenticación en el servidor de Traccar
Para autenticar una sesión en Traccar, la aplicación debe obtener un cookie de sesión. Para obtener dicho cookie, se utiliza el paquete [dio](https://pub.dev/packages/dio) para hacer una petición Get al punto final `/api/session` enviando como parámetro un Token de autenticación generado previamente en Traccar para el usuario correspondiente. 

Esta operación se realiza en el método  `Future<void> _getCookie({String protocol = "http"})`  que se encuentra en el archivo ***client.dart***
en la ruta `lib/src/traccar/client.dart`. 

**Nota:** La cookie de sesión se debe pasar en el encabezado de todas las peticiones que se realizan al servidor.


 ## Obtención de la ubicación en tiempo real
Para obtener la ubicación emitida por Mika Gps Conductor, la aplicación escucha a través del paquete [web_socket_channel](https://pub.dev/packages/web_socket_channel) las ubicaciones emitidas por el servidor de Traccar a través del método `Future<Stream<dynamic>> _positionsStream(
{String serverUrl, String protocol = "http"})` que se encuentra en el archivo ***client.dart***  mencionado anteriormente.

Para comunicarse con Traccar, se debe establecer la conexión con el punto final del WebSocket `/api/socket` de su servidor, el cual emite actualizaciones y eventos de ubicación en vivo. La cookie de sesión es la única opción de autorización para la conexión WebSocket.

Cada mensaje en la comunicación WebSocket usa el mismo formato JSON:
 
    { 
       "devices": [...],
       "positions: [...], 
       "events": [...]  
    }
Cada conjunto contiene modelos estándar correspondientes:

-   [Devices](https://www.traccar.org/api-reference/#/definitions/Device)
-   [Position](https://www.traccar.org/api-reference/#/definitions/Position)
-   [Event](https://www.traccar.org/api-reference/#/definitions/Event)

## Implementación del mapa y marcador de ubicación
Para implementar el mapa y sus marcadores se utiliza una biblioteca muy interesante llamada [FluxMap](https://pub.dev/packages/fluxmap).

Flux Map es un mapa  que permite  manejar actualizaciones de ubicación en tiempo real para múltiples dispositivos. El mapa toma una secuencia de objetos de [dispositivo](https://github.com/synw/device) para la entrada y administra su estado en el mapa. Esta biblioteca permite manejar la lógica del mapa y su actualización constante. 

El resto de bibliotecas que se utilizan son las siguientes:

 - [map_controller](https://pub.dev/packages/map_controller)
 - [geopoint_location](geopoint_location)
 - [geopoint](https://pub.dev/packages/geopoint)
 - [latlong](https://pub.dev/packages/latlong)

Toda la logica de implementacion del mapa y sus marcadores se encuentra en el archivo `controller.dart` en la ruta `lib/src/controller.dart`.

**Nota:** Como guía para extender esta aplicación en un desarrollo futuro, consultar el siguiente repositorio, que abarcan un sinnúmero de funcionalidades para manejar mapas en ***Flutter*** :

 - [livemap](https://github.com/synw/livemap)

aes:ecb:md5

out:
FilTZHBt9Yfy1N+qGahIGDsQiULUpmHlzJljlc/Pt61hBifGM+c/WuRHcPxX3Bxzqdl11lMWOZnN/XNUc5IZJg


