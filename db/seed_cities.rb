shell.say "Seeding DB with cities"

City.new(city_id: 2, name: "Москва", domain: "msk", active: true).save
City.new(city_id: 3, name: "Санкт-Петербург", domain: "spb", active: true).save

shell.say "done"