---
title: Refactoring Plaid App – A reactive MVP approach
date: 2016-06-16
location: Berlin, Droidcon Berlin 2016
youtube: wWyPc_HN77c
speakerdeck: d5ffc18dbfbe4c00bdd6674bcbcae540
---

Nick Butcher, developer advocate at Google, has open sourced an android app called Plaid with an outstanding UI, meaningful animations and a lot of others material design goodies.

However, from the software architecture’s point of view, the architecture of this app more “traditional” so that both, beginners and expert developers, can understand the source code easily. Unfortunately, that means that there is a lack of separation of concerns that modern software architectures offers. This talk discusses how to improve the architecture of this app by applying Model-View-Presenter (MVP) to create modular and decoupled components that are easy to test. Furthermore, this talk shows how to improve the code quality by using well known libraries like RxJava (foreknowledge is not a strong requirement), dependency injection and how to test such an App by doing Test-Driven-Development (TDD) from the very beginning.

The aim of this talk is to showcase the importance of a well thought out software architecture and how to implement such an MVP based architecture and last but not least to clarify what the word “reactive” actually means in this context.