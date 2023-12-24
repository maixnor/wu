

# Code Quality
or Readability / Understandability

To measure the quality of your code measure the WFTs per minute while somebody else is reading your code.

## Smelly Business
Code Quality and Readability are subjective. Therefore most issues with code are like with food when it has gone off. Something is off about that smell. We don't know why and what is causing the feeling, but we can tell.

### Names
Variables and functions should be named properly. They signal what things are doing and what they are. I recommend to name variables with nouns and functions with verbs.

Check out the following 2 examples, I don't even need to read the function in the second code block to know what it (probably) does and can use it right away. 

```R
a <- (1:10)

b <- function(x) { ... }

c <- b(a)
```

```R
interval <- (1:10)

calulate_mean <- function(values) { ... }

mean <- calculate_mean(interval)
```

### (implicit) Loops

R has the language feature which allows you to pass a vector to functions which would by definition only accept a single value. 

```R
increment <- function(x) x + 1

# single value
eight <- increment(7)

before_increment <- (1:5) # 1 2 3 4 5
after_increment <- increment(before_increment))
# after_increment = 2 3 4 5 6
```

In most other language one would have to use a loop or something called a `map` operation (Map = every input value is mapped to an output value). This saves a lot of code to write as you can see since those approaches take much more lines to express the same thing.

```R
with_loop <- function(before_increment) {
	after_increment <- (1:length(before_increment)); # create vector of equal length
	
	for (i in (1:length(before_increment) ) {
		after_increment[i] = increment(before_increment[i])
	}
	
	return after_increment
}

with_map <- function(before_increment) {
	# x is like before_increment[i] from the with_loop snippet
	return before_increment.map(x -> { increment(x) })
	# or some languages can do it like this
	return before_increment.map(increment)
}
```

Be careful tho since you can pack a lot of information into a single line or expression.


