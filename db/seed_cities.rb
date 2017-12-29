# encoding: UTF-8

shell.say 'Seeding DB with cities'

City.new(city_id: 2, name: 'Москва', name_short: 'Москва', domain: 'msk', active: true).save
City.new(city_id: 3, name: 'Санкт-Петербург', name_short: 'СПб', domain: 'spb', active: true).save

shell.say 'done'