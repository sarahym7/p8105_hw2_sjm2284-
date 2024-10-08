---
  title: "Homework 2"
author: "Sarahy Martinez"
date: "09-29-2024"
output: github_document
---
  
  Libraries Used for this HW
```{r message=FALSE}
library(tidyverse)
library(tidyr)
library(readxl)
```

---
  title: "Homework 2"
author: "Sarahy Martinez"
date: "09-29-2024"
output: github_document
---
  
  Libraries Used for this HW
```{r message=FALSE}
library(tidyverse)
library(tidyr)
library(readxl)
```

## Problem 1


```{r, cleaning_nyc, message=FALSE}
NYC_transit =
  read_csv("./data/NYC_Transit_Subway_Entrance_AND_EXIT_DATA.csv", na = c("NA", ".", "")) %>% 
  janitor::clean_names() %>% 
  relocate(line:entry, ada,vending) %>% 
  select(-division:-entrance_location, station_location) %>% 
  mutate(entry = ifelse(entry == "YES", TRUE, FALSE)) %>% 
  mutate(vending = ifelse(vending == "YES", TRUE, FALSE)) %>% 
  mutate(across(starts_with("route"), as.character)) %>% 
  pivot_longer(
    route1:route11,
    names_to = "route_number",
    values_to = "route_name",
  ) %>% 
  relocate(station_name,station_location,route_number, route_name,line,entrance_type, entry, ada,vending)

```

This dataset contains the variables  station name, station location, train route number, routes,line, entrance type, entry, exit only, vending, ada, station lat, and station long. I cleaned my data by using clean names to fix the variable names, relocated the order of my variables for legibility, selected my columns/ data of interest, mutated the character variables from entry to logical, mutates the names of the routes as characters because it wasn't allowing me to run the pivot function , then used the pivot_longer to tidy the data and combine route numbers to one column  and assign the routes their own column with the station, and relocated again for legibility.  Data is now tidy.



```{r, counting}
count(distinct(NYC_transit, station_name,line))

transit_entry = 
  NYC_transit %>% 
  filter(ada == TRUE) %>% 
  select(station_name, line) %>% 
  distinct()

transit_entry = NYC_transit %>% 
  filter( vending == "FALSE") %>% 
  pull(entry) %>% 
  mean()

A_train =
  NYC_transit %>% 
  filter(route_name == "A") %>% 
  distinct(station_name, line) 
nrow(A_train)

A_train_ada =
  NYC_transit %>% 
  filter(route_name == "A", ada== TRUE) %>% 
  distinct(station_name, line) 
nrow(A_train_ada)
 
```

* There are 465 distinct stations.
* There are 84 stations that are ADA compliant. 
* There proportion of entrances/ exits without vending that allow entrance, is  0.377. 
* There are 60 stations that serve the A train, and 17 are ADA compliant. 


## Probem 2


Importing and reading the dataset

```{r, mister_trash}

mister_trash_data = read_excel("./data/202409 Trash Wheel Collection Data New.xlsx", 
                               sheet=1,
                               skip = 1,
                               range= "A2:N653",
                               na = c("NA", ".", "")) %>% 
                            janitor::clean_names() %>% 
                            mutate(sports_balls = as.integer(round(sports_balls))) %>% 
                            mutate(year = as.numeric(year)) %>% 
                            mutate(trash = "mister_trash") 


```




```{r, professor_trash}

professor_trash = read_excel("./data/202409 Trash Wheel Collection Data New.xlsx", 
                               sheet=2,
                               skip = 1,
                               range= "A2:M121",
                               na = c("NA", ".", "")) %>% 
                            janitor::clean_names() %>% 
                            mutate(year = as.numeric(year)) %>% 
                            mutate(trash = "professor_trash") 


```



```{r, gwynnda_sheet}

gwynnda_trash = read_excel("./data/202409 Trash Wheel Collection Data New.xlsx", 
                               sheet=4,
                               skip = 1,
                               range= "A2:L265",
                               na = c("NA", ".", "")) %>% 
                            janitor::clean_names() %>% 
                            mutate(year = as.numeric(year)) %>% 
                            mutate(trash = "gwynnda_trash") 
                            

```


```{r}

trash_wheel_tidy = 
  bind_rows(professor_trash, gwynnda_trash, mister_trash_data) %>% 
  janitor::clean_names() %>% 
  select(trash, everything())

nrow(trash_wheel_tidy)
ncol(trash_wheel_tidy)
summary(trash_wheel_tidy)

rowSums(is.na(trash_wheel_tidy))

```
In this dataset we have 15 variables which include dumpster, month, year, date, weight_tons, volume_cubic_yards, plastic_bottles, polystyrene, cigarette_butts, glass_bottles, plastic_bags, wrappers, homes_powered,sports_balls, and trash (to specify from which dataset). There are a total of 1,033 observations (rows) and 15 columns. The datasheets were individually imported, in mister trash I mutated the year and same for the rest due to years being considered as a character in one dataset and the others as numeric so I converted them all to numeric and get the mean years, committed data is 2022. I also cleaned the names for reasonable variable names and mutated again to create a variable name to identify which dataset the trash is from. 

```{r}

total_weight_prof =  trash_wheel_tidy %>% 
                     filter(trash == "professor_trash") %>% 
                     summarise(total_weight = sum(weight_tons, na.rm = TRUE))

print(total_weight_prof)


total_cigs_gwn =  trash_wheel_tidy %>% 
                     filter(trash == "gwynnda_trash", year == "2022", month == "June") %>% 
                     summarise(cigarette_butts = sum(cigarette_butts, na.rm = TRUE))
print(total_cigs_gwn)

```


* The total weight of trash collected by Professor trash wheel was 246.76 tons. 
* In the month of June 2022 Gwynnda collected 18,120 cigarette butts. 


## Problem 3

```{r, original}


bakers_df = 
  read_csv("./data/bakers.csv", na = c("NA", ".", "")) %>% 
  janitor::clean_names() %>% 
  separate(baker_name, into = c("first_name", "last_name"), sep = " ") %>% 
  select(- last_name) %>% 
  rename(bakers = first_name) %>% 
  drop_na()

bakes_df = 
  read_csv("./data/bakes.csv", na = c("NA", ".", "")) %>% 
  janitor::clean_names() %>% 
  rename(bakers = baker) %>% 
  drop_na()

results_df = 
  read_csv("./data/results.csv", skip = 3, col_names = FALSE,na = c("NA", ".", "")) %>% 
  janitor::clean_names() %>% 
  rename(series = x1,episode = x2, baker = x3, technical = x4, result = x5, ) %>% 
  rename( bakers = baker) %>% 
  drop_na()


GBB_merged_ = 
  full_join(results_df, bakes_df, by = c("bakers", "series", "episode")) %>% 
  full_join(x= ., bakers_df, by =c("series","bakers"))



```


## problem 3, part 2 

```{r, views}
views = 
  read_csv("./data/viewers.csv",na = c("NA", ".", ""))  %>% 
  janitor::clean_names() %>% 
  rename( season_1 = series_1, season_2 = series_2, season_3 = series_3, season_4 = series_4, season_5 = series_5, season_6 = series_6, season_7 = series_7, season_8 = series_8, season_9 = series_9, season_10 = series_10) %>% 
  head(10)
 

mean(pull(views, season_1), na.rm = TRUE)
mean(pull(views, season_5), na.rm = TRUE)


```

* The average viewership in season 1 was 2.77 
* The average viewership in season 5 was 10.0393

