# Movie DB Case Study

## Popular movies list

### Story: Customer requests to see popular movies list

### Narrative #1

```
As an online customer
I want the app to automatically load the recent popular movies
So I can always enjoy the newest popular movies
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see the popular movies
 Then the app should display the latest popular movies from remote
  And replace the cache with the new popular movies
```

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of popular movies
So I can always enjoy the newest saved popular movies
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there’s a cached version of popular movies
  And the cache is less than seven days old
 When the customer requests to see the popular movies
 Then the app should display the latest popular movies saved

Given the customer doesn't have connectivity
  And there’s a cached version of the popular movies
  And the cache is seven days old or more
 When the customer requests to see the popular movies
 Then the app should display an error message

Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the popular movies
 Then the app should display an error message
```

## Use Cases

### Load Popular Movies From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Popular Movies" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates popular movies from valid data.
5. System delivers popular movies.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

### Load Popular Movies From Cache Use Case

#### Primary course:
1. Execute "Load Popular Movies" command with above data.
2. System retrieves movies data from cache.
3. System validates cache is less than seven days old.
4. System creates popular movies from cached data.
5. System delivers popular movies.

#### Retrieval error course (sad path):
1. System delivers error.

#### Expired cache course (sad path): 
1. System delivers no feed images.

#### Empty cache course (sad path): 
1. System delivers no feed images.

---

### Validate Popular Movies Cache Use Case

#### Primary course:
1. Execute "Validate Cache" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.

#### Retrieval error course (sad path):
1. System deletes cache.

#### Expired cache course (sad path): 
1. System deletes cache.

---

### Cache Popular Movies Use Case

#### Data:
- Popular movie

#### Primary course (happy path):
1. Execute "Save Popular movie" command with above data.
2. System deletes old cache data.
3. System encodes popular movie.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.

---
