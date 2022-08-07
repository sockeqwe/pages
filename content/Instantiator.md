---
title: "Instantiate test data with Instantiator"
date: 2022-08-05T10:00:00+01:00
description: "Instantiate test data with Instantiator"
type: "post"
categories: 
  - "android"
  - "testing"
tags:
  - "kotlin"
  - "unit-tests"
---

I have noticed that most of the unit tests I write are testing how my code transforms data or business logic.
My class or business logic just needs data as input (thus I need some test data to write unit tests).
For example, most of my android apps load a list of items from the backend and then the android app is transforming that data into some state object or front-end specific domain objects.
I found myself spending too much time to creating data for my tests rather than writing tests. 

That is where `Instantiator` comes to the rescue. 
`Instantiator` is a little Kotlin library that I have written that uses reflection to fill `data class` with random test data (but it is not only limited to data classes).
And yes, you can find it on [Github](https://github.com/sockeqwe/Instantiator).

## Instantiatior
Instantiator is a little tool I have written that uses reflections to instantiate test data.
It is not bound to junit (although one could build a junit test runner on top of it).

Usage is quite simple: `instance()` and you get an instance. 
Example:

```kotlin
data class Person(
  val id : Int, 
  val name : String
)
```

```kotlin
val person : Person = instance()  // instance() is from Instantiator
val persons : List<Person> = instance()
```


Et voilà, you have a `Person` or a `List<Person>`.
`person.id` and `person.name` are filled with random data (a random number and a random string).

Let's take a look at some of my use cases. 
As said before, most of the time my business logic is just transforming data or that data is accessed through a `Repository` and then we validate some business logic accordingly. 

Let's take a look at how a typical android app of mine interact with a `Respository`:

```kotlin
class FakePersonRepository(
  var items : List<Person>
) : PersonRepository {

  override fun loadPersons() : List<Person> = items
}
```

```kotlin
@Test
fun `move from loading state to show list state`(){
  val persons : List<Person> = instance()
  val repository = FakePersonRepository(persons)

  val viewModel = PersonListViewModel(repository)
  assertTrue(viewModel.loading)
  assertNull(viewModel.items)
  viewModel.loadPersons() // loads data from repository
  assertEquals(persons, viewModel.items)
}
```

As you see in the example above, I don't really care about the actual item's content of the `List<Person>`. 
I actually want to unit test my `ViewModel's` business logic.
This is where `Instantiator` could be useful (of course one could argue that in the oversimplified example from above one could just return an `emptyList()` if we don't care about the items at all, but I hope you get the point that in a slightly more complex data set up emptyList() is probably not suitable).


Another example is to test pagination business logic: 

```kotlin
@Test
fun `when loading next page succeeds then loaded items are added`(){
  val startItems : List<Person> = instance()
  val repository = FakePersonRepository(startItems)

  val nextPageItems : List<Person> = instance()

  val viewModel = PersonListViewModel(repository)
  assertEquals(startItems, viewModel.items)

  repository.items = nextPageItems // set next items to be returned when loading next page
  viewModel.loadNextPage() 
  assertEquals( startItems + nextPageItems, viewModel.items)
}
```


Another use case where I found `Instantiator` useful is when a mobile app loads data from a backend that returns a response with a deeply nested hierarchy of data objects.
Instantiating such a deep hierarchy of data classes manually is a nightmare.
In the past, I tried to simplify that by storing the backend's json response in a text file and later in my unit tests I load the json from that file and parse it to get instances of my test data.
While that works it also has some disadvantages, for example whenever the response's data types change you need to adjust things in the stored json files too. 
You might have multiple such files containing json responses that you need to adjust. 
With `Instantiator` you don't have that problem because it uses reflection to instantiate objects.
Thus, there is no need to keep in sync your class definition and a file containing the interesting data to fill your class with.
Also `Instantiator` can fill any deeply nested data hierarchy without any problems. 
No additional manual work required.

I am also a fan of MVI or state machines. 
In fact, I use [FlowRedux](https://github.com/freeletics/FlowRedux) nowadays for my projects.
In MVI you send an `Intent` (or `Actions` as it is called in Redux world, thus also in `FlowRedux`) to trigger something.
But do you also test if sending other `Intents` (or `Actions`) are doing  nothing while your app is in a certain state?

This is something where `Instantiator` can help as it offers also a way to instantiate an instance of each class in a `sealed interface/class` hierarchy.
For that we have to use `instantiateSealedSubclasses()` instead of `instance()`:

```kotlin
sealed interface Action // could also be called Intent instead of Action

object LoadItems : Action // this action triggers loading
data class ItemClicked(val itemId : Int) : Action
data class ApplyFilter(val filter : Filter) : Action

enum class Filter { A, B }
```


```kotlin
@Test
fun `when in error state only LoadItems action causes state transition`(){
  val stateMachine = MyStateMachine(initialState = ErrorState)
  assertEquals(ErrorState, stateMachine.state)

  val allActions : List<Action> = instantiateSealedSubclasses() // part of Instantiator
  val allActionsExceptLoadItem = allActions.filter { it is LoadItems } 

  println(allActionsExceptLoadItem) // [ ItemClicked(123), ApplyFilter(B) ]

  for (action in allActionsExceptLoadItem) {
    // validate that state is not changed because of ItemClicked or ApplyFilter action
    stateMachine.dispatch(action)
    assertEquals(ErrorState, stateMachine.state) 
  }

  stateMachine.dispatch(LoadItems)
  assertEquals(Loading, stateMachine.state) // this is the only expected state transition
}
```

As you see, instead of creating a list with all `Actions` manually, you can use Instantiator's `instantiateSealedSubclasses()` to create an instance of each subclass of `Action`. 
For me it is quite handy when working in a code base with a ton of `Actions` and I would like to validate
no side effects are happening because of some unexpected Action being dispatched.

Moreover, if I add more Actions later, I don't have to change anything in the unit test shown above. 
`instantiateSealedSubclasses()` creates a new instance of this new Action type too.

Another use case I have from time to time is I need some data to for a screen that is under development but the backend is not ready yet to provide that data. 
Instantiator helps me here as well. 


## Alternatives

I know that similar libraries or tools like `Instantiator` already exist. 
Some of them come from the Java land and have not so great interop with some kotlin features such as `object` or `sealed interfaces`.
You may wonder if my problem is not what property-based testing is solving, for example [Kotest](https://kotest.io/docs/proptest/property-based-testing.html) has support for it.
Yes, it goes in that direction but I don't want to do fully property-based testing most of the time.
Then there are other libraries and frameworks tight to junit such as [junit's parameterized tests](https://junit.org/junit5/docs/current/user-guide/#writing-tests-parameterized-tests). 
Most of them these framework still require you to provide test data:

```java
@ParameterizedTest
@ValueSource(ints = { 1, 2, 3 })
void testWithValueSource(int argument) {
    assertTrue(argument > 0 && argument < 4);
}
```

That is what I would like to avoid: the need for setting up test data.
The closest to what I would like to have for my unit test is Google's [TestParameterInjector
](https://github.com/google/TestParameterInjector) but it doesn't support some kotlin features.

I don't want to convince you that `Instantiator` is better or sell you my tool somehow. 
Actually, how it started was that I wanted to learn more about Kotlin's reflections capabilities and `Instantiator` was to some degree a side effect of these learnings.


Nevertheless, if you want to check out `Instantiator`, it is open source on Github:
https://github.com/sockeqwe/Instantiator
