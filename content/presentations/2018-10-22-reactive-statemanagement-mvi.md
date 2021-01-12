---
title: Reactive State Management with Model-View-Intent
date: 2017-10-05
location: Krakow, Mobiconf 2017
youtube:
speakerdeck: 4aa11922607e4f649351dd8c21de9f0d
---

Managing application state is not a simple topic especially on Android with a synchronous and asynchronous source of data, components having different lifecycles, back stack navigation and process death.

Model-View-Intent (MVI) is an architectural design pattern to separate the View from the Model. In this talk, we will discuss the idea behind MVI and how this pattern compares to other architectural patterns like Flux, Redux, Model-View-Presenter or Model-View-ViewModel. Furthermore, we will discuss what a Model actually is and how Model is related to State.

Once we have understood the role of Model and State we will focus on state management by building an unidirectional data flow.

Finally, we will connect the dots with RxJava to build apps with deterministic state management in a reactive way that makes maintaining and testing such apps easy.
