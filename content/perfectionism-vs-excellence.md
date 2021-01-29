---
title: "Perfectionism vs. Excellence"
date: 2021-01-28T10:00:00+01:00
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
That are the questions that I want to answer by looking at a very concrete example from the world of software engineering: Code Reviews.

## What is perfectionism?

Here is the thing: defining what is perfect is subjective, not objective.
Just because something apears perfect for me it doesn't mean that it matches the definition of perfect of another person as well.

Moreover, Perfectionism drives people to be concerned with achieving unattainable ideals or unrealistic goals, often leading to many forms of adjustment problems such as depression, low self-esteem, suicidal thoughts and tendencies and a host of other psychological, physical, relationship, and achievement problems in children, adolescents, and adults.[^1]

Perfectionism is not the key to success. In fact, research[^2] shows that perfectionism hampers achievement and that Perfectionism is correlated with depression, anxiety, addiction, and life paralysis, or missed opportunities.

Brené Brown, a research professor at the University of Houston and  author of five #1 New York Times bestsellers, adds intersting aspects (based on her research) to the definition of perfectionism[^3]:

 > Perfectionism is not self-improvement. Perfectionism is, at its core, about trying to earn approval. Most perfectionists grew up being praised for achievement and performance (grades, manners, rule following, people pleasing, appearance, sports). Somewhere along the way, they adopted this dangerous and debilitating belief system: I am what I accomplish and how well I accomplish it. Please. Perform. Perfect. Prove.
 > Perfectionism is a self-destructive and addictive belief system that fuels this primary thought: If I look perfect and do everything perfectly, I can avoid or minimize the painful feelings of blame, judgment, and shame.
 >
 > **Perfectionism is more about perception than internal motivation, and there is no way to control perception, no matter how much time and energy we spend trying.**

I found it interesting to see perfectionism being linked to perception. 
Do I want to be perceived as perfect? Why? By whom?
Keep that in mind, we will get back to this question later in this blog post once we eventually talk about Code Reviews.

## What is excellent?

According to Wikipedia[^4] excellence is defined as following: 

> Excellence is a talent or quality which is unusually good and so surpasses ordinary standards. It is also used as a standard of performance as measured e.g. through economic indicators.

In contrast to perfectionism, excellence is measured agains standards. 
Thus, excellence is objective. You know which standards you need to meet to achieve excellence and it is measurable.

## Let's talk about Code Reviews
Let's see how this translates to real world examples for software engineers: Code Reviews (like reviewing PRs on Github). 
It's out of scope to talk about the benefits of code reivews. 
I assume you have already been part of both sides of the game: asked for code review and reviewed someone else's code.
For the rest of this article I would like to step into the shoes of the later: being a code reivewer.

Let's say we are working for a shoping company and a coworker of ours is working on adding a little countdown widget to our app that displays how many days, hours, minutes and seconds are remaining until a sale ends.
So the PR that we get to review looks something like this: 

```kotlin
fun secondsRemaining(now : Date, endDate : Date){
  val nowMilliseconds = now.getTime()
  val endMilliseconds = end.getTime()

  val nowSeconds = nowMilliseconds / 1000
  val endSeconds = endSeconds / 1000

  return endSeconds - nowSeconds
}
```

and the PR also contains a unit test:

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

Now, lets see how this relates to our Perfectionism vs. Excellent discussion.

If we are a perfectionist looking for perfection we could request the following changes before we accept this PR (as it matches our definition of perfection only after changes are applied):




[^1]: https://en.wikipedia.org/wiki/Perfectionism_(psychology) visited at Januar 28, 2021.
[^2]: Paul L. Hewitt, Gordon L. Flett, Samuel F. Mikail. [Perfectionism: A Relational Approach to Conceptualization, Assessment, and Treatment](https://www.amazon.com/dare-lead-brave-conversations-hearts). 2017.
https://www.amazon.com/Perfectionism-Relational-Conceptualization-Assessment-Treatment/dp/1462528724
[^3]: Brown, Brené. [Dare to Lead](https://www.amazon.com/dare-lead-brave-conversations-hearts). 2018.
[^4]: https://en.wikipedia.org/wiki/Excellence