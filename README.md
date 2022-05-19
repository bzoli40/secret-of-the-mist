# KodersBase - Secret of the Mist

> Készítette: Szelinger Annamária - Fejes Gergő - Birkás Zoltán

## A projektről (tervek szerint)<img title="" src="Assets/Images/Identity/game_lgo.png" alt="loading-ag-231" width="348" data-align="center">

- Egy **story** típusú játék, ahol karakterünknek fel kell fedeznie egy rejtélyes hegyvidéket

- A történet során különböző képességekre tesz szert, hogy minél nagyobb esélyekkel túlvészelje a hegyvidék megpróbáltatásait

- Egyszemélyes játékélmény PC-n akár billentyűvel, akár kontrollerrel

- Komponensek:
  
  - Interakciók
  
  - Harcrendszer
  
  - AI
  
  - Irányítás
  
  - Inventory
  
  - Küldetések
  
  - Képességek
  
  - Stats (pl. életerő)
  
  - és más



## Használt programok

- Unity 2021.3.1f1

- Blender

- MarkText

- paint.net



## Fejlesztési mérföldkövek

```mermaid
graph LR
A[Kezdés] --> B(Input rendszer)
B --> C(Interakció-rendszer)
C --> D(Kamera-mozgás)
D --> E[Inventory]
E --> F[Küldetésrendszer]
F --> G[Interakciók 2.0]
C --> G
G --> H(Notifications)
G --> I[Eventek]
I --> J(Trackerek)
H --> J
F --> J
J --> K[AI]
K --> L[Bemutató!]
```

## DEMO

A bemutatóra elkészült a tervekből(%):

```mermaid
pie
    title Haladás
    "Igen" : 55
    "Nem" : 45
```

Hogyan lehet kipróbálni a **DEMO**-t?

\- A GitHub projekten belül a **Runnable** mappában található .exe fájl indításával

! Fontos ! Újraindításhoz vagy meg kell halni az egyik ellenségtől (közel kell hozzá állni) vagy az alkalmazást kell újra megnyitni
