---
title: "Perfectionism vs. Excellence"
date: 2021-01-29T10:00:00+01:00
description: "Perfectionism is not the same thing as striving for excellence. When reviewing PRs do we aim for perfectionism or for excellence? Code Reviews."
type: "post"
categories: 
  - "Soft-Skills"
tags:
  - "code-review"
---

Perfectionism is not the same thing as striving for excellence. 
How does one differentiate from the other and why does it matter? 
How does it related to software engineering? 
These are the questions that I want to answer by looking at a very concrete example from the world of software engineering: Code Reviews.

## What is perfectionism?

Here is the thing: defining what is perfect is subjective, not objective.
Just because something appears perfect to me it doesn't mean that it matches the definition of perfect of another person as well.

Moreover, Perfectionism drives people to be concerned with achieving unattainable ideals or unrealistic goals, often leading to many forms of adjustment problems such as depression, low self-esteem, suicidal thoughts and tendencies and a host of other psychological, physical, relationship, and achievement problems in children, adolescents, and adults.[^1]

Perfectionism is not the key to success. In fact, research[^2] shows that perfectionism hampers achievement and that Perfectionism is correlated with depression, anxiety, addiction, and life paralysis, or missed opportunities.

Brené Brown, a research professor at the University of Houston and  author of five #1 New York Times bestsellers, adds interesting aspects (based on her research) to the definition of perfectionism[^3]:

 > Perfectionism is not self-improvement. Perfectionism is, at its core, about trying to earn approval. Most perfectionists grew up being praised for achievement and performance (grades, manners, rule following, people pleasing, appearance, sports). Somewhere along the way, they adopted this dangerous and debilitating belief system: I am what I accomplish and how well I accomplish it. Please. Perform. Perfect. Prove.
 > Perfectionism is a self-destructive and addictive belief system that fuels this primary thought: If I look perfect and do everything perfectly, I can avoid or minimize the painful feelings of blame, judgment, and shame.
 >
 > Perfectionism is more about perception than internal motivation, and there is no way to control perception, no matter how much time and energy we spend trying.
 > 
 > Perfectionism is other-focused: What will people think? Perfectionism is a hustle.

I found it interesting to see perfectionism being linked to perception. 
Do I want to be perceived perfect? Why? By whom?
Keep that in mind, we will get back to this question later in this blog post once we eventually talk about Code Reviews.

## What is excellent?

According to Wikipedia[^4] excellence is defined as follows: 

> Excellence is a talent or quality which is unusually good and so surpasses ordinary standards. It is also used as a standard of performance as measured e.g. through economic indicators.

In contrast to perfectionism, excellence is measured by standards. 
Thus, excellence is objective. You know which standards you need to meet to achieve excellence and it is measurable.

## Let's talk about Code Reviews
Let's see how this translates to real world examples for software engineers: Code Reviews (like reviewing PRs on Github). 
It's out of scope to talk about the benefits of code reviews. 
I assume you have already been part of both sides of the game: asked for code review and reviewed someone else's code.
For the rest of this article I would like to step into the shoes of the later: being a code reviewer.

Let's say we are working for an e-commerce company and a coworker of ours is working on adding a little countdown widget to our app that displays how many days, hours, minutes and seconds are remaining until a sale ends.
Something that at the end looks like this:

![Code Review Comment1](/images/perfectionism-excellence/countdown-widget.png)


The solution our coworker came up with and ask us for code review looks as follows: 

```kotlin
fun secondsRemaining(now : Date, endDate : Date){
  val nowMilliseconds = now.getTime()
  val endMilliseconds = end.getTime()

  val nowSeconds = nowMilliseconds / 1000
  val endSeconds = endSeconds / 1000

  return endSeconds - nowSeconds
}
```

and the it also contains a unit test:

```kotlin
@Test
fun remaining_time_between_two_consecutive_days_is_86400_seconds(){
  val oneDayInSeconds = 1*24*60*60
  val format = SimpleDateFormat("yyyy-MM-dd")
	val d1 = format.parse("2012-01-15")
  val d2 = format.parse("2012-01-16")
    
	val remainingSeconds = secondsRemaining(d1, d2)

  Assert.assertEquals(oneDayInSeconds, remainingSeconds)
}
```

Now, lets' see how this relates to our Perfectionism vs. Excellent discussion.

If we are a perfectionist looking for perfection we could for example request the following change before we approve this PR (as it matches our definition of perfection only after our desired changes are applied):

![Code Review Comment1](/images/perfectionism-excellence/review_unit_test.png)

What did we do here? 
We said that the solution of the coworker to compute two consecutive dates is not perfect but Calendar is perfect for us. Remember, perfect is subjective. 
Going back to Brené Brown's definition of Perfectionism:
 > Perfectionism is more about perception than internal motivation, and there is no way to control perception, no matter how much time and energy we spend trying.
 > 
 > Perfectionism is other-focused: What will people think?

Aren't we by requesting this change (subconsciously) just trying to be perceived as perfect (or smarter or more knowledgeable) by whoever reads our comment, like the author of the code who requested our code review?


#### Healthy striving for excellence
Healthy striving is self-focused: "How can I improve?". 
If we translate this to code review then the question is: How can we improve the solution to make it excellent?

Coming back to the code review example from above, the question we should ask ourselves is does using `Calendar` APIs make this piece of code more excellent? I don't think so. 

Excellence is objective. Excellence has defined standards. 

For example: when reviewing code that implements a certain algorithm we can measure runtime performance and know what excellence means in that context.
Similarly, building a backend system with multiple microservices we can measure scalability, resilience, request throughput and so on. 
Another example is proper domain model which you can measure indirectly (maybe not by such a meaningful number like throughput of requests on the backend) by taking into account i.e. coupling and dependencies we have to other components or the complexity of a module. 
Even on a smaller scope: just using enums over string literals to model a finite set of options is excellent. 
The standard that defines excellence, in that case, is that you have fewer errors by using enums as compilers can check for exhaustive use in `when` expressions in Kotlin (`switch` in Java).
For sure there are other things where the definition of excellence is not that clear. For example naming (of types or variables). 
But even in that case, there is a chance that there are common best practices or naming conventions that serve as a standard (and statical analysis tools can do that code review for you). 
More broadly speaking: Excellence can be measured with fewer bugs.

With that said, let's finish code review example from above.
So instead of reviewing code by focusing on perfectionism ("you must use `Calendar`!") we should focus on excellence.
One issue that we as code reviewer could point out is that just using `Date` is not the best choice if we need to work with different timezones. 
Focusing on that aspect is focusing on striving for excellence (less chance to have timezone related bugs or misbehaviour).
Or focusing on the fact that there is no check in `secondsRemaining(now : Date, endDate : Date)` that `endDate` is actually after `now`.
Another area that could be improved to be more excellent is to point out that instead of returning just seconds as type `Long` from `fun secondsRemaining(now : Date, endDate : Date) : Long` we should introduce a domain model `RemainingTime` because most likely we need to do another computation (worst case in the UI layer where it is harder to write unit tests for) to translate remaining seconds into remaining days, hours, minutes and seconds as these are what the UI widget needs at the end.

```kotlin
data calss RemainingTime( 
  val days : Int,
  val hours : Int, 
  val minutes : Int, 
  val seconds : Int
)

// secondsRemaining() renamed to computeTimeRemaining()
fun computeTimeRemaining(now : Date, endDate : Date) : RemainingTime {
  // Compute days, hours, minutes, seconds
  ... 
  return RemainingTime(days, hours, minutes, seconds)
}
```

Probably a more perfectionism driven point of view is to point out that `now` is probably not the best variable name.
Here the question is: Does it make the solution excellent by renaming that variable? 
Are we sure that we are not striving for our own subjective perfectionism?
Is there a standard that defines excellence in this context? 
We could argue that it is misleading for the reader of the code.
But is it a blocker to not approve this code from our co-worker? 
What are our team standards in that context that could help us here as a reference for excellence?

But what if I still really really really want to make the point that I, think `Calendar` is a better choice here? 

Here is a little guide that works well for me when reviewing code:

1. Step: Take a step back and ask me: Is it about perfectionism or excellence?
2. Step: If it is about my own perfectionism then I have to acknowledge that. Self-awareness is key.
3. Step: There is nothing wrong with making a comment that I, personally, think that `Calendar` is a better choice but I must acknowledge that it is a matter of personal preference and not because it makes the solution more excellent. 

So my code review comment could look as follows:

![Code Review Comment2](/images/perfectionism-excellence/review_unit_test2.png)

By doing so I don't chase perfection.
I don't want to look perfect and I don't expect the author to achieve unattainable ideals that I consider perfect. 
I actually leave the ownership by the author of the code.

And last but not least, we skip the whole dance where both, the code reviewer and the author of the code, are in disagreement because both stick to their different picture of perfect code. 
Either the code reviewer gets annoyed and says at some point "then do whatever you want" or the author of the code says "okay, I give up and I change it to whatever you want" but for sure they didn't collaborate to improve the code towards an excellent solution.

[^1]: https://en.wikipedia.org/wiki/Perfectionism_(psychology) visited at Januar 28, 2021.
[^2]: Paul L. Hewitt, Gordon L. Flett, Samuel F. Mikail. [Perfectionism: A Relational Approach to Conceptualization, Assessment, and Treatment](https://www.amazon.com/dare-lead-brave-conversations-hearts). 2017.
https://www.amazon.com/Perfectionism-Relational-Conceptualization-Assessment-Treatment/dp/1462528724
[^3]: Brené Brown. [Dare to Lead](https://www.amazon.com/dare-lead-brave-conversations-hearts). 2018.
[^4]: https://en.wikipedia.org/wiki/Excellence