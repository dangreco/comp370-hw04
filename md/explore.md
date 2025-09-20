# COMP 370 HW04

## Task 3

### Setting up the dataset

First we need to download the dataset:

```sh
curl -L -o dataset.zip https://www.kaggle.com/api/v1/datasets/download/liury123/my-little-pony-transcript
```

Unzipping:

```sh
unzip dataset.zip
```

Let's clean things up:

```sh
rm dataset.zip
mkdir .in
mv *.csv .in/
echo "/data" >> .gitignore
```

### How big is the dataset?

#### Physical Size

We can check the physical size of dataset through:

```sh
ls -l .in/clean_dialog.csv
```

...which gives us:

```
-rw-r--r-- 1 dgreco dgreco 4870970 Oct 19  2019 .in/clean_dialog.csv
```

To show a more human-readable size, we can use:

```sh
ls -lh .in/clean_dialog.csv
```

...which gives us:

```
-rw-r--r-- 1 dgreco dgreco 4.7M Oct 19  2019 .in/clean_dialog.csv
```

#### Entries

To determine the amount of entries in the CSV file, we can count the number of lines
(skipping the header line):

```sh
tail -n +2 .in/clean_dialog.csv | wc -l
```

...which gives us `36859` entries.

### What's the structure of the data?

#### Fields

We can view the fields of the dataset by using:

```sh
head -n 1 .in/clean_dialog.csv
```

...which gives us:

```
"title","writer","pony","dialog"
```

#### Values

To see some example values, we can get the first 3 entries:

```sh
tail -n +2 .in/clean_dialog.csv | head -n 3
```

...and we get:

```
"Friendship is Magic, part 1","Lauren Faust","Narrator","Once upon a time, in the magical land of Equestria, there were two regal sisters who ruled together and created harmony for all the land. To do this, the eldest used her unicorn powers to raise the sun at dawn; the younger brought out the moon to begin the night. Thus, the two sisters maintained balance for their kingdom and their subjects, all the different types of ponies. But as time went on, the younger sister became resentful. The ponies relished and played in the day her elder sister brought forth, but shunned and slept through her beautiful night. One fateful day, the younger unicorn refused to lower the moon to make way for the dawn. The elder sister tried to reason with her, but the bitterness in the young one's heart had transformed her into a wicked mare of darkness: Nightmare Moon."
"Friendship is Magic, part 1","Lauren Faust","Narrator","She vowed that she would shroud the land in eternal night. Reluctantly, the elder sister harnessed the most powerful magic known to ponydom: the Elements of Harmony. Using the magic of the Elements of Harmony, she defeated her younger sister, and banished her permanently in the moon. The elder sister took on responsibility for both..."
"Friendship is Magic, part 1","Lauren Faust","Narrator and Twilight Sparkle","...sun and moon..."
```

### How many episodes does it cover?

Episodes are denoted by the `title` field in the dataset.
To determine the amount of episodes the dataset covers, we should count the number of unique values for `title`.

Let's first try to get the title of the first entry using `csvtool`:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 1 - | csvtool head 1 -
```

...we get: `"Friendship is Magic, part 1"`. We can remove the quotes by chaining on a `| tr -d '"'`:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 1 - | csvtool head 1 - | tr -d '"'
```

...to get: `Friendship is Magic, part 1`.

We can get the unique lines through the `uniq` command:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 1 - | tr -d '"' | uniq
```

Doing so we get all of the titles used in the dataset. However, one of these is a movie:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 1 - | tr -d '"' | uniq | grep "Movie"
```

...yields: `My Little Pony The Movie`.

To count the number of episodes, we can subtract one from the number of unique titles:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 1 - | tr -d '"' | uniq | wc -l | awk '{print $1-1}'
```

...which gives us `196` episodes.

### Unexpected aspects of the dataset

1. **Mixed speaking lines**: some lines have multiple ponies speaking, e.g.

    ```
    "Narrator and Twilight Sparkle"
    ```

    This makes it difficult to attribute parts of lines to individual ponies.

2. **Ensembles**: some lines are spoken by everyone in a scene,
   e.g. `"All"` or `"Everyone"`. Without context, it's impossible to know who
   exactly is speaking.

3. **Ensemble Omission**: some characters are omitted from an ensemble speaking line, e.g.
   `"All except Rarity"` or `"All sans Twilight Sparkle"`.
   This makes it difficult to attribute lines to individual ponies.

## Task 4

### Calculating speaking frequency of main ponies

#### Getting the total number of lines spoken

To get the total number of lines spoken, we can use:

```sh
csvtool drop 1 .in/clean_dialog.csv | wc -l
```

...which gives us `36859` lines spoken (the same as in Task 2.)

#### Getting the number of lines spoken a pony

To get the number of lines spoken by a specific pony, we can use:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 3 - | head -n 10 | grep "^<PONY>$" | wc -l
```

...where `<PONY>` is the name of the pony we want to check. We match the line
exactly to avoid the ensemble issues from before. Therefore, we are really only
counting lines soley spoken by a pony. For example, to get the number of lines
spoken by Twilight Sparkle, we can use:

```sh
csvtool drop 1 .in/clean_dialog.csv  | csvtool col 3 - | grep "^Twilight Sparkle$" | wc -l
```

...which gives us `4745` line spoken.

#### Calculating the frequencies

To iterate over all main ponies, we can use a `for` loop in a `bash` script:

```sh
#!/usr/bin/env bash

ROOT=$(git rev-parse --show-toplevel)
total=$(csvtool drop 1 $ROOT/.in/clean_dialog.csv | wc -l)

echo "pony_name,total_line_count,percent_all_lines"

for pony in "Twilight Sparkle" "Applejack" "Rarity" "Pinkie Pie" "Rainbow Dash" "Fluttershy"
do
    lines=$(csvtool drop 1 $ROOT/.in/clean_dialog.csv  | csvtool col 3 - | grep "^$pony$" | wc -l)
    percent=$(echo "scale=10; $lines / $total * 100" | bc)
    echo "$pony,$lines,$percent"
done
```

We'll save this as `src/frequency.sh` and make it executable:

```sh
chmod +x src/frequency.sh
```

Running it:

```sh
./src/frequency.sh
```

...we get:

```
pony_name,total_line_count,percent_all_lines
Twilight Sparkle,4745,12.8733823400
Applejack,2748,7.4554382900
Rarity,2660,7.2166906300
Pinkie Pie,2833,7.6860468200
Rainbow Dash,3072,8.3344637600
Fluttershy,2109,5.7218047100
```

We can redirect this to a CSV file:

```sh
./src/frequency.sh > .out/frequency.csv
```

...and that's it!
