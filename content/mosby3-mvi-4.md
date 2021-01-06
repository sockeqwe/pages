---
title: "Reactive Apps with Model-View-Intent - Part4: Independent UI Components"
date: 2017-02-25T10:00:00+01:00
description: "Model-View-Intent MVI on Android by using Mosby 3. Focusing on Independent UI Components and state managment in MVI"
type: "post"
url: "android/mosby3-mvi-4"
categories: 
  - "Android"
tags:
  - "android"
  - "software-architecture"
  - "design-patterns"
series: ["Reactive Apps with Model-View-Intent"]
---

In this blog post we will discuss how to build
independent UI components and clarify why Parent-Child relations are a code smell in my opinion. Furthermore, we will discuss why I think such relations are needless.

One question that arises from time to time with architectural design patterns such as Model-View-Intent, Model-View-Presenter or
Model-View-ViewModel is how do Presenters (or ViewModels) communicate with
each other? Or even more specific: How does a "Child-Presenter" communicate with its "Parent-Presenter"?

![wtf](/images/mvi-mosby3/wtf.jpg)

From my point of view such Parent-Child relations are a code smell, because they introduce a
direct coupling between both Parent and Child, which leads to code that is hard to read, hard to maintain, where changing
requirement affects a lot of components (hence it's a virtually impossible task in large systems)
and last but not least introduces shared state that is hard to predict and even harder to reproduce
and debug.

So far so good, but somehow the information must flow from Presenter A to Presenter B: How does a Presenter communicate with another Presenter? **They don't!**
What would a Presenter have to tell another Presenter? _Event X_ has happened? Presenters don't
have to talk to each other, they just observe the same Model (or the same part of the business
  logic to be precise). That's how they get notified about changes: from the underlying layer.

![Presenter-Businesslogic](/images/mvi-mosby3/mvp-business-logic.png)

Whenever an _Event X_ happens (i.e. a user clicked on a button in View 1), the Presenter lets that information sink
down to the business logic. Since the other Presenters are observing the same
business logic, they get notified by the business logic that something has changed (model has been updated).

![Presenter-Businesslogic](/images/mvi-mosby3/mvp-business-logic2.png)

We have already discussed the importance of this principle (unidirectional data flow) in the [first part]({{< ref mosby3-mvi-1.md >}}).

Let's implement this for a real world example: In our shopping app we can put items into the
shopping basket. Additionally, there is a screen where we can see the content of our basket and we
can select and remove multiple items at once.

{{< youtube ZvnceMj8NoY >}}

Wouldn't it be cool if we could split that big screen into multiple smaller, independent and reusable UI components.
Let's say a Toolbar, that displays the number of items that are selected, and a
RecyclerView that actually displays the list of items in the shopping basket.

```xml
<LinearLayout>
  <com.hannesdorfmann.SelectedCountToolbar
      android:id="@+id/selectedCountToolbar"
      android:layout_width="match_parent"
      android:layout_height="wrap_content"
      />

  <com.hannesdorfmann.ShoppingBasketRecyclerView
      android:id="@+id/shoppingBasketRecyclerView"
      android:layout_width="match_parent"
      android:layout_height="0dp"
      android:layout_weight="1"
      />
</LinearLayout>
```

But how do these components communicate with each other? Obviously each component has its own Presenter: **SelectedCountPresenter** and **ShoppingBasketPresenter**. Is that a Parent-Child relation? No, both are just observing the same Model (updated from the same business logic):

![ShoppingCart-Businesslogic](/images/mvi-mosby3/shoppingcart-businesslogic.png)

```java
public class SelectedCountPresenter
    extends MviBasePresenter<SelectedCountView, Integer> {

  private ShoppingCart shoppingCart;

  public SelectedCountPresenter(ShoppingCart shoppingCart) {
    this.shoppingCart = shoppingCart;
  }

  @Override protected void bindIntents() {
    subscribeViewState(shoppingCart.getSelectedItemsObservable(), SelectedCountView::render);
  }
}


class SelectedCountToolbar extends Toolbar implements SelectedCountView {

  ...

  @Override public void render(int selectedCount) {
   if (selectedCount == 0) {
     setVisibility(View.VISIBLE);
   } else {
       setVisibility(View.INVISIBLE);
   }
 }
}
```

The code for **ShoppingBasketRecyclerView** looks pretty much the same and therefore we skip that here. However, if we take a closer look at **SelectedCountPresenter** we notice that this Presenter is coupled to **ShoppingCart**. We would like to use the UI component also on other screens in our app. To make that component reusable we have to remove this dependency, which is actually an easy refactoring: The presenter gets an **Observable&lt;Integer&gt;** as Model through the constructor instead of ShoppingCart:

```java
public class SelectedCountPresenter
    extends MviBasePresenter<SelectedCountView, Integer> {

  private Observable<Integer> selectedCountObservable;

  public SelectedCountPresenter(Observable<Integer> selectedCountObservable) {
    this.selectedCountObservable = selectedCountObservable;
  }

  @Override protected void bindIntents() {
    subscribeViewState(selectedCountObservable, SelectedCountToolbarView::render);
  }
}
```

Et voilà, we are able to use the SelectedCountToolbar component whenever we have to display the number
of items currently selected. That can be the number of items in ShoppingCart but this UI component could also be used in an entirely different context and screen in your app. Moreover, this UI component could be put into a standalone library and used in another app like a photos app to display the number of selected photos.

```java
Observable<Integer> selectedCount = photoManager.getPhotos()
    .map(photos -> {
       int selected = 0;
       for (Photo item : photos) {
         if (item.isSelected()) selected++;
       }
       return selected;
    });

return new SelectedCountToolbarPresnter(selectedCount);
```

## Conclusion
The aim of this blog post is to demonstrate that a Parent-Child relation is usually not needed at all
and can be avoided by simply observing the same part of your business logic. No EventBus, no findViewById() from a parent Activity / Fragment, no presenter.getParentPresenter() or other workarounds are required. Just the observer pattern. With the help of RxJava, which basically implements the observer pattern, we are able to build such reactive UI components easily.

### Additional thoughts
In contrast to MVP or MVVM in MVI we are forced (in a positive way) that business
logic drives the state of a certain component. Hence developers with more experience in MVI could
come to the following conclusion:

> What if such a view state is the model of another component?
> What if a view state change of one component is an intent for another component?

Example:

```java
Observable<Integer> selectedItemCountObservable =
        shoppingBasketPresenter
           .getViewStateObservable()
           .map(items -> {
              int selected = 0;
              for (ShoppingCartItem item : items) {
                if (item.isSelected()) selected++;
              }
              return selected;
            });

Observable<Boolean> doSomethingBecauseOtherComponentReadyIntent =
        shoppingBasketPresenter
          .getViewStateObservable()
          .filter(state -> state.isShowingData())
          .map(state -> true);

return new SelectedCountToolbarPresenter(
              selectedItemCountObservable,
              doSomethingBecauseOtherComponentReadyIntent);
```

At first glance this seems like a valid approach, but isn't it a variant of a Parent-Child
relation? Sure, it's not a traditional hierarchical Parent-Child relation, it's more like an onion
(the inner one offers a state to the outer one) which seems to be better, but still, a tightly
coupled relation, isn't it? I haven't made up my mind but I think avoiding this onion-like
relation is better for now. If you have a different opinion please leave a comment below. I would
love to hear your thoughts.

{{< series >}}