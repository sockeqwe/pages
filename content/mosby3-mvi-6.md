---
title: "Reactive Apps with Model-View-Intent - Part 6: Restoring State"
date: 2017-05-02T10:00:00+01:00
description: "Model-View-Intent MVI on Android by using Mosby 3. Restoring State in MVI is easy. SaveStateDelegate. MVI."
type: "post"
url: "android/mosby3-mvi-6"
categories: 
  - "Android"
tags:
  - "android"
  - "software-architecture"
  - "design-patterns"
series: ["Reactive Apps with Model-View-Intent"]
---
In the previous blog posts we have discussed Model-View-Intent (MVI) and the importance of unidirectional data flow. That simplifies state restoration a lot. How and why? We will discuss that in this blog post.

There are two scenarios we will focus on in this blog post: Restoring state "in memory"
(for example during screen orientation change) and restoring a "persistent state"
(for example from Bundle previously saved in `Activity.onSaveInstanceState()`).


## In Memory
That is the simple case. We just have to keep our RxJava stream that emits new state over time out of
android components lifecylce (i.e. Activity, Fragment or even ViewGroups). For example Mosby's
`MviBasePresenter` establishes such a RxJava stream internally by using
`PublishSubject` for View intents and `BehaviorSubject` to render the state on the view.
I have already described these implementation details at the end of [Part 2]({{< ref mosby3-mvi-2.md >}}).
The main idea is that MviBasePresenter is such a component that lives outside View's lifecylce so that a view can be attached and detached to such a Presenter.
In Mosby the Presenter gets "destroyed" (garbage collected) when the view is destroyed permanently.
Again, this is just an implementation detail of Mosby.
Your MVI implementation might be entirely different.
The important bit is that such a component like a Presenter lives outside of View's lifecycle because
then it's easy to deal with View attached and detached events:
whenever the View gets (re)attached to the Presenter we simply call `view.render(previousState)`
 (therefore Mosby uses BehaviorSubject internally).
This is just one solution of how to deal with screen orientation changes. It also works with back stack navigation,
i.e. Fragments on the back stack: if we come back from back stack we simply call view.render(previousState) again and the view is displaying the correct state.
Actually, state can still be updated even if no view is attached because Presenter lives outside of that lifecycle and keeps RxJava state stream alive. Imagine receiving a push notification that changes data (part of state) while no view is attached. Again, whenever view gets reattached the latest state (containing updated data from push notification) is hand over to the view to render.

## Persistent State
That scenario is also much simpler with a unidirectional data flow pattern like MVI.
Let's say we want that state of our View (i.e. Activity) not only survives in memory, but also through process death.
Typically in Android one would use `Activity.onSaveInstanceState(Bundle)` to save that state.
In contrast to MVP or MVVM where you not necessarily have a Model that represents state
(see [Part1]({{< ref mosby3-mvi-1.md >}}) in MVI your View has a `render(state)` method which makes it easy to keep track of the latest state.
So the obvious solution is to make state Parcelable and store it into the bundle and then restore it afterwards like this:


```java
class MyActivity extends Activity implements MyView {

  private final static KEY_STATE = "MyStateKey";
  private MyViewState lastState;

  @Override
  public void render(MyState state) {
    lastState = state;
    ... // update UI widgets
  }

  @Override
  public void onSaveInstanceState(Bundle out){
    out.putParcelable(KEY_STATE, lastState);
  }

  @Override
  public void onCreate(Bundle saved){
    super.onCreate(saved);
    MyViewState initialState = null;
    if (saved != null){
      initialState = saved.getParcelable(KEY_STATE);
    }

    presenter = new MyPresenter( new MyStateReducer(initialState) ); // With dagger: new MyDaggerModule(initialState)
  }
  ...
```

I think you get the point. Please note that in onCreate() we are not calling
view.render(initialState) directly but rather we let the initial state sink down to where state management takes place: the state reducer ([see Part 3]({{< ref mosby3-mvi-3.md >}}) where we use it with `.scan(initialState, reducerFunction)`.

## Conclusion
With a unidirectional data flow and a Model that represents State a lot of state related things are much simpler to implement compared to other patterns.
However, usually I don't persist state into a bundle in my apps for two reasons:
First, Bundle has a size limit, so you can't put arbitrary large state into a bundle (alternatively you could save state into a file or an object store like Realm).
Second, we only have discussed how to serialize and deserialize state but that is not necessarily  the same as restoring state.

For Example: Let's assume we have a LCE (Loading-Content-Error) View that displays a loading indicator while loading data and a list of items once the data (items) is loaded.
So the state would be like `MyViewState.LOADING`. Let's assume that loading takes some time and
that the Activity process gets killed while loading (i.e. because another app has come into foreground like phone app because of an incoming call). If we just serialize  MyViewState.LOADING and deserialize it after Activity has been
recreated as described above, our state reducer would just call view.render(MyViewState.LOADING) which is correct so far **BUT** we would actually never invoke loading data again
(i.e. start http request) just by using the deserialized state blindly.

As you can see, serializing and deserializing state is not the same as state restoration which
may requires some additional steps that increases complexity (still simpler to implement with MVI than with
any other architectural pattern I have used so far).
Also deserialized state containing some data might be outdated when View gets recreated so that you
might have to refresh (load data) anyway. In most of the apps I have worked on I found it
much simpler and more user friendly to keep state in memory only and after process death start with
a empty initial state as if the app would start the first time.
Ideally an app has a cache and offline support so that loading data after process death is fast.

That ultimately leads to a common belief I have had some hard debates about with other android developers: If I use a cache or store, I already have such a component that lives outside of the android component
lifecycle and I don't have to do all that retaining components stuff and MVI nonsense at all, right?
Most of the time those android devs are referring to Mike Nakhimovich post [Presenters are not for persisting](https://hackernoon.com/presenters-are-not-for-persisting-f537a2cc7962)
where he introduced [NyTimes Store](https://github.com/NYTimes/Store), a data loading and caching library. Unfortunatley, those developers don't understand that **loading data and caching is NOT state management**.
For example what if I have to load data from 2 stores or caches?

Finally, does caching libraries like NyTimes Store help us to deal with process death?
Obviously not because process death can happen at any time. Deal with it.
The only thing we can do is to beg android operating system not to kill our apps process because we still have some work to do by using android
services (which is also such a component that lives outside of other android components lifecycles)
or don't we need android services anymore these days with RxJava, do we?
We will talk about android services, RxJava and MVI in the next part. Stay tuned.

Spoiler alert: I think we do need services.

{{< series >}}