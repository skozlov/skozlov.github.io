---
layout: post
title:  Insertion Sort
categories: algorithms
permalink: /algorithms/sort/insertion
mathjax: true
---

## Idea

**To add a next element to a sorted subarray, move greater elements right and *insert* that element into the appropriate place.**

For example, we have the subarray from `1` to `5` sorted and `3` to insert.

![start](/assets/insertion-sort/start.png)

First, we move `4` and `5` right:

![moved](/assets/insertion-sort/moved.png)

And finally, we insert `3`:

![inserted](/assets/insertion-sort/inserted.png)

## Time complexity

### Worst case

When inserting each element, the whole subarray is moved (this takes place for arrays sorted in reverse order), which leads to arithmetic progression $1 + 2 + ... + (n-1) = O(n^2)$.

### Best case

When inserting each element, nothing is moved, i.e. the input is already sorted.
In this case, we just traverse the array once, which requires $O(n)$ operations.

### Average case

It depends on what is considered "average".

For a length of $n$, let's consider all permutations of sequence `1` to `n` and calculate the average number of moves per sequence.
Note that **the number of moves done by the insertion sort is exactly the number of inversions in the array**.
**The average number of inversions** in a permutation of $n$ elements is $\frac{n(n-1)}{4} = O(n^2)$.

<details>
<summary>Proof</summary>

<p>
Initially I tried to calculate the number of permutations of length $n$ with $k$ inversions.
These numbers are known as <i>Mahonian numbers</i> (see M. Bóna, Combinatorics of Permutations, 2004, p. 43ff).
Fortunately, we don't need to calculate them.
</p>

<p>
Instead, let's see how desired average numbers of inversions change when increasing $n$.
Then we get a recurrence relation and solve it.
</p>

<p>
Creation of a permutation of length $n$ can be considered as inserting $n$ into a permutation of $\{1,...,n-1\}$.
</p>

<img src="/assets/insertion-sort/extend-permutation.png" alt="" />

<p>
As a result, each of $(n-1)!$ source permutations become $n$ permutations of length $n$.
Inversions of a final permutation come from two sources:
</p>
<ol>
<li>Inversions of the source permutation.</li>
<li>Inversions added by inserting.</li>
</ol>

<p>
If we denote the total number of inversions in all permutations of length $n$ by $a_n$, the first source gives $na_{n-1}$ inversions.
Regarding the second source, each of $(n-1)!$ source permutations gives $0 + 1 + ... + (n-1)$ inversions.
So $a_n = na_{n-1} + (n-1)! \sum_{k=1}^{n-1} k$.
</p>

<p>Now it's easy to get a recurrence relation for the average number of inversions: $b_n = \frac{a_n}{n!} = \frac{a_{n-1}}{(n-1)!} + (n-1)/2 = b_{n-1} + \frac{n-1}{2}$.</p>

<p>
The generating function: $G(z) = \sum_{n=1}^\infty b_n z^n = \sum_{n=2}^\infty (b_{n-1} + \frac{n-1}{2}) z^n = \sum_{n=2}^\infty b_{n-1} z^n + \sum_{n=2}^\infty \frac{n-1}{2} z^n = zG(z) + \sum_{n=2}^\infty \frac{n-1}{2} z^n$,
then $G(z) = \frac{\sum_{n=2}^\infty \frac{n-1}{2} z^n}{1-z}$.
</p>

<p>
Transform $ \frac{1}{1-z} = \sum_{k=0}^\infty z^k $ and group coefficients in the product of the two sums.
Then $ G(z) = \sum_{n=2}^\infty (\sum_{k=2}^n \frac{n(n-1)}{4}) z^n $, so $ b_n = \frac{n(n-1)}{4} $.
</p>

</details>

<details>
<summary>Note that the average number of inversions is 2 times less than the maximum one.</summary>

<p>In fact, the corresponding distribution is symmetric.</p>

<p>Permutations of length 3:</p>
<img src="/assets/insertion-sort/mahonian3.png" alt="" />

<p>Of length 4:</p>
<img src="/assets/insertion-sort/mahonian4.png" alt="" />

</details>

## Stability

An element can be moved only past greater elements, so the order of equal elements never changes, and the sort is **stable**.

## Usage

Although this sort is not asymptotically optimal, its simplicity makes it super fast for short arrays.

## Implementation

{% highlight java %}
public static <T> void insertionSort(T[] array, Comparator<T> comparator) {
    for (var initialIndex = 0; initialIndex < array.length; initialIndex++) {
        T toInsert = array[initialIndex];
        var targetIndex = initialIndex;
        for (; targetIndex > 0; targetIndex--) {
            T previous = array[targetIndex - 1];
            if (comparator.compare(previous, toInsert) <= 0) {
                break;
            } else {
                array[targetIndex] = previous;
            }
        }
        array[targetIndex] = toInsert;
    }
}
{% endhighlight %}

See [latest version on GitHub](https://github.com/skozlov/algorithms/blob/master/src/main/java/com/github/skozlov/algorithms/Sort.java).