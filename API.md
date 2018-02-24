SubsCity API
===================

All results are cached for up to 15 minutes.

* [Movies](#movies)
* [Cinemas](#cinemas)
* [Screenings](#screenings)
  * [For a movie](#for-a-movie)
  * [For a cinema](#for-a-cinema)
  * [For a date](#for-a-date)

## Movies

* https://msk.subscity.ru/movies.json?sort=[type][field]
* https://spb.subscity.ru/movies.json?sort=[type][field]

Allowed `type` values:
* `+` (ascending)
* `-` (descending)

Allowed `field` values:
* `id`
* `imdb` (IMDb rating)
* `kinopoisk` (KinoPoisk rating)
* `next_screening`
* `screenings` (screenings count)
* `title` (Russian title)

Default sorting: `+title`

Example: https://msk.subscity.ru/movies.json?sort=-kinopoisk

```JSON
[
  {
    "age_restriction": 16,
    "cast": [
      "Джозеф Гордон-Левитт",
      "Шейлин Вудли",
      "Скотт Иствуд"
    ],
    "countries": [
      "США",
      "Германия",
      "Франция"
    ],
    "created_at": "2016-09-09T05:55:55+03:00",
    "description": "Он мечтал продолжить семейную традицию и посвятить свою жизнь служению Родине.",
    "directors": [
      "Оливер Стоун"
    ],
    "duration": 140,
    "genres": [
      "триллер"
    ],
    "id": 24070,
    "languages": [
      "английский"
    ],
    "poster": "https://msk.subscity.ru/images/posters/24070.jpg",
    "rating": {
      "imdb": {
        "id": 3774114,
        "rating": 7.4,
        "votes": 9427
      },
      "kinopoisk": {
        "id": 843831,
        "rating": 7.2,
        "votes": 5464
      }
    },
    "screenings": {
      "count": 7,
      "next": "2016-10-12T10:00:00+03:00"
    },
    "title": {
      "original": "Snowden",
      "russian": "Сноуден"
    },
    "trailer": {
      "original": "QlSAiI3xMh4",
      "russian": "f93Wttq02zI"
    },
    "year": 2016
  },

  ...

]
```

## Cinemas

* https://msk.subscity.ru/cinemas.json?sort=[type][field]
* https://spb.subscity.ru/cinemas.json?sort=[type][field]

Allowed `type` values:
* `+` (ascending)
* `-` (descending)

Allowed `field` values:
* `id`
* `name`

Default sorting: `+name`

```JSON
[
  {
    "id": 28,
    "location": {
      "address": "Покровка, 47/24",
      "metro": [
      "Красные Ворота",
      "Курская"
      ],
      "latitude": 55.763611,
      "longitude": 37.654027
    },
    "movies": [
      25636,
      24367,
      25415,
      24070,
      25666
    ],
    "movies_count": 5,
    "name": "35ММ",
    "phones": [
      "+7 (495) 917 17 48"
    ],
    "urls": [
      "http://www.kino35mm.ru"
    ]
  },

  ...

]
```

## Screenings

### For a movie

* https://msk.subscity.ru/movies/screenings/[movie_id].json
* https://spb.subscity.ru/movies/screenings/[movie_id].json

```JSON
[
  {
    "cinema_id": 28,
    "date_time": "2016-10-10T11:40:00+03:00",
    "movie_id": 53456,
    "price_max": 250,
    "price_min": 200,
    "screening_id": 24211338
  },

  ...

]
```

Sorting: by `date_time` ascending.

**NB**: `screening_id` field is a Rambler.Kassa's screening ID.

### For a cinema

* https://msk.subscity.ru/cinemas/screenings/[cinema_id].json
* https://spb.subscity.ru/cinemas/screenings/[cinema_id].json

```JSON
[
  {
    "cinema_id": 311,
    "date_time": "2016-10-10T10:00:00+03:00",
    "movie_id": 25415,
    "price_max": 250,
    "price_min": 200,
    "screening_id": 24211337
  },
  {
    "cinema_id": 311,
    "date_time": "2016-10-10T11:40:00+03:00",
    "movie_id": 24070,
    "price_max": null,
    "price_min": null,
    "screening_id": 24211338
  },

  ...

]
```

Sorting: by `date_time` ascending.

**NB**: `screening_id` field is a Rambler.Kassa's screening ID.

### For a day

* https://msk.subscity.ru/dates/screenings/[YYYY]-[MM]-[DD].json
* https://spb.subscity.ru/dates/screenings/[YYYY]-[MM]-[DD].json

```JSON
[
  {
    "cinema_id": 23,
    "date_time": "2016-10-10T09:15:00+03:00",
    "movie_id": 24070,
    "price_max": 100,
    "price_min": 100,
    "screening_id": 24077100
  },

  ...

]
```

Sorting: by `date_time` ascending.

**NB**: `screening_id` field is a Rambler.Kassa's screening ID.

**NB**: Screenings belong to a day if they start between 02:31 AM of this day and 02:30 AM of the following one.
