---
title: "Reactive Apps with Model-View-Intent - Part 8: Navigation"
date: 2018-05-06T10:00:00+01:00
description: "Model-View-Intent MVI on Android by using Mosby 3. Navigation in MVI."
type: "post"
url: "android/mosby3-mvi-8"
categories: 
  - "Android"
tags:
  - "android"
  - "software-architecture"
  - "design-patterns"
series: ["Reactive Apps with Model-View-Intent"]
---
In my [previous blog post]({{< ref android_coordinators.md >}}) we discussed how the Coordinator pattern can be applied on Android. This time I would like to show how this can be used in Model-View-Intent.

If you don't know yet what the Coordinator pattern is I highly recommend to go back and read the [introdcution]({{< ref android_coordinators.md >}}). 

Applying this pattern in MVI is not much different from MVVM or MVP: 
we pass a lambda as navigation callback into our MviBasePresenter. 
The interesting part is how do we trigger this callbacks in a state driven architecture?
Let's take a look at a concrete example:

```java
class FooPresenter(
  private var navigationCallback: ( () -> Unit )?
) : MviBasePresenter<FooView> {  
  lateinit var disposable : Disposable
  override fun bindIntents(){
    val intent1 = ...
    val intent2 = ...
    val intents = Observable.merge(intent1, intent2)

    val state = intents.switchMap { ... }

    // Here stars the interesting part
    val sharedState = state.share()
    disposable = sharedState.filter{ state ->
      state is State.Foo
    }.subscribe { navigationCallback!!() }
  
    subscribeViewState(sharedState, FooView::render)
  }

  override fun unbindIntents(){
    disposable.dispose() // Navigation disposable
    navigationCallback = null // Avoid memory leaks
  }
}
```

The idea is to reuse the same `state` observable that we usually use to render the state in our View by using RxJava's `share()` operator.
This plus the combination of `.filter()` allows us to listen for a certain state and then trigger the navigation once we reached that state. 
The Coordinator Pattern then just works as described in my previous blog post.

{{< series >}}