---
title: "Finding the right abstraction (when working with Strings)"
date: 2021-01-22T10:00:00+01:00
description: "As android developers, how do we load string resources from inside our business logic?"
type: "post"
categories: 
  - "Android"
tags:
  - "android"
  - "design-patterns"
---

Finding the right abstraction is hard.
In this blog post, I would like to share a technique that works well for us (my android teammates and me) when dealing with String resources on android.

## An abstraction layer for Strings?
Why do we even need an abstraction to simply work with Strings on Android? Probably you don't if your app is simple enough. But the more flexible your app needs to be regarding displaying text as content the sooner you realize that there are different kind of string resources and to deal with all of these kinds gracefully in your codebase you probably need another layer of abstraction. Let me explain what I mean with different kind of string resources:
- A simple String resource like `R.string.some_text`, displayed on screen via `resources.getString(R.string.some_text)`
- A formatted string which then is formatted at runtime. i.e. `context.getString(R.string.some_text, “arg1”, 123)` with 
  ```xml
  <string name=”some_formatted_text”>Some formatted Text with args %s %i</string>
  ```
- More advanced String resources like `Plurals` that are loaded i.e. with `resources.getQuantityString(R.plurals.number_of_items, 2)`: 
  ```xml
  <plurals name="number_of_items">
    <item quantity="one">%d item</item>
    <item quantity="other">%d items</item>
  </plurals>
  ```
- A simple text that is not loaded from an android resource xml file like `strings.xml` but is loaded already as string type and doesn't need any further translation (in contrast to `R.string.some_text`). For example, just a piece of text extracted from a json backend response.

Did you notice that to load these kinds of strings you have to invoke different methods with different parameters to actually get the string value?
If we want to deal with all of them gracefully then we should consider introducting a layer of abstraction for strings. To do that we have to consider the following points: 
1. We don't want to leak implementation details like which method to invoke to actually translate a resource into a string.
2. We need to make text a first class citizen (if suitable) of our business logic layer instead of our UI layer so that the view layer can easily "render" it.


Let's go step by step through this points by implementing a concrete example: Let's say that we want to load a string from a backend via http and if that fails we fallback to display a fallback string that is loaded from `strings.xml`. Something like this:

```kotlin
class MyViewModel(
  private val backend : Backend,
  private val resources : Resources // Android resources from context.getResources()
) : ViewModel() {
  val textToDisplay : MutableLiveData<String>  // for the sake of readability I use MutableLiveData

  fun loadText(){
    try {
      val text : String = backend.getText() 
      textToDisplay.value = text
    } catch (t : Throwable) {
      textToDisplay.value = resources.getString(R.string.fallback_text)
    }
  }
}
```

We are leaking implementation details into `MyViewModel` making our ViewModel overall harder to test. Actually, to write a test for `loadText()` we would need to either mock `Resources` or to introduce an interface like `StringRepository` (repository pattern alike) so that we can swap it with another implementation for testing:

```kotlin
interface StringRepository{
  fun getString(@StringRes id : Int) : String
}

class AndroidStringRepository(
  private val resources : Resources // Android resources from context.getResources()
) : StringRepository {
  override fun getString(@StringRes id : Int) : String = resources.getString(id)
}

class TestDoubleStringRepository{
    override fun getString(@StringRes id : Int) : String = "some string"
}
```

Our ViewModel then gets a `StringRepository` instead of resources directly and we are good to go, right?

```kotlin
class MyViewModel(
  private val backend : Backend,
  private val stringRepo : StringRepository // hiding implementation details behind an interface
) : ViewModel() {
  val textToDisplay : MutableLiveData<String>  

  fun loadText(){
    try {
      val text : String = backend.getText() 
      textToDisplay.value = text
    } catch (t : Throwable) {
      textToDisplay.value = stringRepo.getString(R.string.fallback_text)
    }
  }
}
```

We can unit test it like this:

```kotlin
@Test
fun when_backend_fails_fallback_string_is_displayed(){
  val stringRepo = TestDoubleStringRepository()
  val backend = TestDoubleBackend()
  backend.failWhenLoadingText = true // makes backend.getText() throw an exception
  val viewModel = MyViewModel(backend, stringRepo)
  viewModel.loadText()

  Assert.equals("some string", viewModel.textToDisplay.value)
}
```

With the introduction of `interface StringRepository` we have introduced a layer of abstraction and our problem is solved, right? Wrong. We have introduced an abstraction layer but this does not solve the real problem: 
-  `StringRepository` doesn't address the fact that different kind of text exists (see enumeration at the beginning of this article). This is shown by the fact that our ViewModel still has code that is hard to maintain because it explicitly knows how to transform different kinds of text to String. That is the real issue we want to find a good abstraction for. 
- Moreover, if you look at our test and the implementation of `TestDoubleStringRepository`, how meaningful is the test we wrote?  `TestDoubleStringRepository` is always returning the same string. We could totally mess up our ViewModels code by passing `R.string.foo` instead of `R.string.fallback_text` to `StringRepository.getString()` and our test would still pass. Sure we can improve `TestDoubleStringRepository` by not just always return the same string, something like that:
  ```kotlin
  class TestDoubleStringRepository{
      override fun getString(@StringRes id : Int) : String = when(id){
        R.string.fallback_test -> "some string"
        R.string.foo -> "foo"
        else -> UnsupportedStringResourceException()
      }
  }
  ```
  But how maintainable is that? Do you really want to do that for all your strings in your app (if you have hundreds of strings)? 

A better abstraction helps to solve both issues with one single abstraction.

## TextResource to the rescue
We call the abstraction that we came up with `TextResource` and is a domain specific model to represent text. Thus, it is a first class citizen of our business logic. It looks as following:

```kotlin
sealed class TextResource {
  companion object { // Just needed for static method factory so that we can keep concrete implementations file private
    fun fromText(text : String) : TextResource = SimpleTextResource(text)
    fun fromStringId(@StringRes id : Int) : TextResource = IdTextResource(id)
    fun fromPlural(@PluralRes id: Int, pluralValue : Int) : TextResource = PluralTextResource(id, pluralValue)
  }
}

private data class SimpleTextResource( // We could also use use inline classes in the future
  val text : String
) : TextResource()

private data class IdTextResource(
  @StringRes id : Int
) : TextResource()

private data class PluralTextResource(
    @PluralsRes val pluralId: Int,
    val quantity: Int
) : TextResource()

// you could add more kinds of text in the future
...
```

With `TextResource` our ViewModel looks as follows:

```kotlin
class MyViewModel(
  private val backend : Backend // Please note that we don't need to pass any Resources nor StringRepository.
) : ViewModel() {
  val textToDisplay : MutableLiveData<TextResource> // Not of type String anymore!  

  fun loadText(){
    try {
      val text : String = backend.getText() 
      textToDisplay.value = TextResource.fromText(text)
    } catch (t : Throwable) {
      textToDisplay.value = TextResource.fromStringId(R.string.fallback_text)
    }
  }
}
```

The major difference are the following: 
- `textToDisplay` changed from `LiveData<String>` to `LiveData<TextResource>` so ViewModel doesn't need to know how to translate to different kind of text to String anymore but how to translate it to TextResource but that is fine as TextResource is the abstraction that solves our problems as we will see.
- Take a look at ViewModel's constructor. We were able to remove the "wrong abstraction" `StringRepository` (nor do we need `Resources`). You might wonder how do we write test then? Just as simple as test against `TextResource` directly as this abstraction also abstracts away the android dependencies like `Resources` or `Context` (`R.string.fallback_text` is just an `Int`). So this is how our unit test look like:
  ```kotlin
  @Test
  fun when_backend_fails_fallback_string_is_displayed(){
    val backend = TestDoubleBackend()
    backend.failWhenLoadingText = true // makes backend.getText() throw an exception
    val viewModel = MyViewModel(backend)
    viewModel.loadText()

    val expectedText = TextResource.fromStringId(R.string.fallback_text)
    Assert.equals(expectedText, viewModel.textToDisplay.value)
    // data classes generate equals methods for us so we can compare them easily
  }
  ```

So far so good, but one piece is missing: how do we translate `TextResource` to `String` so that we can display it in a `TextView` for example? Well, that is a pure "android rendering" thing and we can create an extension function and keep it to our UI layer only.

```kotlin
// Note: you can get resources with context.getResources()
fun TextResource.asString(resources : Resources) : String = when (this) { 
  is SimpleTextResource -> this.text // smart cast
  is IdTextResource -> resources.getString(this.id) // smart cast
  is PluralTextResource -> resources.getQuantityString(this.pluralId, this.quantity) // smart cast
}
```

Moreover, since "translating" `TextResource` to String is happening in the UI (or View layer) of our app's architecture `TextResource` will be "retranslated" on config changes (i.e. changing system language on your smartphone) results in displaying the right localized string for any of your apps `R.string.*` resources.

Bonus: You can unit test `TextResource.asString()` easily (mocking Resources but you don't need to mock it for every single string resource in your app as all you really want to unit test is that the `when` state works properly, so here it is fine to always return the same string from mocked `resources.getString()`). 
Furthermore, `TextResource` is highly reusable throughout our codebas and follows the [open-closed principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle).
Thus, it is extendable for future use cases by only adding a few lines of code to our codebase (add a new data class that extends `TextResource` and add a new case in the `when` statement in `TextResource.asString()`).


**Update:** As [correctly pointed out](https://www.reddit.com/r/android_devs/comments/l3uc9r/finding_the_right_abstraction_when_working_with/) TextResource is not following the Open-Closed principle. 
Thanks for your feedback, I really appreciate it! 
We could make `TextResouce` follow the Open-Closed principle if `sealed class TextResouce` has a `abstract fun asString(r : Resources)` that all sub-classes implement. 
I personally think it is fine to sacrifice the Open-Closed principle in favor of keeping the data structs lean and work with a pure (extension) function `asString(r : Resources)` that lives outside of the inheritance hierarchy (as described in this blog post; Plus to me it still feels extensible enough although it is not as exensible as it can be with Open-Closed principle). Why? Well, I see it as problematic to add a function with a parameter `Resources` to the public API of TextResource because only a subset of all subclasses need that parameter (i.e. `SimpleTextResource` doesnt need this parameter add all). 
It just adds maintainance overhead and complexity (especially for testing) once it is part of the public API.