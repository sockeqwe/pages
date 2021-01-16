---
title: Annotation Processing 101
date: 2015-06-05
location: Berlin, Droidcon 2015
youtube: 43FFfTyDYEg
speakerdeck: 4ffe12e13cff4787b5dce56620d75c4d
---

Writing Java application can be annoying because the Java programming language requires to write boilerplate code. Writing Android apps makes no difference. Moreover, on Android you have to write a lot of code for doing simple things like setting up a Fragment with arguments, implement the Parcelable interface, define ViewHolder classes for RecyclerViews and so on.

Fortunately, the writing of boilerplate code can be reduced by using Annotation processing, a feature of the Java compiler that allows to setup hooks to generate code based on annotations.

The aim of the talk is to understand the annotation processing fundamentals and to be able to write an annotation processor. Furthermore, existing annotation processors for Android will be showcased.