def price_tag_style(price)
  case price
  when 0...200 then 'label-success'
  when 200...350 then 'label-primary'
  when 350...500 then 'label-warning'
  when 500...10**6 then 'label-danger'
  else 'label-danger'
  end
end

def time_of_day(time)
  case time.hour
  when 6...12 then 'morning'
  when 12...18 then 'day'
  else 'evening'
  end
end

def format_price(price)
  price.to_s.empty? ? '.' : price.to_s
end

def format_price_range(min, max)
  min.to_i != max.to_i ? "от #{min} до #{max}" : min.to_s
end

def format_title(title)
  title
end

def format_word(count, words)
  if count.to_i.between? 11, 14
    words[5]
  else
    case count.to_i % 10
    when 1 then words[1]
    when 2..4 then words[2]
    when 5..9 then words[5]
    else words[5]
    end
  end
end

def format_word_count(count, words)
  "#{count} #{format_word(count, words)}"
end

def languages_format(langs)
  langs.split(', ').uniq.map { |l| language(l) }.join(', ') rescue nil
end

def language(lang)
  l = {
    'English' => 'английский',
    'Aboriginal' => 'аборигенский',
    'Arabic' => 'арабский',
    'Armenian' => 'армянский',
    'Afrikaans' => 'африкаанс',
    'Bulgarian' => 'болгарский',
    'Catalan' => 'каталанский',
    'Chinese' => 'китайский',
    'Croatian' => 'хорватский',
    'Creole' => 'креольский',
    'Czech' => 'чешский',
    'Danish' => 'датский',
    'Dutch' => 'голландский',
    'Estonian' => 'эстонский',
    'Faroese' => 'фарерский',
    'Farsi' => 'фарси',
    'Finnish' => 'финский',
    'French' => 'французский',
    'Gaelic' => 'гаэльский',
    'German' => 'немецкий',
    'Georgian' => 'грузинский',
    'Greek' => 'греческий',
    'Greenlandic' => 'гренландский',
    'Hebrew' => 'иврит',
    'Hindi' => 'хинди',
    'Hokkien' => 'хок-кьень',
    'Hungarian' => 'венгерский',
    'Icelandic' => 'исландский',
    'Iranian' => 'фарси',
    'Irish' => 'ирландский',
    'Irish Gaelic' => 'ирландский',
    'Italian' => 'итальянский',
    'Japanese' => 'японский',
    'Korean' => 'корейский',
    'Kurdish' => 'курдский',
    'Latvian' => 'латышский',
    'Ladino' => 'ладино',
    'Latin' => 'латинский',
    'Lingala' => 'лингала',
    'Lithuanian' => 'литовский',
    'Luxembourgish' => 'люксембуржский',
    'Macedonian' => 'македонский',
    'Malay' => 'малайский',
    'Mandarin' => 'китайский',
    'Navajo' => 'навахо',
    'Norwegian' => 'норвежский',
    'Pashto' => 'пушту',
    'Polish' => 'польский',
    'Portuguese' => 'португальский',
    'Romanian' => 'румынский',
    'Russian' => 'русский',
    'Scottish' => 'шотландский',
    'Serbian' => 'сербский',
    'Sicilian' => 'сицилийский',
    'Slovenian' => 'словенский',
    'Slovakian' => 'словацкий',
    'Somali' => 'сомалийский',
    'Spanish' => 'испанский',
    'Swahili' => 'суахили',
    'Swedish' => 'шведский',
    'Swiss German' => 'немецкий (швейцарский диалект)',
    'Tagalog' => 'тагальский',
    'Tamil' => 'тамильский',
    'Telugu' => 'телугу',
    'Turkish' => 'турецкий',
    'Urdu' => 'урду',
    'Ukrainian' => 'украинский',
    'Welsh' => 'уэльский',
    'Wolof' => 'волоф',
    'Yiddish' => 'идиш'
  }

  l[lang] || lang
end

def format_word_count_generic(count, with_number, words)
  with_number ? format_word_count(count, words) : format_word(count, words)
end

def format_next_screening(time)
  date = date_for_screening(time)
  date_now = date_for_screening(Time.now)
  diff = difference_in_days(date, date_now)
  case diff
  when 0 then 'сегодня'
  when 1 then 'завтра'
  when 2 then 'послезавтра'
  else "через #{format_in_days_count(diff)}"
  end
end

def format_in_days_count(count, with_number = true)
  format_word_count_generic(count, with_number, 1 => 'день', 2 => 'дня', 5 => 'дней')
end

def format_movies_count(count, with_number = true)
  format_word_count_generic(count, with_number, 1 => 'фильм', 2 => 'фильма', 5 => 'фильмов')
end

def format_screenings_count(count, with_number = true)
  format_word_count_generic(count, with_number, 1 => 'сеанс', 2 => 'сеанса', 5 => 'сеансов')
end

def format_cinemas_count(count, with_number = true)
  format_word_count_generic(count, with_number, 1 => 'кинотеатр', 2 => 'кинотеатра', 5 => 'кинотеатров')
end

def format_in_cinemas_count(count, with_number = true)
  format_word_count_generic(count, with_number, 1 => 'кинотеатре', 2 => 'кинотеатрах', 5 => 'кинотеатрах')
end

def format_date_url(date)
  date.strftime('%Y-%m-%d')
end

def format_movie_url(movie)
  if movie.title_original.to_s.empty?
    "#{movie.id} #{Translit.convert(movie.title, :english)}".to_url
  else
    "#{movie.id} #{Translit.convert(movie.title_original, :english)}".to_url
  end
end

def format_cinema_url(movie)
  "#{movie.id} #{Translit.convert(movie.name, :english)}".to_url
end

def format_simple_url(movie)
  movie.id.to_s
end

def link_to_cinema(cinema)
  link_to(cinema.name, url(:cinemas, :index, cinema.format_url), class: 'underdashed')
end

def link_to_movie(movie, text = nil)
  text ||= movie.title
  "<a class='underdashed' href='#{url(:movies, :index, movie.format_url)}'>#{hyphenate(text, :ru)}</a>"
end

def link_to_date(day)
  link_to(show_date(day), url(:dates, :index, day), class: 'underdashed')
end

def hyphenate(text, lang)
  h = Text::Hyphen.new(language: lang.to_s, left: 4, right: 4)
  text.split(' ').collect! { |w| h.visualise(w, '&shy;') }.join(' ')
end

def social_urls(city)
  vk_url = "//vk.com/subscity_#{city&.domain || 'msk'}"
  fb_url = "//fb.com/subscity.#{city&.domain || 'msk'}"
  t_url = "//t.me/subscity_#{city&.domain || 'msk'}"
  { vk: vk_url, fb: fb_url, t: t_url }
end

def item_sorting(query_string, allowed_types, allowed_fields)
  type = query_string[0] rescue allowed_types.first
  field = query_string[1..-1] rescue allowed_fields.first
  type = allowed_types.first unless allowed_types.include? type
  field = allowed_fields.first unless allowed_fields.include? field
  { type: type, field: field }
end

def cinema_sorting(query_string)
  item_sorting(query_string, ['+', '-'], %w[name id])
end

def movie_sorting(query_string)
  item_sorting(query_string, ['+', '-'], %w[title imdb kinopoisk screenings next_screening id])
end

def cinema_sorting_block(field)
  case field
  when 'name'
    proc { |i| i['name'] }
  else
    proc { |i| i['id'] }
  end
end

def movie_sorting_block(field)
  case field
  when 'title'
    proc { |i| i[field]['russian'] || '' }
  when 'kinopoisk', 'imdb'
    proc { |i| i['rating'][field.to_sym][:rating] || 0 }
  when 'next_screening'
    proc { |i| i['screenings']['next'] }
  when 'screenings'
    proc { |i| i['screenings']['count'] }
  else
    proc { |i| i['id'] }
  end
end
