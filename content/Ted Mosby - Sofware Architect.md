---
title: "Ted Mosby - Software Architect"
date: 2015-03-25T10:00:00+01:00
description: "Ted Mosby - Software Architect. A library for MVP on Android. Model-View-Presenter Android"
type: "post"
url: "android/mosby"
image: "images/mosby/mosby-intro.jpg"
categories:
  - "Android"
tags:
  - "android"
  - "software-architecture"
  - "design-patterns"
  - "library"
---

Ted Mosby, architect in _How I met your mother_ (one of my favorite tv shows) was the inspiration for the name of this android library I'm going to talk about in this blog post. This library helps you to build good, robust and reusable software by implementing **M**odel-**V**iew-**P**resenter pattern on android along with some nice features like _ViewState_ for handling screen orientation changes easily. This blog post gives you an introduction to Mosby. The next blog post gives you some tips related to Mosby by showing how to implement a mail client on android: [Stinson's playbook for Mosby](http://hannesdorfmann.com/android/mosby-playbook)

## Model-View-Presenter (MVP)
The **M**odel-**V**iew-**P**resenter design pattern is a modern pattern to separate the view from the underlying model. MVP is a derivative of the model–view–controller (MVC) software pattern, also used mostly for building user interfaces.


* The **model** is the data that will be displayed in the view (user interface).
* The **view** is an interface that displays data (the model) and routes user commands (events) to the presenter to act upon that data. The view usually  has a reference to its presenter.
* The **presenter** is the "middle-man" (played by the controller in MVC) and has references to both, view and model. **Please note that the word "Model"** is not correct. It should rather be **business logic that retrieves or manipulates a Model** For instance: If you have a database with **User** and your View wants to display a list of User, then the Presenter would have a reference to your database business logic (like a DAO) from where the presenter will query a list of Users.


![Model-View-Presenter](/images/mosby/mvp-overview.png)

A concrete workflow of querying and displaying a list of users from a database could work like this:

![Model-View-Presenter](/images/mosby/mvp-workflow.png)

The workflow Image shown above should be self-explaining. However here are some additional thoughts:

* The **Presenter** is not a **OnClickListener**. The **View** is responsible for handling user input and invoking the corresponding method of the presenter. Why not eliminating this "forwarding" process by making the **Presenter** an **OnClickListener**? If doing so the presenter needs to have knowledge about views internals. For instance, if a View has two buttons and the view registers the **Presenter** as **OnClickListener** on both, how could the **Presenter** distinguish which button has been clicked on a click event (without knowing views internals like the references to the button)? Model, View and Presenter should be decoupled.
Furthermore, by letting **Presenter** implement **OnClickListener** the Presenter is bound to the android platform. In theory the presenter and business logic could be plain old java code, which could be shared with a desktop application or any other java application.
* The **View** is only doing what the **Presenter** tells the **View** to do like you can see in step 1 and step 2: After the user has clicked on the _"load user button"_ (step 1) the view doesn't show the loading animation directly. It's the presenter (step 2) who explicitly tells the view to show the loading animation. This variant of Model-View-Presenter is called **MVP Passive View**. The view should be as dumb as possible. Let the presenter control the view in an abstract way. For instance: presenter invokes **view.showLoading()** but presenter should not control view specific things like animations. So presenter should not invoke methods like **view.startAnimation()** etc.
* By implementing MVP Passive View it's much easier to handle concurrency and multithreading. Like you can see in step 3 the database query runs async an the presenter is a Listener / Observer and gets notified when data is ready to display.

## MVP on Android
So far so good. but how do you apply MVP on your own Android app? The first question is, where should we apply the MVP pattern? On an Activity, Fragment or a ViewGroup like a RelativeLayout?
Let's have a look at the at the Gmail Android tablet app:

![Model-View-Presenter](/images/mosby/mvp-gmail.png)

From my point of view, there are 4 independent MVP candidates on the screen. With MVP candidate I mean UI element(s) displayed on the screen that logically belongs together and therefore can be seen as a single UI unit where we could apply MVP.

![Model-View-Presenter](/images/mosby/mvp-gmail-candidates.png)

It seems that Activities and especially Fragments are good candidates. Usually a Fragment is responsible to just display a single content like a ListView. For example **InboxView**, controlled by an **InboxPresenter** which uses **MailProvider** to get a List of **Mails**. However, MVP is not limited to Fragments or Activities. You can also apply this design Pattern on **ViewGroups** like shown in **SearchView**. In the most of my apps I use Fragments as MVP candidates. However it's up to you to find MVP candidates. Just ensure that the view is independent so that one presenter can control that View without getting in conflict with another Presenter.

**Why should you implement MVP?**

How would you implement the inbox view in a traditional Fragment without MVP to display a list of emails that needs to be merged from two sources like a local sql database (on your device) and an IMAP mail server connected over internet. How would your code of the fragment looks like? You would start two **AsyncTasks** and have to implement a "wait mechanism" (wait until both tasks have finished to merged the loaded data of both tasks to a single list of mails). You also have to take care of displaying a loading animation (ProgressBar) while loading and replace that one with a ListView afterwards. Would you put all that code into the Fragment? What about errors while loading? What about screen orientation changes? Who is responsible to cancel **AsyncTasks**? This kind of problems can be addressed and solved with MVP. Say goodbye to activities and fragments with 1000+ lines of spaghetti code.

But before we dive deeper in how to implement MVP on Android we have to clarify if an Activity or Fragment is a **View** or a **Presenter**. Activity and Fragment seems to be both, because they have lifecycle callbacks like **onCreate()** or **onDestroy()** as well as responsibilities of View things like switching from one UI widget to another UI widget (like showing a ProgressBar while loading and then displaying a ListView with data). You may say that these sounds like an Activity or Fragment is a Controller and I guess that was the original intention. However, after some years of experience in developing Android apps I came to the conclusion that Activity and Fragment should be treated like a (dumb) **View and not a Presenter**. You will see why afterwards.

With that said, I want to introduce **Mosby** a library for creating MVP based apps on android.

## Mosby

Mosby can be found on [Github](https://github.com/sockeqwe/mosby) and is available in maven central. Mosby is divided into serval submodules so you can pick that components that you need. Let's review the most important one.

### Core - Module
Ted Mosby in How I met your mother wants to create a skyscraper. Building such a impressive building needs a good fundament. Same is valid for Android apps. Basically, the **Core Module**  offers two classes: **MosbyActivity** and **MosbyFragment**. These are the base classe (the fundament) for all other activity or fragment subclasses. Both use well known [annotation processors](http://hannesdorfmann.com/annotation-processing/annotationprocessing101) to reduce writing boilerplate code. _MosbyActivity_ and _MosbyFragment_ use [Butterknife](http://jakewharton.github.io/butterknife/) for view "injection", [Icepick](https://github.com/frankiesardo/icepick) for saving and restoring instance state to a bundle and [FragmentArgs](https://github.com/sockeqwe/fragmentargs) for injecting Fragment arguments. You don't have to call the injecting methods like **Butterknife.inject(this)**. This kind of code is already included in _MosbyActivity_ and _MosbyFragment_. It just works out of the box. The only thing you have to do is to use the corresponding annotations in your subclasses. The _Core - Module_ is not related to MVP. It's just the fundament to build skyscraper apps on it.

### MVP - Module
Mosby's MVP module uses generics to ensure type safety. The base class for all views is **MvpView**. Basically it's just an empty interface. The base class for presenters is **MvpPresenter**:

```java
public interface MvpView { }


public interface MvpPresenter<V extends MvpView> {

  public void attachView(V view);

  public void detachView(boolean retainInstance);
}
```

As already mentioned before we treat Activity and Fragment as Views. Therefore Mobsby's MVP module provides **MvpActivity** and **MvpFragment** which are **MvpViews** as base classes for Activities and Fragments:

```java
public abstract class MvpActivity<V extends MvpView, P extends MvpPresenter> extends MosbyActivity implements MvpView {

  protected P presenter;

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    presenter = createPresenter();
    presenter.attachView(this);
  }

  @Override protected void onDestroy() {
    super.onDestroy();
    presenter.detachView(false);
  }

  protected abstract P createPresenter();
}
```


```java
public abstract class MvpFragment<V extends MvpView, P extends MvpPresenter> extends MosbyFragment implements MvpView {

  protected P presenter;

  @Override public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);

    // Create the presenter if needed
    if (presenter == null) {
      presenter = createPresenter();
    }
    presenter.attachView(this);
  }

  @Override public void onDestroyView() {
    super.onDestroyView();
    presenter.detachView(getRetainInstance());
  }


  protected abstract P createPresenter();
}
```

The idea is that a **MvpView** (i.e. Fragment or Activity) gets attached to and detached from his **MvpPresenter**. Mosby takes Activities and Fragments lifecycle for doing so as you have seen in the code snipped above. Usually a presenter is bound to that lifecycle. So initializing and cleaning up things (like canceling async running tasks) should be done in **presenter.onAttach()** and **presenter.onDetach()**. We will discuss later how a presenter can "escape" this lifecycle in Fragments by using **setRetainInstanceState(true)**. You may have noticed that **MvpPresenter** is an interface. The MVP module provides **MvpBasePresenter**, a presenter implementation which uses **WeakReference** to hold the reference to the view (which is a Fragment or Activity) to avoid memory leaks. Therefore when your presenter wants to invoke a method of the view you always have to check if the view is attached to the presenter by checking **isViewAttached()** and using **getView()** to get the reference.

#### Loading-Content-Error (LCE)
Usually a Fragment is doing the same thing over and over again. It loads data in background, display a loading view (i.e ProgressBar) while loading, displays the loaded data on screen or displays an error view if loading failed. Nowadays supporting pull to refresh is easy as **SwipeRefreshLayout** is part of android's support library. To not reimplementing this workflow again and again Mosby's MVP module provides **MvpLceView**:

```java
public interface MvpLceView<M> extends MvpView {

  /**
   * Display a loading view while loading data in background.
   * <b>The loading view must have the id = R.id.loadingView</b>
   *
   * @param pullToRefresh true, if pull-to-refresh has been invoked loading.
   */
  public void showLoading(boolean pullToRefresh);

  /**
   * Show the content view.
   *
   * <b>The content view must have the id = R.id.contentView</b>
   */
  public void showContent();

  /**
   * Show the error view.
   * <b>The error view must be a TextView with the id = R.id.errorView</b>
   *
   * @param e The Throwable that has caused this error
   * @param pullToRefresh true, if the exception was thrown during pull-to-refresh, otherwise
   * false.
   */
  public void showError(Throwable e, boolean pullToRefresh);

  /**
   * The data that should be displayed with {@link #showContent()}
   */
  public void setData(M data);
}
```

You can use **MvpLceActivity implements MvpLceView** and **MvpLceFragment implements MvpLceView** for that kind of view. Both assume that the inflated xml layout contains views with **R.id.loadingView**, **R.id.contentView** and **R.id.errorView**.

#### Example
In the following example (hosted on[Github](https://github.com/sockeqwe/mosby/tree/master/sample) ) we are loading a list of **Country** by using **CountriesAsyncLoader** and display that in a **RecyclerView** in a Fragment. You can download the [sample APK here](https://db.tt/ycrCwt1L).

Let's start by defining the view interface **CountriesView**:
```java
public interface CountriesView extends MvpLceView<List<Country>> {
}
```

Why do I need to define interfaces for the View?

 1. Since it's an interface you can change the view implementation. You can simple move your code from something that extends Activity to something that extends Fragment.
 2. Modularity: You can move the whole business logic, Presenter and View Interface in a standalone library project. Then you can use this library with the containing Presenter in various apps. The following image shows the [kicker app](https://play.google.com/store/apps/details?id=com.netbiscuits.kicker) on the left which uses an Activity while [meinVerein app](https://play.google.com/store/apps/details?id=com.tickaroo.meinverein) uses a Fragment embedded in a ViewPager. Both use the same library where View-Interface and Presenter are defined and unit tested.
![Model-View-Presenter](/images/mosby/mvp-reuse.png)
 3. You can easily write unit tests since you can mock views by implement the view interface. One could also introduce a java interface for the presenter to make unit testing by using mock presenter objects even more easy.
 4. Another very nice side effect of defining a interface for the view is that you don't get tempted to call methods of the activity / fragment directly from presenter. You get a clear separation because while implementing the presenter the only methods you see in your IDE's auto completion are those methods of the view interface. From my personal experiences I can say that this is very useful especially if you work in a team.

Please note that we could also use **MvpLceView&lt;List&lt;Country&gt;&gt;** instead of defining an (empty, because inherits methods) interface **CountriesView**. But having an dedicated interface **CountriesView** improves code readability and we are more flexible to define more View related methods in the future.



Next we define our views xml layout file with the required ids:

```xml
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    >

  <!-- Loading View -->
  <ProgressBar
    android:id="@+id/loadingView"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_gravity="center"
    android:indeterminate="true"
    />

  <!-- Content View -->
  <android.support.v4.widget.SwipeRefreshLayout
    android:id="@+id/contentView"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    >

    <android.support.v7.widget.RecyclerView
        android:id="@+id/recyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        />

    </android.support.v4.widget.SwipeRefreshLayout>


    <!-- Error view -->
    <TextView
      android:id="@+id/errorView"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      />

</FrameLayout>
```

The **CountriesPresenter** controls **CountriesView** and starts the **CountriesAsyncLoader**:

```java
public class CountriesPresenter extends MvpBasePresenter<CountriesView> {

  @Override
  public void loadCountries(final boolean pullToRefresh) {

    getView().showLoading(pullToRefresh);


    CountriesAsyncLoader countriesLoader = new CountriesAsyncLoader(
        new CountriesAsyncLoader.CountriesLoaderListener() {

          @Override public void onSuccess(List<Country> countries) {

            if (isViewAttached()) {
              getView().setData(countries);
              getView().showContent();
            }
          }

          @Override public void onError(Exception e) {

            if (isViewAttached()) {
              getView().showError(e, pullToRefresh);
            }
          }
        });

    countriesLoader.execute();
  }
}
```

The **CountriesFragment** which implements **CountriesView** looks like this:
```java
public class CountriesFragment
    extends MvpLceFragment<SwipeRefreshLayout, List<Country>, CountriesView, CountriesPresenter>
    implements CountriesView, SwipeRefreshLayout.OnRefreshListener {

  @InjectView(R.id.recyclerView) RecyclerView recyclerView;
  CountriesAdapter adapter;

  @Override public void onViewCreated(View view, @Nullable Bundle savedInstance) {
    super.onViewCreated(view, savedInstance);

    // Setup contentView == SwipeRefreshView
    contentView.setOnRefreshListener(this);

    // Setup recycler view
    adapter = new CountriesAdapter(getActivity());
    recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    recyclerView.setAdapter(adapter);
    loadData(false);
  }

  public void loadData(boolean pullToRefresh) {
    presenter.loadCountries(pullToRefresh);
  }

  @Override protected CountriesPresenter createPresenter() {
    return new SimpleCountriesPresenter();
  }

  // Just a shorthand that will be called in onCreateView()
  @Override protected int getLayoutRes() {
    return R.layout.countries_list;
  }

  @Override public void setData(List<Country> data) {
    adapter.setCountries(data);
    adapter.notifyDataSetChanged();
  }

  @Override public void onRefresh() {
    loadData(true);
  }
}
```

Not that much code to write, right? It's because the base class  **MvpLceFragment** already implements the switching from loading view to content view or error view  for us. At first glance the list of generics parameter of **MvpLceFragment** may discourage you. Let me explain that: The first generics parameter is the type of the content view. The second is the Model that is displayed with this fragment. The third one is the View interface and the last one is the type of the Presenter. To summarize: **MvpLceFragment&lt;AndroidView, Model, View, Presenter&gt;**

Another thing you may have noticed is **getLayoutRes()**, which is a shorthand introduced in **MosbyFragment** for inflating a xml view layout:
```java
@Override public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState){
    return inflater.inflate(getLayoutRes(), container, false);
}
```

So instead of overriding **onCreateView()** you can override **getLayoutRes()**. In general **onCreateView()** should only create the view while **onViewCreated()** should be overridden to init things like Adapter for RecyclerView. **Important: don't forget to call super.onViewCreated()**

### ViewState - Module
Now you should have an idea of how to use Mosby. Mosby's ViewState module helps you to solve on of the annoying things in android development: Handling screen orientation changes.

**Question:** What happens if we rotate our device from portrait to landscape that runs our countries example app and already displays a list of countries?

**Answer:** A new **CountriesFragment** gets instantiated and the app starts by showing the **ProgressBar** (and loads list of countries again) rather than displaying the list of countries in the **RecyclerView** (as it was before the screen rotation) as you can see in the video below:

{{< youtube tSRoIwDXidQ >}}
<p>

Mosby introduces **ViewState** to solve this problem. The idea is, that we track the methods the presenter invokes on the attached View. For instance the presenter calls **view.showContent()**. Once **showContent()** gets called the view knows that it's state is "showing content" and hence the view  stores this information into a **ViewState**. If the view gets destroyed during orientation changes, the ViewState gets stored into a bundle in **Activity.onSaveInstanceState(Bundle)** or **Fragment.onSaveInstanceState(Bundle)** and will be restored in **Activity.onCreate(Bundle)** or **Fragment.onActivityCreated(Bundle)**.

Since not every kind of data (I'm talking about the data type passed as parameter in **view.setData()** ) can be stored in a Bundle, different ViewState implementations are provided like **ArrayListLceViewState** for data of type **ArrayList&lt;Parcelable&gt;**, **ParcelableDataLceViewState** - for data of type **Parcelable** or **SerializeableLceViewState** - for data of type **Serializeable**. If you use a retaining Fragment (more about retaining Fragments below) then the **ViewState** is not destroyed during screen orientation changes and doesn't need to be saved into a Bundle. Hence it can store any type of data. In that case you should use **RetainingFragmentLceViewState**. Restoring a **ViewState** is easy. Since we have a clean architecture and an interface for our **View**, **ViewState** can restore the associated view by calling the same interface methods as the presenter does. For example **MvpLceView** basically has 3 states: it can display **showContent()**, **showLoading()** and **showError()** and hence the ViewState himself calls the corresponding method to restore the views state.

That are just internals. You only need to know about that if you want to write your own custom ViewStates.
Using **ViewStates** is pretty easy. Actually, to migrate an **MvpLceFragment** to an **MvpLceViewStateFragment** you only additionally have to implement **createViewState()** and **getData()**. Let's do that for our **CountriesFragment**:

```java
public class CountriesFragment
    extends MvpLceViewStateFragment<SwipeRefreshLayout, List<Country>, CountriesView, CountriesPresenter>
    implements CountriesView, SwipeRefreshLayout.OnRefreshListener {

  @InjectView(R.id.recyclerView) RecyclerView recyclerView;
  CountriesAdapter adapter;


  @Override public LceViewState<List<Country>, CountriesView> createViewState() {
    return new RetainingFragmentLceViewState<List<Country>, CountriesView>(this);
  }

  @Override public List<Country> getData() {
    return adapter == null ? null : adapter.getCountries();
  }

   // The code below is the same as before

  @Override public void onViewCreated(View view, @Nullable Bundle savedInstance) {
    super.onViewCreated(view, savedInstance);

    // Setup contentView == SwipeRefreshView
    contentView.setOnRefreshListener(this);

    // Setup recycler view
    adapter = new CountriesAdapter(getActivity());
    recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    recyclerView.setAdapter(adapter);
    loadData(false);
  }


  public void loadData(boolean pullToRefresh) {
    presenter.loadCountries(pullToRefresh);
  }

  @Override protected CountriesPresenter createPresenter() {
    return new SimpleCountriesPresenter();
  }

  // Just a shorthand that will be called in onCreateView()
  @Override protected int getLayoutRes() {
    return R.layout.countries_list;
  }

  @Override public void setData(List<Country> data) {
    adapter.setCountries(data);
    adapter.notifyDataSetChanged();
  }

  @Override public void onRefresh() {
    loadData(true);
  }
}
```

That's all. You don't have to change code of your presenter or something else. Here is a video of our CountriesFragment **with ViewState** support where you can see that now the view is still in the same "state" after orientation changes, i.e. the view  shows the list of Countries in portrait, then it also shows the list of Countries in landscape. The view shows the pull to refresh indicator in landscape and shows the pull to refresh indicator after changing to portrait as well.

{{< youtube Ni7e5NhUEUw >}}

#### Writing your own ViewState
**ViewState** is a really powerful and flexible concept. So far you learned how easy it is to use one of the provided LCE (Loading-Content-Error) ViewsStates. Now lets write our own custom View and ViewState. Our View should only display two different kind of data objects **A** and **B**. The result should look like this:

{{< youtube 9iSBGEIZmUw >}}

I know, it's not that impressive. It should just give you an idea of how easy it is to create your own ViewState.

The View interface and the data objects (model) looks like this:
```java

public class A implements Parcelable {
  String name;

  public A(String name) {
    this.name = name;
  }

  public String getName() {
    return name;
  }
}

public class B implements Parcelable {
  String foo;

  public B(String foo) {
    this.foo = foo;
  }

  public String getFoo() {
    return foo;
  }
}

public interface MyCustomView extends MvpView {

  public void showA(A a);

  public void showB(B b);
}
```

We don't have any business logic in this simple sample. Let's assume that in a real world app there would be a complex operation in our business logic to generate **A** or **B**. Our presenter looks like this:

```java
public class MyCustomPresenter extends MvpBasePresenter<MyCustomView> {

  Random random = new Random();

  public void doA() {

    A a = new A("My name is A "+random.nextInt(10));

    if (isViewAttached()) {
      getView().showA(a);
    }
  }

  public void doB() {

    B b = new B("I am B "+random.nextInt(10));

    if (isViewAttached()) {
      getView().showB(b);
    }
  }
}
```

We define **MyCustomActivity** which implements **MyCustomView**

```java
public class MyCustomActivity extends MvpViewStateActivity<MyCustomView, MyCustomPresenter>
    implements MyCustomView {

  @InjectView(R.id.textViewA) TextView aView;
  @InjectView(R.id.textViewB) TextView bView;

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.my_custom_view);
  }

  @Override public RestoreableViewState createViewState() {
    return new MyCustomViewState(); // Our ViewState implementation
  }

  // Will be called when no view state exist yet,
  // which is the case the first time MyCustomActivity starts
  @Override public void onNewViewStateInstance() {
    presenter.doA();
  }

  @Override protected MyCustomPresenter createPresenter() {
    return new MyCustomPresenter();
  }

  @Override public void showA(A a) {
    MyCustomViewState vs = ((MyCustomViewState) viewState);
    vs.setShowingA(true);
    vs.setData(a);
    aView.setText(a.getName());
    aView.setVisibility(View.VISIBLE);
    bView.setVisibility(View.GONE);
  }

  @Override public void showB(B b) {
    MyCustomViewState vs = ((MyCustomViewState) viewState);
    vs.setShowingA(false);
    vs.setData(b);
    bView.setText(b.getFoo());
    aView.setVisibility(View.GONE);
    bView.setVisibility(View.VISIBLE);
  }

  @OnClick(R.id.loadA) public void onLoadAClicked() {
    presenter.doA();
  }

  @OnClick(R.id.loadB) public void onLoadBClicked() {
    presenter.doB();
  }
}
```

Since we are not having LCE (Loading-Content-Error) we are not using **MvpLceActivity** as base class. We use **MvpViewStateActivity** as base class which is the most general Activity implementation that supports **ViewState**. Basically our View simply displays **aView** or **bView**.
In **onNewViewStateInstance() ** we have to specify what to do on first Activity start, because no previous **ViewState** instance exists to restore. In **showA(A a)** and **showB(B b)** we have to save the information that we are displays **A** or **B** into our **ViewState**. We are almost done, only  **MyCustomViewState** implementation is missing:

```java
public class MyCustomViewState implements RestoreableViewState<MyCustomView> {

  private final String KEY_STATE = "MyCustomViewState-flag";
  private final String KEY_DATA = "MyCustomViewState-data";

  public boolean showingA = true; // if false, then show B
  public Parcelable data; // Can be A or B

  @Override public void saveInstanceState(Bundle out) {
    out.putBoolean(KEY_STATE, showingA);
    out.putParcelable(KEY_DATA, data);
  }

  @Override public boolean restoreInstanceState(Bundle in) {
    if (in == null) {
      return false;
    }

    showingA = in.getBoolean(KEY_STATE, true);
    data = in.getParcelable(KEY_DATA);
    return true;
  }

  @Override public void apply(MyCustomView view, boolean retained) {

    if (showingA) {
      view.showA((A) data);
    } else {
      view.showB((B) data);
    }
  }

  /**
   * @param a true if showing a, false if showing b
   */
  public void setShowingA(boolean a) {
    this.showingA = a;
  }

  public void setData(Parcelable data){
    this.data = data;
  }
}
```

As you can see we have to save our **ViewState** in **saveInstanceState()** which will be called from **Activity.onSaveInstanceState()** and restore the viewstate's data in **restoreInstanceState()** which will be called from **Activity.onCreate()**. The **apply()** method will be called from Activity to restore the view state. We do that by calling the same View interface methods **showA()** or **showB()** like the presenter does.

This external **ViewState** class pulls the complexity and responsibility of restoring the view's state out from the Activity code into this separated class. It's also easier to write unit tests for a **ViewState** class  than for an **Activity** class.


#### How to handle background threads?

Usually background threads are observed by the **Presenter**. There are two scenario how presenter can handle background threads depending on the the surrounding Activity or Fragment:

 - **Retaining Fragment:** If you set **Fragment.setRetainInstanceState(true)** then the Fragment will not be destroyed during screen rotations. Only the Fragment's GUI (the **android.view.View**  returned from **onCreateView()**) get's destroyed an newly created. That means all of your fragment class member variables are still there after screen rotation and so is the presenter still there after screen orientation has been changed. In that case we just detach the old view from presenter and attach the new view to presenter. Hence the presenter doesn't have to cancel any running background task, because the view gets reattached. Example:
    1. We start our app in portrait.
    2. The retaining fragment gets instantiated and calls **onCreate()**, **onCreateView()**, **createPresenter()** and attach the view (the fragment himself) to the presenter by calling **presenter.attachView()**.
    3. Next we rotate our device from portrait to landscape.
    4. **onDestroyView()** gets called which calls **presenter.detachView(true)**. Note that the parameter **true**, informs the presenter that the fragment is a retaining fragment (otherwise the parameter would be set to false). Therefore the presenter knows that he doesn't have to cancel  running background threads.
    5. App is in landscape now. **onCreateView()** gets called, but **not** **createPresenter()** because  **presenter != null** since presenter variable has survived orientation changes because of **setRetainInstanceState(true)**.
    6. View gets reattached to presenter by **presenter.attachView()**.
    7. **ViewState** gets restored. Since no background thread has been canceled restarting background threads is not needed.

 - **Activity and NOT Retaining Fragments:** In that case the workflow is quite simple. Everything gets destroyed (presenter instance too), hence the presenter should cancel running background tasks. Example:
     1. We start our app in portrait with an **NOT** retaining fragment
     2. The fragment gets instantiated and calls **onCreate()**, **onCreateView()**, **createPresenter()** and attach the view (the fragment) to the presenter by calling **presenter.attachView()**.
     3. Next we rotate our device from portrait to landscape.
     4. **onDestroyView()** gets called which calls **presenter.detachView(false)**. Presenter cancels background tasks.
     5. **onSaveInstanceState(Bundle)** gets called where the **ViewState** gets saved into the Bundle.
     6. App is in landscape now. A new Fragment gets instantiated and calls **onCreate()**, **onCreateView()**, **createPresenter()**, which creates a new presenter instance and attaches the new view to the new presenter by calling **presenter.attachView()**.
     7. **ViewState** gets restored from Bundle and restores the views state. If the **ViewState** was **showLoading** then the presenter restarts new background threads to load data.


To sum it up here is a lifecycle diagram for **Activities** with ViewState support:
![Model-View-Presenter](/images/mosby/mvp-activity-lifecycle.png)

and here is the lifecycle diagram for **Fragments** with ViewState support:

![Model-View-Presenter](/images/mosby/mvp-fragment-lifecycle.png)

### Retrofit - Module
Mosby provides **LceRetrofitPresenter** and **LceCallback**. Writing  an Presenter for Retrofit with support for LCE methods **showLoading()**, **showContent()** and **showError()** can be done in few lines of code.

```java
public class MembersPresenter extends LceRetrofitPresenter<MembersView, List<User>> {

  private GithubApi githubApi;

  public MembersPresenter(GithubApi githubApi){
    this.githubApi = githubApi;
  }

  public void loadSquareMembers(boolean pullToRefresh){
    githubApi.getMembers("square", new LceCallback(pullToRefresh));
  }
}
```


### Dagger - Module
Building an app without dependency injection? Ted Mosby would kick you in the ass! Dagger is one of the most used dependency injection frameworks for java and very popular by android developers. Mosby supports [Dagger1](https://github.com/square/dagger). Mosby provides an **Injector** interface with a method called **getObjectGraph()**. Usually, you have an application wide module. To share this module easily you have to subclass **android.app.Application** and make it implement **Injector**. Then all Activities and Fragments can access that **ObjectGraph** by calling **getObjectGraph()** since DaggerActivity and DaggerFragment are **Injector** as well. You can also call **plus(Module)** to add modules by overriding **getObjcetGraph()** in Activity or Fragment. I personally have migrated to  [Dagger2](https://github.com/google/dagger), which works also with Mosby. You can find samples for both Dagger1 and Dagger2 on [Github](https://github.com/sockeqwe/mosby). The Dagger1 sample apk can be downloaded [here](https://db.tt/3fVqVdAz) and Dagger2 sample apk can be downloaded [here](https://db.tt/z85y4fSY)

### Rx - Module
**Observables** ftw! Nowadays all the cool kids use RxJava and you know what? RxJava is pretty cool! Therefore Mosby offers **MvpLceRxPresenter** which internally is a **Subscriber** and handles for you automatically **onNext()**, **onCompleted()** and **onError()** as well as invoking the corresponding LCE method like **showLoading()**, **shwoContent()** and **showError()**. It also ships with RxAndroid to **observerOn()** Androids Main UI Thread. You may think that you don't need Model View Presenter anymore by using RxJava. Well, that's your decision. In my opinion a clear separation between View and Model is essential. I also think that some nice features like **ViewState** is not as easy to implement without MVP. And last but not least, do you really wanna step back where Activities and Fragments containing more than 1000+ lines of code? Welcome back to the spaghetti code hell. Ok, let's be fair, it's not spaghetti code because Observables introduce a nice structured workflow, but you are one step closer to make your Activity or Fragment to a [BLOB](http://www.antipatterns.com/briefing/sld024.htm)

### Testing - Module
You may have noticed that a testing module exists. This module is used internally to test mosby library. However it can also be used for your own app. It offers unit testing templates for your LCE Presenter, Activities and Fragments by using Robolectric. Basically, it checks if the Presenter under test is working correctly: Does the presenter calls **showLoading()**, **showContent()** and **showError()**. You can also verify the data from **setData()**. So you could write kind of black box tests for Presenter and underlying layers. Mosby's testing module also provides the possibility to test your **MvpLceFragment** or **MvpLceActivity**. It's kind of an "lite" UI test. These tests only check if the Fragment or Activity is working properly without crashing, by checking if the xml layout contains the required ids like **R.id.loadingView**, **R.id.contentView** and **R.id.errorView** or checks if the loadingView is visible, while loading data, is the error view visible, does the content view can handle the loaded data submitted by **setData()**. It's not an UI test like you could do with Espresso. I don't see the need to write UI tests for LCE Views.
Concluding here are Ted Mosby's testing tips:
 1. Write traditional unit tests for testing your business logic and models.
 2. Use **MvpLcePresenterTest** to test your presenters,
 3. Use **MvpLceFragmentTest** and **MvpLceActivityTest** to test your MvpLceFragment / Activity.
 4. If you want, you can write UI Tests by using Espresso.


The Testing - Module is not complete yet. You can see this module as beta software, because Robolectric 3.0 is not finished yet, nor has android gradle plugin full support for traditional unit tests. This should be much better with android gradle plugin 1.2. I will write another blog post about unit testing with Mosby, Dagger, Retrofit and RxJava once Robolectric and androids gradle plugin are ready to be used.

**Update:** A new Blog post with some tips related to Mosby by showing how to implement a mail client on android is online: [Stinson's playbook for Mosby](http://hannesdorfmann.com/android/mosby-playbook)
