---
title: "My newest post"
date: 2020-05-14T14:46:10+06:00
description: "This is meta description"
type: "post"
image: "images/featured-post/post-1.jpg"
categories: 
  - "Valuable Idea"
tags:
  - "Photos"
  - "Finance"
---


Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex
ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque
laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae
dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia
consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem
ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut
labore et dolore magnam aliquam quaerat voluptatem.

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex
ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque
laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae
dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia
consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem
ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut
labore et dolore magnam aliquam `quaerat` voluptatem.


> Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut
labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum


![](../images/post-img.jpg)

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex
ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque
laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae
dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia
consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem
ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut
labore et dolore magnam aliquam quaerat voluptatem.


```kotlin
@JvmOverloads
fun showEditTextDialog(
    context: Context,
    @StringRes titleResId: Int,
    preFilledText: String?,
    saveCallback: (String) -> Unit,
    shouldDisablePositiveButton: (String) -> Boolean = { false },
    @StringRes hintResId: Int? = null,
    textInputType: Int = InputType.TYPE_CLASS_TEXT
): Dialog {
    val view = View.inflate(
        context.dialogContext,
        R.layout.dialog_input,
        null
    )
    val editText = view.editText
    editText.apply {
        inputType = textInputType
        preFilledText?.let {
            setText(preFilledText)
            setSelection(preFilledText.length)
        }

        hintResId?.let {
            setHint(it)
        }
    }

    val dialog = FreeleticsDialog.Builder(context)
        .title(titleResId)
        .positiveButton(LocalizationR.string.dialog_ok) {
            saveCallback(editText.text.toString())
        }
        .negativeButton(LocalizationR.string.fl_mob_bw_global_dialog_cancel)
        .view(view)
        .build()

    fun updatePositiveButtonDisabled() {
        if (dialog.getButton(AlertDialog.BUTTON_POSITIVE) != null) {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).isEnabled =
                !shouldDisablePositiveButton(editText.text.toString())
        }
    }

    dialog.setOnShowListener {
        updatePositiveButtonDisabled()
        editText.requestFocus()
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.showSoftInput(
            editText,
            InputMethodManager.SHOW_IMPLICIT
        )
    }

    editText.addTextChangedListener(object : TextWatcher {
        override fun beforeTextChanged(
            s: CharSequence,
            start: Int,
            count: Int,
            after: Int
        ) {
        }

        override fun onTextChanged(
            s: CharSequence,
            start: Int,
            before: Int,
            count: Int
        ) {
            updatePositiveButtonDisabled()
        }

        override fun afterTextChanged(s: Editable) {}
    })

    dialog.show()
    return dialog
}
```

Hello next

```kotlin
/**
 * Hello
 */
 // single comment
enum class Screen(val analyticsName: String) {
    SignIn("Sign In")
    val c = 'c'
    val i : Int = 1
    val d : Double = 2.0
    val f : Float = 0.1f
    val b : Boolean = true
}

data class Foo (val a:Int)
```

```kotlin
package com.freeletics.feature.paywall.composer.grouper

import com.freeletics.api.apimodel.SubscriptionBrandType
import com.freeletics.feature.paywall.datasources.ProductDetails
import javax.inject.Inject

/**
 * Groups products by their brand
 */
internal class BrandGrouper @Inject constructor() : ProductGrouper<BrandGroup> {

    @Throws(DifferentBrandTypesException::class, IllegalArgumentException::class)
    override fun group(products: List<ProductDetails>): ProductGroups<BrandGroup> {
        if (products.isEmpty())
            throw IllegalArgumentException("Empty product list is not permitted")

        val i = 1.0

        val expectedBrandType = products[0].product.subscriptionBrandType
        if (!products.all { it.product.subscriptionBrandType == expectedBrandType })
            throw DifferentBrandTypesException

        val productGroup = BrandGroup(
            products.sortedByDescending { it.product.months },
            expectedBrandType
        )

        return ProductGroups(listOf(productGroup))
    }
}

internal data class BrandGroup(
    override val products: List<ProductDetails>,
    val type: SubscriptionBrandType
) : ProductGroup

object DifferentBrandTypesException :
    IllegalArgumentException("More than one brand type in the list")

```