# Black Pearl Adventures

Un juego de apuestas en Flutter inspirado en Dino Mystake, pero con un tema de barco navegando por el océano.

## Descripción

Black Pearl Adventures es un juego de apuestas donde el jugador debe realizar una apuesta y hacer "cash out" antes de que ocurra una explosión submarina que destruya el barco. Cuanto más tiempo espere el jugador, mayor será el multiplicador y potencialmente la ganancia.

## Características

- **Apuestas en USD**: Ingresa una cantidad en dólares para comenzar.
- **Multiplicador progresivo**: El multiplicador aumenta con el tiempo.
- **Animaciones**: GIFs de barco navegando y explosión submarina.
- **Sistema de cash out**: Retira tus ganancias antes de que explote el barco.
- **Historial de apuestas**: Consulta tus apuestas anteriores.
- **Configuración**: Personaliza el sonido y la vibración.

## Tecnologías utilizadas

- Flutter
- Provider para gestión de estado
- Shared Preferences para almacenamiento local
- Intl para formato de moneda
- AudioPlayers para efectos de sonido

## Capturas de pantalla

[Espacio para capturas de pantalla cuando estén disponibles]

## Instalación

1. Asegúrate de tener Flutter instalado en tu sistema.
2. Clona este repositorio.
3. Ejecuta `flutter pub get` para instalar las dependencias.
4. Ejecuta `flutter run` para iniciar la aplicación.

```bash
git clone https://github.com/tu-usuario/black-pearl-adventures.git
cd black-pearl-adventures
flutter pub get
flutter run
```

## Cómo jugar

1. **Ingresa tu apuesta**: Escribe la cantidad en USD que quieres apostar.
2. **Observa el multiplicador**: El multiplicador aumenta con el tiempo.
3. **Haz Cashout a tiempo**: Presiona "CASH OUT" antes de que explote el barco para ganar tu apuesta multiplicada.
4. **Si el barco explota**: Pierdes tu apuesta. El juego se reiniciará automáticamente después de 3 segundos.

## Créditos

Desarrollado por Black Pearl Studios.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - vea el archivo LICENSE para detalles.
