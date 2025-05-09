# Exercise Sheet 6

## Task 1

Write a program that initializes an integer variable `counter` to `0` and subsequently creates `500` POSIX threads.

Each thread should execute a loop of `50000` iterations. In each iteration `i`, the value of `counter` is
  - incremented by `73`, if `i` is even, or
  - decremented by `71`, if `i` is odd.

The main thread waits for all other threads and then prints the final value of `counter`, which should be `25000000`.

To prevent race conditions, implement **two variants**:

- `task_1_atomic.c`: Use **atomics** for incrementing and decrementing the `counter`. Have a look at [Atomic (Reference)](https://en.cppreference.com/w/c/atomic).
- `task_1_mutex.c`: Protect access to `counter` using a **mutex**. Note that the threads must still be able to make progress *concurrently*. Have a look at `pthread_mutex_init(3)`.

Your Makefile should build both binaries: `task_1_atomic` and `task_1_mutex`.

Answer the following questions in `task_1.txt` or `task_1.md`:

1. Optimization flags:

- What is the effect of specifying optimization flags when compiling?
- How do the flags `-O2` and `-O3` differ?

2. Comparing program behavior of the two variants:

- First, create optimized builds by using either `-O2` or `-O3`.
- Measure the execution time of both variants using `/usr/bin/time -v`.
- What is the difference between `elapsed (wall clock) time`, `user time`, and `system time`?
- What conclusions can you draw from inspecting your measurements?

3. Atomic operations:

- What is the difference between using `+=` on a normal vs. an *atomic* integer type?
- How does using e.g. `+=` on atomic types relate to using atomic functions such as `atomic_fetch_add`?
- Which operations other than decrementing/incrementing can be done atomically?

## Task 2

In this task you will revisit the producer-consumer pattern, this time with multiple consumers implemented through POSIX threads.

Your program should take 2 command line arguments: The first argument is the number of *consumers* `c`, which all try to read elements from a queue storing integers, and the second argument is the number of elements `n` which should be put into the queue.

For the queue, you can use the basic implementation that is provided in [`myqueue.h`](task_2/myqueue.h).

- When a consumer thread successfully reads an element, it adds it to its local `sum`.
  When the element is `INT_MAX` (`limits.h`), it prints out the sum, returns it to the main thread and exits.
- The main thread acts as the *producer*.
  After spawning the `c` consumers, it feeds `n` entries into the queue, alternating between `i` and `-i` (starting with `i`), followed by `c` entries of value `INT_MAX`.
- The main thread then waits until all consumers have finished and computes the final sum from all the partial results, prints it to the console and exits. Note that the final sum should be `-(n/2)` if `n` is even and `n/2` if `n` is odd.

To avoid race conditions, synchronize access to the queue by using the `pthread_mutex` facilities.
Check the appropriate man pages (`pthread_mutex_lock(3p)`, `pthread_mutex_destroy(3p)`, ...).
Carefully consider all locations where you might need synchronization.

**Important**: The consumer threads should be able to begin processing elements from the queue *as soon as* the producer has added them, NOT only once all elements have been added.

Example output:

```text
$ ./task_2 5 200000
Consumer 0 sum: 78
Consumer 3 sum: 68
Consumer 2 sum: -123
Consumer 4 sum: 78
Consumer 1 sum: -101
Final sum: -100000
```

Answer the following question in `task_2.txt` or `task_2.md`:

Instead of a mutex, could a semaphore be used in this situation?

## Task 3

Continuing with the single producer, multiple consumer example, in this exercise you should improve the performance of your implementation from the previous task by using a pthread _condition variable_ to signal the availability of new elements to the consumers.

Answer the following question in `task_3.txt` or `task_3.md`:

- What is the advantage of using a condition variable in this case, compared to using plain mutexes?
- When would you use condition variables?
- What are spurious wakeups in the context of condition variables, and how can they be mitigated?
- How does the program behavior differ between the two variants?

Benchmark the following commands and make sure to use an optimized build (`-O2` or `-O3`). Report your findings.

```text
/usr/bin/time -v ./task_2 250 100000
/usr/bin/time -v ./task_3 250 100000

/usr/bin/time -v ./task_2 500 100000
/usr/bin/time -v ./task_3 500 100000

/usr/bin/time -v ./task_2 750 100000
/usr/bin/time -v ./task_3 750 100000

/usr/bin/time -v ./task_2 1000 100000
/usr/bin/time -v ./task_3 1000 100000
```

---

Submit your solution as a zip archive via OLAT, structured as follows, where csXXXXXX is your UIBK login name. Your zip archive **must not** contain binaries.

```text
exc06_csXXXXXX.zip
├── Makefile             # optional
├── group.txt            # optional
├── task_1
│   ├── Makefile
│   ├── task_1_atomic.c
│   ├── task_1_mutex.c
│   └── task_1.txt       # or .md
├── task_2
│   ├── Makefile
│   ├── myqueue.h
│   ├── task_2.c
│   └── task_2.txt       # or .md 
└── task_3
    ├── Makefile
    ├── myqueue.h
    ├── task_3.c
    └── task_3.txt       # or .md
```

Requirements

- [ ] Any implementation MUST NOT produce any additional output
- [ ] If you work in a group, create a `group.txt` file according to the format specified below
- [ ] Auto-format all source files
- [ ] Check your submission on ZID-GPL
- [ ] Check your file structure (and permissions!)
- [ ] Submit zip
- [ ] Mark solved exercises in OLAT

If you worked in a group, the `group.txt` file must be present
and have one line per student which contains the matriculation number
in the beginning, followed by a space and the student's name.
For example, if the group consists of Jane Doe,
who has matriculation number 12345678,
and Max Mustermann, who has matriculation number 87654321,
the `group.txt` file should look like this:

```text
12345678 Jane Doe
87654321 Max Mustermann
```
