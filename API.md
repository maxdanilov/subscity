SubsCity JSON API
===================

All call results are cached for up to 15 minutes.

* [Movies List](#movies-list)
* [Movie Screenings List](#movie-screenings-list)
* [Cinemas List](#cinemas-list)
* [Cinema Screenings List](#cinema-screenings-list)
* [Date Screenings List](#date-screenings-list)

## Movies List

* https://msk.subscity.ru/movies.json
* https://spb.subscity.ru/movies.json

```JSON
[
  {
	    "age_restriction": 16,
	    "cast": "Джозеф Гордон-Левитт\r\nШейлин Вудли\r\nСкотт Иствуд",
	    "country": "США, Германия, Франция",
	    "created_at": "2016-09-09T05:55:55+03:00",
	    "description": "Он мечтал продолжить семейную традицию и посвятить свою жизнь служению Родине.",
	    "description_english": "",
	    "director": "Оливер Стоун",
	    "duration": 140,
	    "genres": "триллер",
	    "id": 24070,
	    "imdb_id": 3774114,
	    "kinopoisk_id": 843831,
	    "languages": "English",
	    "poster": "https://img05.rl0.ru/kassa/c144x214/s1.kassa.rl0.ru/StaticContent/P/Img/1609/08/160908192744817.jpg",
	    "title": "Сноуден",
	    "title_original": "Snowden",
	    "trailer": "QlSAiI3xMh4*f93Wttq02zI",
	    "year": 2016
  },

  ...

]
```

## Movie Screenings List

* https://msk.subscity.ru/movies/screenings/[movie_id].json
* https://spb.subscity.ru/movies/screenings/[movie_id].json

```JSON
[
  {
    "cinema_id": 28,
    "date_time": "2016-10-10T11:40:00+03:00",
    "price_max": 250,
    "price_min": 200,
    "screening_id": 24211338
  },

  ...

]
```

**NB**: `screening_id` field is Rambler.Kassa's screening ID.

## Cinemas List

* https://msk.subscity.ru/cinemas.json
* https://spb.subscity.ru/cinemas.json

```JSON
[
  {
    "address": "Покровка, 47/24",
    "id": 28,
    "metro": "Красные Ворота, Курская",
    "name": "35ММ",
    "phone": "+7 (495) 917 17 48",
    "url": "http://www.kino35mm.ru",
    "movies_count": 5,
    "movies": [
      25636,
      24367,
      25415,
      24070,
      25666
    ]
  },

  ...

]
```

## Cinema Screenings List

* https://msk.subscity.ru/cinemas/screenings/[cinema_id].json
* https://spb.subscity.ru/cinemas/screenings/[cinema_id].json

```JSON
[
  {
    "date_time": "2016-10-10T10:00:00+03:00",
    "movie_id": 25415,
    "price_max": 250,
    "price_min": 200,
    "screening_id": 24211337
  },
  {
    "date_time": "2016-10-10T11:40:00+03:00",
    "movie_id": 24070,
    "price_max": null,
    "price_min": null,
    "screening_id": 24211338
  },

  ...

]
```

**NB**: `screening_id` field is Rambler.Kassa's screening ID.

## Date Screenings List

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
    "screening_id": 24077100,
  },

  ...

]
```

**NB**: `screening_id` field is Rambler.Kassa's screening ID.

**NB**: Screenings belong to the day if they start between 02:31 AM of this day and 02:30 AM of the following one.
